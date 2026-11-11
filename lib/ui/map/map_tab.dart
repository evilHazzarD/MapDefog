import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapdefog/app/app_scope.dart';
import 'package:mapdefog/data/settings_store.dart';
import 'package:mapdefog/domain/caches.dart';
import 'package:mapdefog/explore/explorer.dart';
import 'package:mapdefog/explore/fix.dart';
import 'package:mapdefog/explore/location_feed.dart';
import 'package:mapdefog/geo/grid.dart';
import 'package:mapdefog/l10n/app_localizations.dart';
import 'package:mapdefog/l10n/game_text.dart';
import 'package:mapdefog/ui/components/components.dart';
import 'package:mapdefog/ui/game_data.dart';
import 'package:mapdefog/ui/map/fog_layer.dart';
import 'package:mapdefog/ui/navigation.dart';
import 'package:mapdefog/ui/texts.dart';
import 'package:mapdefog/ui/theme/theme.dart';
import 'package:mapdefog/util/days.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key, required this.mapFocus, required this.data});

  final ValueNotifier<MapFocus?> mapFocus;
  final GameData data;

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapToast {
  _MapToast(this.icon, this.text, this.color);
  final IconData icon;
  final String text;
  final Color color;
}

class _MapTabState extends State<MapTab> with WidgetsBindingObserver {
  final _controller = MapController();
  var _acquired = false;
  LocationFeed? _feed;
  StreamSubscription<GameEvent>? _eventsSub;
  Timer? _toastTimer;
  Timer? _tick;

