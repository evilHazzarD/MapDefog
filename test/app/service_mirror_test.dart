import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapdefog/app/app_scope.dart';
import 'package:mapdefog/data/database.dart';
import 'package:mapdefog/data/models.dart';
import 'package:mapdefog/data/settings_store.dart';
import 'package:mapdefog/domain/fog.dart';
import 'package:mapdefog/explore/explorer.dart';
import 'package:mapdefog/explore/location_feed.dart';
import 'package:mapdefog/explore/walk_messages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

/// The app's side of a walk tracked by the service: whatever the
/// service sends must reach the screens' data sources.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  TestWidgetsFlutterBinding.ensureInitialized();

  late FogDatabase db;
  late AppContainer app;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = FogDatabase.forTesting(NativeDatabase.memory());
    final settings = SettingsStore(await SharedPreferences.getInstance());
    final explorer = Explorer(db: db, settings: settings, fog: FogStore());
    await explorer.load();
    app = AppContainer(
      db: db,
      settings: settings,
      fog: explorer.fog,
      explorer: explorer,
      feed: LocationFeed(explorer),
    );
  });
  tearDown(() async {
    app.explorer.dispose();
    await db.close();
  });

  Future<void> receive(String type, [Map<String, Object?> body = const {}]) =>
      app.handleServiceMessage(WalkMessage.of(type, body));

  test('live state, cells and events are mirrored', () async {
    final events = <GameEvent>[];
    final sub = app.explorer.events.listen(events.add);
    addTearDown(sub.cancel);

    await receive(WalkMessage.live, {
      'live': WalkCodec.live(const Live(walk: WalkRow(id: 4, start: 1, end: 2, cells: 9))),
    });
    await receive(WalkMessage.cells, {
      'ids': [5, 6, 7],
    });
    await receive(WalkMessage.event, {'e': WalkCodec.event(BeaconEvent())});
    await pumpEventQueue();

    expect(app.explorer.liveValue.walk!.cells, 9);
    expect(app.fog.size, 3);
    expect(events.single, isA<BeaconEvent>());
  });

  test("the service's writes refresh the app's queries", () async {
    final days = <List<DayRow>>[];
    final sub = db.observeDays().listen(days.add);
    addTearDown(sub.cancel);
    await pumpEventQueue();
    expect(days.last, isEmpty);

    // A write the app's connection does not know about, as from the service.
    await db.customStatement('INSERT INTO days (day, cells) VALUES (100, 3)');
    await pumpEventQueue();
    expect(days.last, isEmpty);

    await receive(WalkMessage.tables, {
      'names': ['days'],
    });
    await pumpEventQueue();
    expect(days.last.single.cells, 3);
  });

  test('settings the service wrote are picked up', () async {
    var ticks = 0;
    app.settingsTick.addListener(() => ticks++);
    await SharedPreferencesStorePlatform.instance.setValue('Bool', 'flutter.walking', true);

    await receive(WalkMessage.settings);

    expect(app.settings.now().walking, isTrue);
    expect(ticks, 1);
  });

  test('unknown messages are ignored', () async {
    await app.handleServiceMessage('stop_walk');
    await receive('nonsense');
  });
}
