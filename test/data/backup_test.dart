import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapdefog/data/backup.dart';
import 'package:mapdefog/data/database.dart';
import 'package:mapdefog/data/models.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late FogDatabase source;
  late FogDatabase target;

  setUp(() {
    source = FogDatabase.forTesting(NativeDatabase.memory());
    target = FogDatabase.forTesting(NativeDatabase.memory());
  });
  tearDown(() async {
    await source.close();
    await target.close();
  });

  test('an exported atlas imports into an empty one intact', () async {
    await source.insertCells(const [CellRow(11, 1), CellRow(12, 1)]);
    await source.upsertDay(const DayRow(day: 20000, cells: 2, meters: 850));
    await source.insertFind(
      const FindRow(
        key: 'cache:x',
        at: 5,
        rarity: 2,
        relic: 'compass',
        coins: 40,
        xp: 60,
        lat: 50.08,
        lon: 14.42,
      ),
    );
    await source.grant(const EntryRow(ref: 'deed:a', at: 6, coins: 10));
    final walk = await source.insertWalk(
      const WalkRow(start: 1000, end: 2000, meters: 850, cells: 2),
    );
    await source.insertWaypoints([
      WaypointRow(walk: walk, at: 1000, lat: 50.08, lon: 14.42),
      WaypointRow(walk: walk, at: 2000, lat: 50.09, lon: 14.43),
    ]);

    await Backup.importJson(target, await Backup.exportJson(source));

    expect(await target.cellIds(), unorderedEquals([11, 12]));
    expect((await target.day(20000))!.meters, 850);
    expect((await target.allFinds()).single.relic, 'compass');
    expect((await target.allLedger()).single.ref, 'deed:a');
    final walks = await target.allWalks();
    expect(walks.single.meters, 850);
    expect(await target.waypointsFor(walks.single.id), hasLength(2));
  });

  test('a file from another app is rejected', () {
    expect(Backup.importJson(target, '{"app": "something-else"}'), throwsFormatException);
  });

  test('a malformed backup is rejected and writes nothing', () async {
    const broken = '{"app": "fogwalk", "cells": [1, 2], "days": ["oops"]}';
    await expectLater(Backup.importJson(target, broken), throwsFormatException);
    expect(await target.cellCount(), 0);
  });

  test('text that is not JSON is rejected', () {
    expect(Backup.importJson(target, 'not json'), throwsFormatException);
  });
}
