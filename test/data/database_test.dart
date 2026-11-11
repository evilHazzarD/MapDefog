import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapdefog/data/database.dart';
import 'package:mapdefog/data/models.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late FogDatabase db;

  setUp(() => db = FogDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  FindRow find(String key) =>
      FindRow(key: key, at: 1, rarity: 0, coins: 5, xp: 10, lat: 50, lon: 14);

  test('cells are stored once however often they are revealed', () async {
    await db.insertCells(const [CellRow(1, 10), CellRow(2, 10)]);
    await db.insertCells(const [CellRow(2, 20), CellRow(3, 20)]);

    expect(await db.cellCount(), 3);
    expect(await db.cellIds(), unorderedEquals([1, 2, 3]));
  });

  test('upsertDay replaces the stats of an existing day', () async {
    await db.upsertDay(const DayRow(day: 100, cells: 4, meters: 120));
    await db.upsertDay(const DayRow(day: 100, cells: 9, meters: 300));
    await db.upsertDay(const DayRow(day: 99));

    final days = await db.allDays();
    expect(days.map((d) => d.day), [99, 100]);
    expect((await db.day(100))!.cells, 9);
    expect((await db.day(100))!.meters, 300);
  });

  test('a find can only be claimed once', () async {
    expect(await db.insertFind(find('cache:a')), isTrue);
    expect(await db.insertFind(find('cache:b')), isTrue);
    expect(await db.insertFind(find('cache:a')), isFalse);
    expect(await db.allFinds(), hasLength(2));
  });

  test('a ledger entry can only be granted once', () async {
    const entry = EntryRow(ref: 'deed:first-steps', at: 1, coins: 50);
    expect(await db.grant(entry), isTrue);
    expect(await db.grant(entry), isFalse);
    expect(await db.allLedger(), hasLength(1));
  });

  test('waypoints belong to their walk', () async {
    final a = await db.insertWalk(const WalkRow(start: 0, end: 60));
    final b = await db.insertWalk(const WalkRow(start: 100, end: 160));
    await db.insertWaypoints([
      WaypointRow(walk: a, at: 1, lat: 50, lon: 14),
      WaypointRow(walk: b, at: 2, lat: 51, lon: 15),
      WaypointRow(walk: a, at: 3, lat: 50.1, lon: 14.1),
    ]);

    expect((await db.waypointsFor(a)).map((p) => p.at), [1, 3]);
    expect(await db.walkAt(100), b);
  });

  test('two connections to one file see each other\'s writes', () async {
    final dir = await Directory.systemTemp.createTemp('fogdb');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/fog.db');
    FogDatabase open() => FogDatabase.forTesting(NativeDatabase(file, setup: configureConnection));
    final app = open();
    final service = open();
    addTearDown(app.close);
    addTearDown(service.close);

    final mode = await app.customSelect('PRAGMA journal_mode').getSingle();
    expect(mode.read<String>('journal_mode'), 'wal');
    final wait = await app.customSelect('PRAGMA busy_timeout').getSingle();
    expect(wait.data.values.single, 5000);

    await service.insertCells(const [CellRow(1, 1)]);
    await Future.wait([
      app.upsertDay(const DayRow(day: 5, cells: 1)),
      service.insertCells(const [CellRow(2, 2)]),
    ]);
    expect(await app.cellCount(), 2);
    expect((await service.day(5))!.cells, 1);
  });

  test('a database stamped v2 by an older build opens as v1 with its data', () async {
    final dir = await Directory.systemTemp.createTemp('fogdb');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/fog.db');

    final old = FogDatabase.forTesting(NativeDatabase(file));
    await old.insertCells(const [CellRow(1, 1), CellRow(2, 1)]);
    await old.customStatement('PRAGMA user_version = 2');
    await old.close();

    final reopened = FogDatabase.forTesting(NativeDatabase(file));
    addTearDown(reopened.close);
    expect(await reopened.cellCount(), 2);
    final version = await reopened.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 1);
  });
}
