import 'package:animated_options_bar/animated_options_bar.dart';
import 'package:flutter/material.dart';
import 'package:mapdefog/app/app_scope.dart';
import 'package:mapdefog/l10n/app_localizations.dart';
import 'package:mapdefog/ui/celebrations.dart';
import 'package:mapdefog/ui/game_data.dart';
import 'package:mapdefog/ui/journal/deeds_screen.dart';
import 'package:mapdefog/ui/journal/journal_tab.dart';
import 'package:mapdefog/ui/journal/walk_screen.dart';
import 'package:mapdefog/ui/journal/walks_screen.dart';
import 'package:mapdefog/ui/map/map_tab.dart';
import 'package:mapdefog/ui/navigation.dart';
import 'package:mapdefog/ui/onboarding/onboarding_screen.dart';
import 'package:mapdefog/ui/quests/quests_tab.dart';
import 'package:mapdefog/ui/settings/settings_screen.dart';
import 'package:mapdefog/ui/theme/theme.dart';
import 'package:mapdefog/ui/treasury/treasury_tab.dart';

class MapDefogRoot extends StatefulWidget {
  const MapDefogRoot({super.key});

  @override
  State<MapDefogRoot> createState() => _MapDefogRootState();
}

class _MapDefogRootState extends State<MapDefogRoot> with WidgetsBindingObserver {
  var _tab = FogTab.map;
  var _route = 'welcome';
  int? _walkId;
  late final ValueNotifier<MapFocus?> _mapFocus;
  FogGo? _go;
  ValueNotifier<String?>? _pendingRoute;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mapFocus = ValueNotifier(null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final scope = AppScope.of(context);
      _pendingRoute = scope.pendingRoute..addListener(_onPendingRoute);
      final s = scope.settings.now();
      setState(() => _route = s.onboarded ? 'main' : 'welcome');
      if (s.walking) {
        scope.startWalk();
      }
    });
  }

  @override
  void dispose() {
    _pendingRoute?.removeListener(_onPendingRoute);
    _mapFocus.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onPendingRoute() {
    final scope = AppScope.of(context);
    final route = scope.pendingRoute.value;
    if (route == null) return;
    scope.pendingRoute.value = null;
    if (!scope.settings.now().onboarded) return;
    applyRoute(route);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppScope.of(context).visible = state == AppLifecycleState.resumed;
  }

  FogGo _navigation() {
    return _go ??= FogGo(
      openSettings: () => setState(() => _route = 'settings'),
      openDeeds: () => setState(() => _route = 'deeds'),
      openWalks: () => setState(() => _route = 'walks'),
      openWalk: (id) => setState(() {
        _walkId = id;
        _route = 'walk';
      }),
      selectTab: (t) => setState(() => _tab = t),
      back: () => setState(() => _route = 'main'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final go = _navigation();
    final p = context.palette;

    if (_route == 'welcome') {
      return OnboardingScreen(onDone: () => setState(() => _route = 'main'));
    }

    return GameDataBuilder(
      builder: (context, data) {
        switch (_route) {
          case 'settings':
            return SettingsScreen(settings: data.settings, onBack: go.back);
          case 'deeds':
            return DeedsScreen(data: data, onBack: go.back);
          case 'walks':
            return WalksScreen(data: data, onBack: go.back, onOpen: go.openWalk);
          case 'walk':
            return WalkScreen(id: _walkId ?? -1, data: data, onBack: go.back);
          default:
            break;
        }

        final c = AppLocalizations.of(context);

        return Stack(
          children: [
            ColoredBox(
              color: p.bg,
              child: Column(
                children: [
                  Expanded(
                    child: IndexedStack(
                      index: _tab.index,
                      children: [
                        MapTab(mapFocus: _mapFocus, data: data),
                        QuestsTab(data: data, go: go, mapFocus: _mapFocus),
                        TreasuryTab(data: data, go: go, mapFocus: _mapFocus),
                        JournalTab(data: data, go: go, mapFocus: _mapFocus),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: p.line),
                  _FogTabBar(
                    selected: _tab,
                    toClaim: data.toClaim,
                    labels: (c.tabMap, c.tabQuests, c.tabHoard, c.tabChronicle),
                    onSelect: (t) => setState(() => _tab = t),
                  ),
                ],
              ),
            ),
            CelebrationsHost(data: data),
          ],
        );
      },
    );
  }

  void applyRoute(String route) {
    setState(() {
      switch (route) {
        case 'quests':
          _tab = FogTab.quests;
          _route = 'main';
        // Android Root uses "hoard" / "chronicle"; accept Flutter aliases too.
        case 'treasury':
        case 'hoard':
          _tab = FogTab.treasury;
          _route = 'main';
        case 'journal':
        case 'chronicle':
        case 'deeds':
          _tab = FogTab.journal;
          _route = route == 'deeds' ? 'deeds' : 'main';
        case 'walks':
          _tab = FogTab.journal;
          _route = 'walks';
        case 'settings':
          _route = 'settings';
        default:
          _tab = FogTab.map;
          _route = 'main';
      }
    });
  }
}

/// Bottom tab bar, drawn with [AnimatedOptionsBar]: text tabs with a
/// sliding selection pill. The quest tab shows the count waiting to claim.
class _FogTabBar extends StatelessWidget {
  const _FogTabBar({
    required this.selected,
    required this.toClaim,
    required this.labels,
    required this.onSelect,
  });

  final FogTab selected;
  final int toClaim;
  final (String, String, String, String) labels;
  final ValueChanged<FogTab> onSelect;

  static String _id((FogTab, String) item) => item.$1.name;
  static String _label((FogTab, String) item) => item.$2;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final items = <(FogTab, String)>[
      (FogTab.map, labels.$1),
      (FogTab.quests, toClaim > 0 ? '${labels.$2} · $toClaim' : labels.$2),
      (FogTab.treasury, labels.$3),
      (FogTab.journal, labels.$4),
    ];

    return Material(
      color: p.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AnimatedOptionsBar<(FogTab, String)>(
            items: items,
            selectedId: selected.name,
            onItemSelected: (id) => onSelect(FogTab.values.byName(id)),
            getId: _id,
            getLabel: _label,
            config: OptionsBarConfig(
              textPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              borderRadius: 50,
              itemSpacing: 4,
              scrollEdgePadding: 8,
              activeTextColor: p.onAccent,
              inactiveTextColor: p.muted,
              selectionColor: p.accent,
              animationDuration: const Duration(milliseconds: 260),
              textStyle: const TextStyle(
                fontFamily: 'AlegreyaSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              centerOptions: true,
            ),
          ),
        ),
      ),
    );
  }
}