  var _follow = true;
  var _centered = false;
  var _permitted = true;
  final _toasts = <_MapToast>[];
  var _now = DateTime.now().millisecondsSinceEpoch;
  double? _lastFollowLat;
  double? _lastFollowLon;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.mapFocus.addListener(_onMapFocus);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now().millisecondsSinceEpoch);
    });
  }

  @override
  void didUpdateWidget(covariant MapTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapFocus != widget.mapFocus) {
      oldWidget.mapFocus.removeListener(_onMapFocus);
      widget.mapFocus.addListener(_onMapFocus);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_acquired) {
      _acquired = true;
      final scope = AppScope.of(context);
      _feed = scope.feed;
      _feed!.acquire();
      _refreshPermission();
      _eventsSub = scope.explorer.events.listen(_onGameEvent);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.mapFocus.removeListener(_onMapFocus);
    _eventsSub?.cancel();
    _toastTimer?.cancel();
    _tick?.cancel();
    if (_acquired) {
      // Release map ref; walk may still hold the feed.
      _feed?.release();
      _acquired = false;
    }
    super.dispose();
  }

  Future<void> _refreshPermission() async {
    final feed = _feed;
    if (feed == null) return;
    final ok = await feed.permitted();
    if (mounted) setState(() => _permitted = ok);
  }

  void _onGameEvent(GameEvent e) {
    if (!mounted) return;
    final c = AppLocalizations.of(context);
    final p = context.palette;
    final settings = AppScope.of(context).settings.now();

    _MapToast? toast;
    switch (e) {
      case NewSectorEvent(:final sector):
        toast = _MapToast(
          Icons.travel_explore_rounded,
          c.toastNewLand(c.sectorName(sector)),
          p.accent,
        );
      case MilestoneEvent(:final sector, :final share, :final coins):
        toast = _MapToast(
          Icons.travel_explore_rounded,
          c.toastMilestone(c.sectorName(sector), (share * 100).toInt(), coins),
          p.gold,
        );
      case BeaconEvent():
        toast = _MapToast(Icons.flare_rounded, c.notifyShrineReached, p.flame);
      case OpenedEvent():
      case NearEvent():
        toast = null;
    }

    if (settings.haptics && (e is OpenedEvent || e is BeaconEvent)) {
      HapticFeedback.mediumImpact();
    }

    if (toast != null) {
      setState(() {
        _toasts.add(toast!);
        if (_toasts.length > 3) _toasts.removeAt(0);
      });
      _toastTimer?.cancel();
      _toastTimer = Timer(const Duration(milliseconds: 3500), () {
        if (!mounted || _toasts.isEmpty) return;
        setState(() => _toasts.removeAt(0));
      });
    }
  }

  void _onMapFocus() {
    final f = widget.mapFocus.value;
    if (f == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _follow = false);
      _goTo(LatLng(f.lat, f.lon), f.zoom);
      widget.mapFocus.value = null;
    });
  }

  void _goTo(LatLng target, [double? zoom]) {
    try {
      _controller.move(target, zoom ?? _controller.camera.zoom);
    } on Exception {
      // Map not ready yet (controller not attached).
    }
  }

  void _followFix(double lat, double lon) {
    try {
      final z = _controller.camera.zoom;
      if (z < 12) {
        _controller.move(LatLng(lat, lon), 17);
      } else {
        _controller.move(LatLng(lat, lon), z);
      }
    } on Exception {
      // Map not ready yet (controller not attached).
    }
  }

  /// "Go to my location". The live feed only runs during a walk; otherwise
  /// [fix] is the last saved position (time 0), so fetch a fresh one.
  Future<void> _goToMe(Fix? fix) async {
    setState(() => _follow = true);
    if (fix != null) {
      _lastFollowLat = fix.lat;
      _lastFollowLon = fix.lon;
      _followFix(fix.lat, fix.lon);
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final fresh = fix != null && fix.time > 0 && now - fix.time < 30 * 1000;
    if (fresh) return;
    final scope = AppScope.of(context);
    if (!await scope.feed.requestPermission()) {
      await _refreshPermission();
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (!mounted || !_follow) return;
      _lastFollowLat = pos.latitude;
      _lastFollowLon = pos.longitude;
      _followFix(pos.latitude, pos.longitude);
    } on Exception catch (e) {
      // No fix in time / location off: stay on the last known spot.
      debugPrint('Current position unavailable: $e');
    }
  }

  String _minsLeft(int until) {
    final c = AppLocalizations.of(context);
    final mins = ((until - _now) / 60000).floor() + 1;
    return '$mins ${c.unitMinutes}';
  }

  @override
  Widget build(BuildContext context) {
    final c = AppLocalizations.of(context);
    final scope = AppScope.of(context);
    final p = context.palette;
    final settings = scope.settings.now();
    final start = settings.lastLat != 0 || settings.lastLon != 0
        ? LatLng(settings.lastLat, settings.lastLon)
        : const LatLng(50.087, 14.421);

    return ListenableBuilder(
      listenable: scope.settingsListenable,
      builder: (context, _) {
        final settings = scope.settings.now();
        return StreamBuilder(
          stream: scope.explorer.live,
          initialData: scope.explorer.liveValue,
          builder: (context, snap) {
            final live = snap.data!;
            final fix = live.fix;
            final today = todayEpochDay();
            final week = Caches.week(today);
            final beacon = settings.beacon.day == today
                ? LatLng(settings.beacon.lat, settings.beacon.lon)
                : null;
            final scene = FogScene(
              fix: fix == null ? null : LatLng(fix.lat, fix.lon),
              accuracy: fix?.accuracy ?? 9999,
              trail: live.trail.map((e) => LatLng(e.$1, e.$2)).toList(),
              beacon: beacon,
              beaconReached: widget.data.todayRow.beacon,
              week: week,
              opened: widget.data.opened,
              radar: settings.radarUntil > _now,
              style: settings.fog,
              density: settings.fogDensity,
            );

            // Follow the walker; the first real fix also zooms in.
            if (fix != null &&
                fix.time > 0 &&
                (_follow || !_centered) &&
                (_lastFollowLat != fix.lat || _lastFollowLon != fix.lon)) {
              final lat = fix.lat;
              final lon = fix.lon;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _lastFollowLat = lat;
                _lastFollowLon = lon;
                if (!_centered) {
                  setState(() {
                    _centered = true;
                    _follow = true;
                  });
                  _goTo(LatLng(lat, lon), 17);
                } else if (_follow) {
                  _followFix(lat, lon);
                }
              });
            }

            final lanternOn = settings.lanternUntil > _now;
            final radarOn = settings.radarUntil > _now;

            return Stack(
              children: [
                FlutterMap(
                  mapController: _controller,
                  options: MapOptions(
                    initialCenter: start,
                    initialZoom: 16,
                    backgroundColor: const Color(0xFFEFE3C8),
                    onPositionChanged: (camera, hasGesture) {
                      if (hasGesture && _follow) {
                        setState(() => _follow = false);
                      }
                    },
                    onLongPress: kDebugMode
                        ? (tap, latlng) {
                            scope.simulateTo(latlng.latitude, latlng.longitude);
                          }
                        : null,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'app.mapdefog',
                      tileBuilder: (context, tileWidget, tile) {
                        return ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            0.393,
                            0.769,
                            0.189,
                            0,
                            0,
                            0.349,
                            0.686,
                            0.168,
                            0,
                            0,
                            0.272,
                            0.534,
                            0.131,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                          ]),
                          child: tileWidget,
                        );
                      },
                    ),
                    FogLayer(fog: scope.fog, scene: scene),
                  ],
                ),
                // Today / lantern / radar HUD pills (Android TopHud)
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _HudPill(
                                icon: Icons.directions_walk_rounded,
                                label: c.todayLine(
                                  widget.data.todayRow.cells,
                                  formatDistance(
                                    widget.data.todayRow.meters,
                                    imperial: settings.units == UnitsPref.imperial,
                                    content: c,
                                  ),
                                ),
                                color: p.accent,
                              ),
                              if (lanternOn)
                                _HudPill(
                                  icon: Icons.lightbulb_rounded,
                                  label: c.lanternLeft(_minsLeft(settings.lanternUntil)),
                                  color: p.gold,
                                ),
                              if (radarOn)
                                _HudPill(
                                  icon: Icons.radar_rounded,
                                  label: c.radarLeft(_minsLeft(settings.radarUntil)),
                                  color: p.violet,
                                ),
                            ],
                          ),
                        ),
                        // Shrine of the day: top right, mirroring Today.
                        if (beacon != null && fix != null) ...[
                          const SizedBox(width: 6),
                          _HudPill(
                            icon: Icons.flare_rounded,
                            label: c.shrineLabel(
                              _arrow(fix.lat, fix.lon, beacon.latitude, beacon.longitude),
                            ),
                            color: widget.data.todayRow.beacon ? p.accent : p.gold,
                            onTap: () {
                              setState(() => _follow = false);
                              _goTo(beacon, 16);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Event toasts
                if (_toasts.isNotEmpty)
                  Positioned(
                    top: 56,
                    left: 12,
                    right: 12,
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          for (final t in _toasts)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Material(
                                elevation: 4,
                                color: p.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: U.rMd,
                                  side: BorderSide(color: p.gilt),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  child: Row(
                                    children: [
                                      Icon(t.icon, size: 20, color: t.color),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          t.text,
                                          style: UType.body(p).copyWith(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Material(
                          color: p.surface.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            child: Text(c.osmCredit, style: UType.small(p).copyWith(fontSize: 10)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (!_permitted)
                        Material(
                          elevation: 8,
                          color: p.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: U.rLg,
                            side: BorderSide(color: p.gilt, width: 1.5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(c.needLocationTitle, style: UType.strong(p)),
                                const SizedBox(height: 4),
                                Text(c.needLocationText, style: UType.muted(p)),
                                const SizedBox(height: 12),
                                PrimaryButton(
                                  c.allowLocation,
                                  icon: Icons.my_location,
                                  onPressed: () async {
                                    final ok = await scope.feed.requestPermission();
                                    if (ok) await scope.feed.restart();
                                    await _refreshPermission();
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () async {
                                  final walking = settings.walking;
                                  if (!walking) {
                                    await scope.startWalk();
                                  } else {
                                    await scope.stopWalk();
                                  }
                                  setState(() {});
                                },
                                icon: Icon(settings.walking ? Icons.stop : Icons.directions_walk),
                                label: Text(settings.walking ? c.endJourney : c.setOut),
                              ),
                            ),
                            if (live.tooFast) ...[
                              const SizedBox(width: 8),
                              Chip(label: Text(c.tooFast)),
                            ],
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              tooltip: c.followMe,
                              onPressed: () => _goToMe(fix),
                              style: IconButton.styleFrom(
                                foregroundColor: _follow ? p.accent : p.muted,
                                // Drop the invisible tap padding so the
                                // circle matches Set out's 40px height.
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: Icon(_follow ? Icons.my_location : Icons.location_searching),
                            ),
                          ],
                        ),
                      if (_permitted && settings.walking) ...[
                        const SizedBox(height: 6),
                        Text(c.walkingHint, textAlign: TextAlign.center, style: UType.small(p)),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _arrow(double lat1, double lon1, double lat2, double lon2) {
    final b = Grid.bearing(lat1, lon1, lat2, lon2);
    const arrows = ['↑', '↗', '→', '↘', '↓', '↙', '←', '↖'];
    return arrows[((b + 22.5) % 360 / 45).floor()];
  }
}

class _HudPill extends StatelessWidget {
  const _HudPill({required this.icon, required this.label, required this.color, this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      elevation: 3,
      color: p.surface,
      clipBehavior: Clip.antiAlias,
      shape: StadiumBorder(side: BorderSide(color: p.gilt.withValues(alpha: 0.7))),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 5),
              Text(label, style: UType.strong(p).copyWith(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
