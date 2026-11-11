import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mapdefog/data/models.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

part 'database.g.dart';

class Cells extends Table {
  IntColumn get id => integer()();
  IntColumn get at => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Days extends Table {
  IntColumn get day => integer()();
  IntColumn get cells => integer().withDefault(const Constant(0))();
  RealColumn get meters => real().withDefault(const Constant(0.0))();
  IntColumn get caches => integer().withDefault(const Constant(0))();
  IntColumn get rare => integer().withDefault(const Constant(0))();
  BoolColumn get beacon => boolean().withDefault(const Constant(false))();
  IntColumn get night => integer().withDefault(const Constant(0))();
  IntColumn get dawn => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {day};
}

class Walks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get start => integer()();
  IntColumn get end => integer()();
  RealColumn get meters => real().withDefault(const Constant(0.0))();
  IntColumn get cells => integer().withDefault(const Constant(0))();
  IntColumn get caches => integer().withDefault(const Constant(0))();
  RealColumn get lat => real().withDefault(const Constant(0.0))();
  RealColumn get lon => real().withDefault(const Constant(0.0))();
}

class Waypoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get walk => integer()();
  IntColumn get at => integer()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
}

class Finds extends Table {
  TextColumn get key => text()();
  IntColumn get at => integer()();
  IntColumn get rarity => integer()();
  TextColumn get relic => text().withDefault(const Constant(''))();
  BoolColumn get duplicate => boolean().withDefault(const Constant(false))();
  IntColumn get coins => integer()();
  IntColumn get xp => integer()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  BoolColumn get seen => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {key};
}

class Ledger extends Table {
  TextColumn get ref => text()();
  IntColumn get at => integer()();
  IntColumn get coins => integer().withDefault(const Constant(0))();
  IntColumn get xp => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {ref};
}

@DriftDatabase(tables: [Cells, Days, Walks, Waypoints, Finds, Ledger])
class FogDatabase extends _$FogDatabase {
  FogDatabase() : super(_open());

  FogDatabase.forTesting(super.e);

