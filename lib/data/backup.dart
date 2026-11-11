import 'dart:convert';

import 'package:mapdefog/data/database.dart';
import 'package:mapdefog/data/models.dart';

/// JSON backup v1 — compatible with the Android Fogwalk exporter.
class Backup {
  Backup._();

  static Future<String> exportJson(FogDatabase db) async {
    final cellIds = await db.cellIds();
    final days = await db.allDays();
    final finds = await db.allFinds();
    final ledger = await db.allLedger();
    final walks = await db.allWalks();

    final walkObjs = <Map<String, dynamic>>[];
    for (final w in walks) {
      final pts = await db.waypointsFor(w.id);
      final route = <double>[];
      for (final p in pts) {
        route.add(double.parse(p.lat.toStringAsFixed(6)));
        route.add(double.parse(p.lon.toStringAsFixed(6)));
      }
      walkObjs.add({
        'start': w.start,
        'end': w.end,
        'meters': w.meters,
        'cells': w.cells,
        'caches': w.caches,
        'lat': w.lat,
        'lon': w.lon,
        'route': route,
      });
    }

    return const JsonEncoder.withIndent('  ').convert({
      'version': 1,
      'app': 'fogwalk',
      'cells': cellIds,
      'days': days
          .map(
            (d) => {
              'day': d.day,
              'cells': d.cells,
              'meters': d.meters,
              'caches': d.caches,
              'rare': d.rare,
              'beacon': d.beacon,
              'night': d.night,
              'dawn': d.dawn,
            },
          )
          .toList(),
      // Android export omits `seen` — omit for parity.
      'finds': finds
          .map(
            (f) => {
              'key': f.key,
              'at': f.at,
              'rarity': f.rarity,
              'relic': f.relic,
              'duplicate': f.duplicate,
              'coins': f.coins,
              'xp': f.xp,
              'lat': f.lat,
              'lon': f.lon,
            },
          )
          .toList(),
      'ledger': ledger
          .map((e) => {'ref': e.ref, 'at': e.at, 'coins': e.coins, 'xp': e.xp})
          .toList(),
      'walks': walkObjs,
    });
  }

  /// Merges a backup into [db] in one transaction.
  ///
  /// Throws [FormatException] when [json] is not a valid backup; nothing is
  /// written in that case.
  static Future<void> importJson(FogDatabase db, String json) async {
    try {
      await _import(db, json);
      // A field of the wrong type surfaces as a TypeError from a cast.
    } on TypeError catch (e) {
      throw FormatException('Malformed backup: $e');
    }
  }

  static Future<void> _import(FogDatabase db, String json) async {
    final root = jsonDecode(json) as Map<String, dynamic>;
    if (root['app'] != 'fogwalk') {
      throw const FormatException('Not a MapDefog backup');
    }
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction(() async {
      final cells = (root['cells'] as List?)?.cast<num>() ?? [];
      for (var i = 0; i < cells.length; i += 5000) {
        final chunk = cells.skip(i).take(5000).map((id) => CellRow(id.toInt(), now)).toList();
        await db.insertCells(chunk);
      }

      for (final d in (root['days'] as List? ?? [])) {
        final m = d as Map<String, dynamic>;
        final existing = await db.day(m['day'] as int);
        final incoming = DayRow(
          day: m['day'] as int,
          cells: m['cells'] as int? ?? 0,
          meters: (m['meters'] as num?)?.toDouble() ?? 0,
          caches: m['caches'] as int? ?? 0,
          rare: m['rare'] as int? ?? 0,
          beacon: m['beacon'] as bool? ?? false,
          night: m['night'] as int? ?? 0,
          dawn: m['dawn'] as int? ?? 0,
        );
        if (existing == null) {
          await db.upsertDay(incoming);
        } else {
          await db.upsertDay(
            DayRow(
              day: existing.day,
              cells: existing.cells > incoming.cells ? existing.cells : incoming.cells,
              meters: existing.meters > incoming.meters ? existing.meters : incoming.meters,
              caches: existing.caches > incoming.caches ? existing.caches : incoming.caches,
              rare: existing.rare > incoming.rare ? existing.rare : incoming.rare,
              beacon: existing.beacon || incoming.beacon,
              night: existing.night > incoming.night ? existing.night : incoming.night,
              dawn: existing.dawn > incoming.dawn ? existing.dawn : incoming.dawn,
            ),
          );
        }
      }

      for (final f in (root['finds'] as List? ?? [])) {
        final m = f as Map<String, dynamic>;
        await db.insertFind(
          FindRow(
            key: m['key'] as String,
            at: m['at'] as int,
            rarity: m['rarity'] as int,
            relic: m['relic'] as String? ?? '',
            duplicate: m['duplicate'] as bool? ?? false,
            coins: m['coins'] as int,
            xp: m['xp'] as int,
            lat: (m['lat'] as num).toDouble(),
            lon: (m['lon'] as num).toDouble(),
            seen: true,
          ),
        );
      }

      for (final e in (root['ledger'] as List? ?? [])) {
        final m = e as Map<String, dynamic>;
        await db.grant(
          EntryRow(
            ref: m['ref'] as String,
            at: m['at'] as int,
            coins: m['coins'] as int? ?? 0,
            xp: m['xp'] as int? ?? 0,
          ),
        );
      }

      for (final w in (root['walks'] as List? ?? [])) {
        final m = w as Map<String, dynamic>;
        final start = m['start'] as int;
        if (await db.walkAt(start) != null) continue;
        final end = m['end'] as int;
        final walk = WalkRow(
          start: start,
          end: end,
          meters: (m['meters'] as num?)?.toDouble() ?? 0,
          cells: m['cells'] as int? ?? 0,
          caches: m['caches'] as int? ?? 0,
          lat: (m['lat'] as num?)?.toDouble() ?? 0,
          lon: (m['lon'] as num?)?.toDouble() ?? 0,
        );
        final id = await db.insertWalk(walk);
        final route = (m['route'] as List?)?.cast<num>() ?? [];
        final n = route.length ~/ 2;
        if (n <= 0) continue;
        final points = <WaypointRow>[];
        for (var j = 0; j < n; j++) {
          final at = start + (end - start) * j ~/ (n <= 1 ? 1 : n - 1);
          points.add(
            WaypointRow(
              walk: id,
              at: at,
              lat: route[j * 2].toDouble(),
              lon: route[j * 2 + 1].toDouble(),
            ),
          );
        }
        await db.insertWaypoints(points);
      }
    });
  }
}
