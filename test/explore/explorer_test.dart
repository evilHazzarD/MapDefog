import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapdefog/data/database.dart';
import 'package:mapdefog/data/models.dart';
import 'package:mapdefog/data/settings_store.dart';
import 'package:mapdefog/domain/fog.dart';
import 'package:mapdefog/explore/explorer.dart';
import 'package:mapdefog/explore/fix.dart';
import 'package:mapdefog/util/days.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  TestWidgetsFlutterBinding.ensureInitialized();

  late FogDatabase db;
  late SettingsStore settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = FogDatabase.forTesting(NativeDatabase.memory());
    settings = SettingsStore(await SharedPreferences.getInstance());
  });
  tearDown(() => db.close());

  Future<Explorer> explorer() async {
    final e = Explorer(db: db, settings: settings, fog: FogStore());
    await e.load();
    addTearDown(e.dispose);
    return e;
  }

  /// A walk north at 1.4 m/s, one fix a second.
  List<Fix> walkNorth(int seconds) {
    final start = DateTime.now().millisecondsSinceEpoch - seconds * 1000;
    return [
      for (var i = 0; i < seconds; i++)
        Fix(
          lat: 50.08 + i * 1.4 / 111320,
          lon: 14.42,
          accuracy: 5,
          time: start + i * 1000,
          speed: 1.4,
        ),
    ];
  }

  test('a walk reveals, stores and reports the same cells', () async {
    final e = await explorer();
    final revealed = <int>[];
    final sub = e.revealed.listen(revealed.addAll);
    addTearDown(sub.cancel);

    walkNorth(90).forEach(e.submit);
    await pumpEventQueue(times: 2000);

    expect(revealed, isNotEmpty);
    expect(revealed.toSet(), hasLength(revealed.length));
    expect(await db.cellIds(), unorderedEquals(revealed));
    expect(e.fog.size, revealed.length);
  });

  test('the app mirrors what the service explorer produced', () async {
    final app = await explorer();
    final events = <GameEvent>[];
    final sub = app.events.listen(events.add);
    addTearDown(sub.cancel);
    var fogChanges = 0;
    app.fog.addListener(() => fogChanges++);

    app.mirrorCells([101, 102]);
    const find = FindRow(
      key: 'c:1:x',
      at: 1,
      rarity: 1,
      relic: 'compass',
      coins: 1,
      xp: 1,
      lat: 0,
      lon: 0,
    );
    app.mirrorEvent(OpenedEvent(find));
    const live = Live(walk: WalkRow(id: 3, start: 1, end: 2));
    app.mirrorLive(live);
    await pumpEventQueue();

    expect(app.fog.contains(101) && app.fog.contains(102), isTrue);
    expect(fogChanges, 1);
    expect(app.openedKeys, contains('c:1:x'));
    expect(events.single, isA<OpenedEvent>());
    expect(app.liveValue.walk!.id, 3);
  });

  test('reloading after an import clears a walk that no longer exists', () async {
    final e = await explorer();
    e.mirrorLive(const Live(walk: WalkRow(id: 9, start: 1, end: 2)));

    await e.reloadAll();

    expect(e.liveValue.walk, isNull);
  });

  test('a shield is not spent twice when the other isolate already used it', () async {
    final today = todayEpochDay();
    // Walked two days ago, missed yesterday: one shield covers the gap.
    await db.upsertDay(DayRow(day: today - 2, cells: 500, meters: 5000));
    await settings.update((s) => s.copyWith(shields: 1));
    settings.now(); // this isolate's cache: 1 shield, nothing shielded

    // Meanwhile the other isolate spent it on yesterday.
    final store = SharedPreferencesStorePlatform.instance;
    await store.setValue('Int', 'flutter.shields', 0);
    await store.setValue('StringList', 'flutter.shielded', ['${today - 1}']);

    await explorer(); // load() runs the daily upkeep

    final s = settings.now();
    expect(s.shields, 0);
    expect(s.shielded, {today - 1});
  });
}
