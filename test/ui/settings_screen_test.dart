import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapdefog/app/app_scope.dart';
import 'package:mapdefog/data/database.dart';
import 'package:mapdefog/data/settings_store.dart';
import 'package:mapdefog/domain/fog.dart';
import 'package:mapdefog/explore/explorer.dart';
import 'package:mapdefog/explore/location_feed.dart';
import 'package:mapdefog/l10n/app_localizations.dart';
import 'package:mapdefog/ui/settings/settings_screen.dart';
import 'package:mapdefog/ui/theme/theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late FogDatabase db;
  late SettingsStore settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'MapDefog',
      packageName: 'app.mapdefog',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    db = FogDatabase.forTesting(NativeDatabase.memory());
    settings = SettingsStore(await SharedPreferences.getInstance());
  });
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester, {Locale? locale}) async {
    final fog = FogStore();
    final explorer = Explorer(db: db, settings: settings, fog: fog);
    final container = AppContainer(
      db: db,
      settings: settings,
      fog: fog,
      explorer: explorer,
      feed: LocationFeed(explorer),
    );
    await tester.pumpWidget(
      AppScope(
        container: container,
        child: MaterialApp(
          theme: mapDefogTheme(lightPalette),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Material(
            child: SettingsScreen(settings: settings.now(), onBack: () {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the app version', (tester) async {
    await pump(tester);
    expect(find.text('Settings'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('1.0.0'), 200);
    expect(find.textContaining('1.0.0'), findsOneWidget);
  });

  testWidgets('choosing imperial units is saved', (tester) async {
    await pump(tester);
    await tester.scrollUntilVisible(find.text('Imperial'), 200);
    await tester.tap(find.text('Imperial'));
    await tester.pumpAndSettle();

    expect(settings.now().units, UnitsPref.imperial);
  });

  testWidgets('turning off the daily reminder hides its time', (tester) async {
    await pump(tester);
    expect(find.textContaining('Remind at'), findsOneWidget);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(settings.now().remind, isFalse);
    expect(find.textContaining('Remind at'), findsNothing);
  });

  testWidgets('follows the chosen language', (tester) async {
    await pump(tester, locale: const Locale('uk'));
    expect(find.text('Налаштування'), findsOneWidget);
    expect(find.text('Щоденне нагадування'), findsOneWidget);
  });
}
