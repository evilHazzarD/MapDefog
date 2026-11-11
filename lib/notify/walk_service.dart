import 'dart:async';
import 'dart:ui' show DartPluginRegistrant, Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapdefog/data/database.dart';
import 'package:mapdefog/data/settings_store.dart';
import 'package:mapdefog/domain/fog.dart';
import 'package:mapdefog/explore/explorer.dart';
import 'package:mapdefog/explore/location_feed.dart';
import 'package:mapdefog/explore/walk_messages.dart';
import 'package:mapdefog/l10n/app_localizations.dart';
import 'package:mapdefog/l10n/locale_resolve.dart';
import 'package:mapdefog/notify/alarms.dart';
import 'package:mapdefog/notify/walk_task.dart';
import 'package:mapdefog/ui/texts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks a walk inside the Android foreground service's isolate, so it
/// keeps recording when the app is swiped away or its UI is destroyed.
///
/// It has its own settings, database connection, fog and [Explorer], and
/// while the app is alive it streams what it records to the app, which
/// mirrors it ([WalkMessage]).
class WalkService {
  WalkService._(this._settings, this._db, this._explorer, this._feed);

  final SettingsStore _settings;
  final FogDatabase _db;
  final Explorer _explorer;
  final LocationFeed _feed;
  final _subs = <StreamSubscription<Object?>>[];

  /// Whether the app is on screen; until it says so, assume not.
  var _appVisible = false;

  /// The app's resolved language, used while the setting is "system".
  String? _appLanguage;

  /// Starts tracking, or returns null when no walk is in progress (the
  /// service was started again after the walk ended).
  static Future<WalkService?> start() async {
    DartPluginRegistrant.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final settings = SettingsStore(prefs);
    if (!settings.now().walking) return null;
    if (!await Geolocator.checkPermission().then(_usable)) {
      // Location was revoked since the walk began: end it rather than run a
      // notification that says "charting" while nothing records.
      await settings.update((s) => s.copyWith(walking: false));
      _send(WalkMessage.stopped);
      return null;
    }

    final db = FogDatabase();
    final explorer = Explorer(db: db, settings: settings, fog: FogStore());
    await explorer.load();
    await Alarms.init();
    Alarms.bind(db: db);

    final service = WalkService._(settings, db, explorer, LocationFeed(explorer));
    service._appLanguage = await WalkTask.savedLanguage();
    service._listen();
    await service._feed.acquire();
    service._sendLive(explorer.liveValue);
    return service;
  }

  void _listen() {
    _subs
      ..add(_explorer.live.listen(_onLive))
      ..add(_explorer.revealed.listen((ids) => _send(WalkMessage.cells, {'ids': ids})))
      ..add(_explorer.events.listen(_onEvent))
      ..add(
        _db.tableUpdates().listen(
          (updates) => _send(WalkMessage.tables, {
            'names': [for (final u in updates) u.table],
          }),
        ),
      );
    _settings.onWrite = () => _send(WalkMessage.settings);
  }

  void _onLive(Live live) {
    _sendLive(live);
    _updateNotification(live);
  }

  void _sendLive(Live live) => _send(WalkMessage.live, {'live': WalkCodec.live(live)});

  Future<void> _onEvent(GameEvent e) async {
    _send(WalkMessage.event, {'e': WalkCodec.event(e)});
    // On screen, the app celebrates the event itself.
    if (_appVisible) return;
    await Alarms.onEvent(e, visible: false, settings: _settings.now());
  }

  Future<void> _updateNotification(Live live) async {
    final s = _settings.now();
    final w = live.walk;
    final now = DateTime.now().millisecondsSinceEpoch;
    // Only show stats while the walk is fresh (< 20 min since the last step).
    final active = w != null && now - w.end < Explorer.walkGapMs;
    final app = _appLanguage;
    final c = lookupAppLocalizations(
      s.language == LanguagePref.system && app != null ? Locale(app) : resolveAppLocale(s),
    );
    await WalkTask.updateLive(
      content: c,
      cells: active ? w.cells : 0,
      distanceLabel: active
          ? formatDistance(w.meters, imperial: s.units == UnitsPref.imperial, content: c)
          : '',
      hasWalk: active,
    );
  }

  /// Handles a message from the app.
  Future<void> onMessage(Object data) async {
    final m = data is Map ? data : const {};
    switch (WalkMessage.typeOf(data)) {
      case WalkMessage.hello:
        _appVisible = m['v'] == true;
        _sendLive(_explorer.liveValue);
      case WalkMessage.visible:
        _appVisible = m['v'] == true;
      case WalkMessage.settings:
        _appLanguage = await WalkTask.savedLanguage();
        await _settings.refresh();
      case WalkMessage.reload:
        await _settings.refresh();
        await _explorer.reloadAll();
      case WalkMessage.simulate:
        await _explorer.simulateTo(m['lat']! as double, m['lon']! as double);
      default:
        debugPrint('WalkService: ignored message $data');
    }
  }

  /// The notification's Stop button: ends the walk with or without the app.
  Future<void> stopFromNotification() async {
    await _settings.update((s) => s.copyWith(walking: false));
    _send(WalkMessage.stopped);
    await FlutterForegroundTask.stopService();
  }

  Future<void> dispose() async {
    _settings.onWrite = null;
    for (final sub in _subs) {
      await sub.cancel();
    }
    await _feed.release();
    _explorer.dispose();
    await _db.close();
  }

  static bool _usable(LocationPermission p) =>
      p == LocationPermission.always || p == LocationPermission.whileInUse;

  /// Delivered only while the app is running; dropped otherwise.
  static void _send(String type, [Map<String, Object?> body = const {}]) =>
      FlutterForegroundTask.sendDataToMain(WalkMessage.of(type, body));
}