  /// When changing a table: bump this, run
  /// `dart run drift_dev make-migrations`, and add a step to [migration].
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Builds before the version was reset to 1 stamped this same schema
      // as 2; there is nothing to change, and drift re-stamps the file as 1.
      if (from == 2 && to == 1) return;
      // Run each step in order, e.g. `if (from < 2) await m.addColumn(..)`.
      // Snapshots of every version live in drift_schemas/.
      throw UnsupportedError('No migration from schema v$from to v$to');
    },
  );

  Future<List<int>> cellIds() async {
    final rows = await select(cells).get();
    return rows.map((r) => r.id).toList();
  }

  Future<void> insertCells(List<CellRow> list) async {
    await batch((b) {
      b.insertAll(
        cells,
        list.map((c) => CellsCompanion.insert(id: Value(c.id), at: c.at)),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  Future<int> cellCount() async {
    final c = countAll();
    final q = selectOnly(cells)..addColumns([c]);
    return (await q.getSingle()).read(c)!;
  }

  Stream<List<DayRow>> observeDays() => (select(
    days,
  )..orderBy([(t) => OrderingTerm.asc(t.day)])).watch().map((rows) => rows.map(_day).toList());

  Future<List<DayRow>> allDays() async {
    final rows = await (select(days)..orderBy([(t) => OrderingTerm.asc(t.day)])).get();
    return rows.map(_day).toList();
  }

  Future<DayRow?> day(int d) async {
    final row = await (select(days)..where((t) => t.day.equals(d))).getSingleOrNull();
    return row == null ? null : _day(row);
  }

  Future<void> upsertDay(DayRow d) async {
    await into(days).insertOnConflictUpdate(
      DaysCompanion.insert(
        day: Value(d.day),
        cells: Value(d.cells),
        meters: Value(d.meters),
        caches: Value(d.caches),
        rare: Value(d.rare),
        beacon: Value(d.beacon),
        night: Value(d.night),
        dawn: Value(d.dawn),
      ),
    );
  }

  Stream<List<WalkRow>> observeWalks() => (select(
    walks,
  )..orderBy([(t) => OrderingTerm.desc(t.start)])).watch().map((rows) => rows.map(_walk).toList());

  Future<WalkRow?> lastWalk() async {
    final rows =
        await (select(walks)
              ..orderBy([(t) => OrderingTerm.desc(t.start)])
              ..limit(1))
            .get();
    return rows.isEmpty ? null : _walk(rows.first);
  }

  Future<int> insertWalk(WalkRow w) => into(walks).insert(
    WalksCompanion.insert(
      start: w.start,
      end: w.end,
      meters: Value(w.meters),
      cells: Value(w.cells),
      caches: Value(w.caches),
      lat: Value(w.lat),
      lon: Value(w.lon),
    ),
  );

  Future<void> upsertWalk(WalkRow w) async {
    await into(walks).insertOnConflictUpdate(
      WalksCompanion(
        id: Value(w.id),
        start: Value(w.start),
        end: Value(w.end),
        meters: Value(w.meters),
        cells: Value(w.cells),
        caches: Value(w.caches),
        lat: Value(w.lat),
        lon: Value(w.lon),
      ),
    );
  }

  Stream<WalkRow?> observeWalk(int id) => (select(
    walks,
  )..where((t) => t.id.equals(id))).watchSingleOrNull().map((r) => r == null ? null : _walk(r));

  Future<List<WalkRow>> allWalks() async {
    final rows = await (select(walks)..orderBy([(t) => OrderingTerm.asc(t.start)])).get();
    return rows.map(_walk).toList();
  }

  Future<int?> walkAt(int start) async {
    final rows =
        await (select(walks)
              ..where((t) => t.start.equals(start))
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first.id;
  }

  Future<void> insertWaypoints(List<WaypointRow> points) async {
    await batch((b) {
      b.insertAll(
        waypoints,
        points.map(
          (p) => WaypointsCompanion.insert(walk: p.walk, at: p.at, lat: p.lat, lon: p.lon),
        ),
      );
    });
  }

  Future<List<WaypointRow>> waypointsFor(int walkId) async {
    final rows =
        await (select(waypoints)
              ..where((t) => t.walk.equals(walkId))
              ..orderBy([(t) => OrderingTerm.asc(t.at), (t) => OrderingTerm.asc(t.id)]))
            .get();
    return rows
        .map((r) => WaypointRow(id: r.id, walk: r.walk, at: r.at, lat: r.lat, lon: r.lon))
        .toList();
  }

  Stream<List<FindRow>> observeFinds() => (select(
    finds,
  )..orderBy([(t) => OrderingTerm.asc(t.at)])).watch().map((rows) => rows.map(_find).toList());

  Future<List<FindRow>> allFinds() async {
    final rows = await (select(finds)..orderBy([(t) => OrderingTerm.asc(t.at)])).get();
    return rows.map(_find).toList();
  }

  Future<List<String>> findKeys(String prefix) async {
    final rows = await (select(finds)..where((t) => t.key.like('$prefix%'))).get();
    return rows.map((r) => r.key).toList();
  }

  /// Returns false if already present.
  /// Returns false if [f] was already found.
  Future<bool> insertFind(FindRow f) async {
    // INSERT OR IGNORE leaves last_insert_rowid() untouched on a conflict, so
    // the returned row id cannot tell a new row from an ignored one.
    final row = await into(finds).insertReturningOrNull(
      FindsCompanion.insert(
        key: f.key,
        at: f.at,
        rarity: f.rarity,
        relic: Value(f.relic),
        duplicate: Value(f.duplicate),
        coins: f.coins,
        xp: f.xp,
        lat: f.lat,
        lon: f.lon,
        seen: Value(f.seen),
      ),
      mode: InsertMode.insertOrIgnore,
    );
    return row != null;
  }

  Future<void> markSeen(String key) async {
    await (update(
      finds,
    )..where((t) => t.key.equals(key))).write(const FindsCompanion(seen: Value(true)));
  }

  Stream<List<EntryRow>> observeLedger() => (select(
    ledger,
  )..orderBy([(t) => OrderingTerm.asc(t.at)])).watch().map((rows) => rows.map(_entry).toList());

  Future<List<EntryRow>> allLedger() async {
    final rows = await (select(ledger)..orderBy([(t) => OrderingTerm.asc(t.at)])).get();
    return rows.map(_entry).toList();
  }

  /// Returns false if already granted.
  Future<bool> grant(EntryRow e) async {
    final row = await into(ledger).insertReturningOrNull(
      LedgerCompanion.insert(ref: e.ref, at: e.at, coins: Value(e.coins), xp: Value(e.xp)),
      mode: InsertMode.insertOrIgnore,
    );
    return row != null;
  }

  DayRow _day(Day r) => DayRow(
    day: r.day,
    cells: r.cells,
    meters: r.meters,
    caches: r.caches,
    rare: r.rare,
    beacon: r.beacon,
    night: r.night,
    dawn: r.dawn,
  );

  WalkRow _walk(Walk r) => WalkRow(
    id: r.id,
    start: r.start,
    end: r.end,
    meters: r.meters,
    cells: r.cells,
    caches: r.caches,
    lat: r.lat,
    lon: r.lon,
  );

  FindRow _find(Find r) => FindRow(
    key: r.key,
    at: r.at,
    rarity: r.rarity,
    relic: r.relic,
    duplicate: r.duplicate,
    coins: r.coins,
    xp: r.xp,
    lat: r.lat,
    lon: r.lon,
    seen: r.seen,
  );

  EntryRow _entry(LedgerData r) => EntryRow(ref: r.ref, at: r.at, coins: r.coins, xp: r.xp);
}

/// The app and the Android walk service each open their own connection to
/// the same file. WAL lets one read while the other writes, and the busy
/// timeout makes a writer wait for the other's lock instead of failing.
void configureConnection(Database raw) => raw
  ..execute('PRAGMA journal_mode = WAL;')
  ..execute('PRAGMA busy_timeout = 5000;');

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'fogwalk.db'));
    return NativeDatabase.createInBackground(file, setup: configureConnection);
  });
}
