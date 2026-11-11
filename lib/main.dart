import 'package:flutter/material.dart';
import 'package:mapdefog/app/app_scope.dart';
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
import 'package:mapdefog/ui/root.dart';
import 'package:mapdefog/ui/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsStore(prefs);
  final locale = resolveAppLocale(settings.now());
  await WalkTask.init(content: lookupAppLocalizations(locale), langTag: locale.languageCode);
  await Alarms.init();
  final db = FogDatabase();
  final fog = FogStore();
  final explorer = Explorer(db: db, settings: settings, fog: fog);
  await explorer.load();
  final feed = LocationFeed(explorer);

  final container = AppContainer(
    db: db,
    settings: settings,
    fog: fog,
    explorer: explorer,
    feed: feed,
  );

  Alarms.bind(db: db, routeHandler: container.openRoute);

  explorer.events.listen((e) {
    // While the walk service tracks, it notifies about its own events.
    if (container.serviceTracking) return;
    Alarms.onEvent(e, visible: container.visible, settings: settings.now());
  });

  final s = settings.now();
  await Alarms.scheduleRemind(enabled: s.remind, minutesFromMidnight: s.remindAt, settings: s);

  var lastLanguage = s.language;
  var lastRemind = s.remind;
  var lastRemindAt = s.remindAt;
  settings.addListener((n) {
    if (n.language != lastLanguage) {
      lastLanguage = n.language;
      final loc = resolveAppLocale(n);
      final c = lookupAppLocalizations(loc);
      // init() re-creates the channel under the new language; bindContent()
      // updates a running notification. Then the service re-reads the language.
      WalkTask.init(
        content: c,
        langTag: loc.languageCode,
      ).then((_) => WalkTask.bindContent(c, langTag: loc.languageCode)).then((_) {
        if (container.serviceTracking) WalkTask.send(WalkMessage.settings);
      });
      lastRemind = !n.remind; // force reschedule below
    }
    if (n.remind != lastRemind || n.remindAt != lastRemindAt) {
      lastRemind = n.remind;
      lastRemindAt = n.remindAt;
      Alarms.scheduleRemind(enabled: n.remind, minutesFromMidnight: n.remindAt, settings: n);
    }
  });

  runApp(MapDefogApp(container: container));
}

class MapDefogApp extends StatefulWidget {
  const MapDefogApp({super.key, required this.container});

  final AppContainer container;

  @override
  State<MapDefogApp> createState() => _MapDefogAppState();
}

class _MapDefogAppState extends State<MapDefogApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.container.settings.addListener(_onSettings);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.container.settings.removeListener(_onSettings);
    super.dispose();
  }

  void _onSettings(Settings _) {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.container.visible = state == AppLifecycleState.resumed;
    if (state == AppLifecycleState.resumed) {
      // Rebook the reminder window: today's streak may have changed and the
      // furthest booked day moves forward.
      final s = widget.container.settings.now();
      Alarms.scheduleRemind(enabled: s.remind, minutesFromMidnight: s.remindAt, settings: s);
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    final s = widget.container.settings.now();
    if (s.language != LanguagePref.system) return;
    final loc = resolveAppLocale(s);
    WalkTask.bindContent(lookupAppLocalizations(loc), langTag: loc.languageCode).then((_) {
      // The service reads the saved language when told settings changed.
      if (widget.container.serviceTracking) WalkTask.send(WalkMessage.settings);
    });
    Alarms.scheduleRemind(enabled: s.remind, minutesFromMidnight: s.remindAt, settings: s);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.container.settings.now();
    final themeMode = switch (settings.theme) {
      ThemeModePref.system => ThemeMode.system,
      ThemeModePref.light => ThemeMode.light,
      ThemeModePref.dark => ThemeMode.dark,
    };

    return AppScope(
      container: widget.container,
      child: MaterialApp(
        title: 'MapDefog',
        theme: mapDefogTheme(lightPalette),
        darkTheme: mapDefogTheme(darkPalette),
        themeMode: themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: switch (settings.language) {
          LanguagePref.system => null,
          LanguagePref.en => const Locale('en'),
          LanguagePref.ru => const Locale('ru'),
          LanguagePref.uk => const Locale('uk'),
        },
        builder: (context, child) => Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: child,
        ),
        home: const MapDefogRoot(),
      ),
    );
  }
}
