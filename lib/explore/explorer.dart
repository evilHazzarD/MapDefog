import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:mapdefog/data/database.dart';
import 'package:mapdefog/data/models.dart';
import 'package:mapdefog/data/settings_store.dart';
import 'package:mapdefog/domain/caches.dart';
import 'package:mapdefog/domain/fog.dart';
import 'package:mapdefog/domain/progress.dart';
import 'package:mapdefog/domain/quests.dart';
import 'package:mapdefog/domain/rarity.dart';
import 'package:mapdefog/domain/relics.dart';
import 'package:mapdefog/explore/fix.dart';
import 'package:mapdefog/explore/track.dart';
import 'package:mapdefog/geo/grid.dart';
import 'package:mapdefog/notify/alarms.dart';
import 'package:mapdefog/util/days.dart';

class Live {
  const Live({this.fix, this.walk, this.trail = const [], this.tooFast = false});

  final Fix? fix;
  final WalkRow? walk;
  final List<(double, double)> trail;
  final bool tooFast;

  Live copyWith({Fix? fix, WalkRow? walk, List<(double, double)>? trail, bool? tooFast}) => Live(
    fix: fix ?? this.fix,
    walk: walk ?? this.walk,
    trail: trail ?? this.trail,
    tooFast: tooFast ?? this.tooFast,
  );
}

sealed class GameEvent {}

class OpenedEvent extends GameEvent {
  OpenedEvent(this.find);
  final FindRow find;
}

class NewSectorEvent extends GameEvent {
  NewSectorEvent(this.sector);
  final int sector;
}

class MilestoneEvent extends GameEvent {
  MilestoneEvent(this.sector, this.share, this.coins);
  final int sector;
  final double share;
  final int coins;
}

class BeaconEvent extends GameEvent {}

class NearEvent extends GameEvent {
  NearEvent(this.cache, this.meters);
  final Cache cache;
  final int meters;
}

class Explorer {
  Explorer({required this.db, required this.settings, required this.fog});

  final FogDatabase db;
  final SettingsStore settings;
  final FogStore fog;

  static const revealM = 40.0;
  static const maxSpeed = 8.5;
  static const fillStep = 8.0;
  static const walkGapMs = 20 * 60 * 1000;
  static const nearM = 150.0;

  final _live = StreamController<Live>.broadcast();
  final _events = StreamController<GameEvent>.broadcast();
  final _revealed = StreamController<List<int>>.broadcast();
  Live _current = const Live();
  final _track = Track();
  WalkRow? _walk;
  int _routed = -1;
  var _opened = <String>{};
  int _openedWeek = -1 << 62;
  final _ownedRelics = <String>{};
  final _grantedSectors = <String>{};
  final _nearNotified = <String>{};
  int _lastSaved = 0;
  int _upkeepDay = -1 << 62;
  int _simulatingUntil = 0;
  final _queue = StreamController<Fix>();
  StreamSubscription<void>? _queueSub;
  bool _ready = false;
  Completer<void>? _readyWait;

  Stream<Live> get live => _live.stream;
  Live get liveValue => _current;
  Stream<GameEvent> get events => _events.stream;

  /// Cell ids newly revealed by a fix (already stored and added to [fog]).
  Stream<List<int>> get revealed => _revealed.stream;

  /// Opened cache keys for the current week (for map gems).
  Set<String> get openedKeys => Set.unmodifiable(_opened);

  Future<void> reloadCells() async {
    final ids = await db.cellIds();
    for (final id in ids) {
      fog.add(id);
    }
    fog.changed();
  }

  /// Full state reload after backup import (cells, finds, sectors, walk).
  Future<void> reloadAll() async {
    _opened.clear();
    _openedWeek = -1 << 62;
    _ownedRelics.clear();
    _grantedSectors.clear();
    _nearNotified.clear();
    _walk = null;
    _routed = -1;
    fog.clear();
    await reloadCells();
    _walk = await db.lastWalk();
    for (final f in await db.allFinds()) {
      if (f.relic.isNotEmpty) _ownedRelics.add(f.relic);
    }
    for (final e in await db.allLedger()) {
      if (e.ref.startsWith('sec:')) _grantedSectors.add(e.ref);
    }
    final s = settings.now();
    if (s.lastLat != 0 || s.lastLon != 0) {
      // A new Live, not copyWith: copyWith cannot clear a walk to null.
      _emit(
        Live(
          fix: Fix(lat: s.lastLat, lon: s.lastLon, accuracy: 9999, time: 0),
          walk: _walk,
        ),
      );
    } else {
      _emit(Live(fix: _current.fix, walk: _walk));
    }
  }

  Future<void> load() async {
    _readyWait = Completer<void>();
    await reloadCells();
    _walk = await db.lastWalk();
    for (final f in await db.allFinds()) {
      if (f.relic.isNotEmpty) _ownedRelics.add(f.relic);
    }
    for (final e in await db.allLedger()) {
      if (e.ref.startsWith('sec:')) _grantedSectors.add(e.ref);
    }
    final s = settings.now();
    if (s.lastLat != 0 || s.lastLon != 0) {
      _emit(
        _current.copyWith(
          fix: Fix(lat: s.lastLat, lon: s.lastLon, accuracy: 9999, time: 0),
        ),
      );
    }
    _ready = true;
    _readyWait!.complete();
    // asyncMap serializes: next fix waits until prior _process completes.
    _queueSub = _queue.stream
        .asyncMap(_process)
        .listen(
          (_) {},
          // One failed fix (say, a busy database) must not stop the walk.
          onError: (Object e, StackTrace st) => debugPrint('Explorer: fix failed: $e\n$st'),
        );
    await _upkeep(todayEpochDay());
  }

  Future<void> awaitReady() async {
    if (_ready) return;
    await (_readyWait?.future ?? Future.value());
  }

  void submit(Fix fix) {
    // A simulated walk can still be submitting after dispose().
    if (!_queue.isClosed) _queue.add(fix);
  }

  // While the Android walk service tracks, its own Explorer does the work and
  // the app's one only mirrors the results, so the screens read it as usual.

  /// Shows the service's live state.
  void mirrorLive(Live live) {
    if (live.walk != null) _walk = live.walk;
    _emit(live);
  }

  /// Adds cells the service revealed (and already stored) to [fog].
  void mirrorCells(List<int> ids) {
    for (final id in ids) {
      fog.add(id);
    }
    fog.changed();
  }

  /// Passes on an event from the service, keeping finds in step.
  void mirrorEvent(GameEvent e) {
    if (e is OpenedEvent) {
      _opened.add(e.find.key);
      if (e.find.relic.isNotEmpty) _ownedRelics.add(e.find.relic);
    }
    _events.add(e);
  }

  void _emit(Live live) {
    _current = live;
    if (!_live.isClosed) _live.add(live);
  }

  Future<void> _upkeep(int today) async {
    if (_upkeepDay == today) return;
    _upkeepDay = today;
    final days = await db.allDays();
    if (Streaks.toShield(days, settings.now().shielded, settings.now().shields, today).isEmpty) {
      return;
    }
    // Decide from the values update() re-reads: the app and the walk service
    // both run upkeep, and a stale read would spend shields twice.
    await settings.update((it) {
      final cover = Streaks.toShield(days, it.shielded, it.shields, today);
      return it.copyWith(shields: it.shields - cover.length, shielded: {...it.shielded, ...cover});
    });
  }

  Future<void> _process(Fix f) async {
    await awaitReady();
    if (!f.simulated && DateTime.now().millisecondsSinceEpoch < _simulatingUntil) {
      return;
    }
    final prev = _current.fix;
    if (prev != null && prev.time > 0 && f.time <= prev.time && !f.simulated) {
      return;
    }
    final step = _track.add(f);
    if (step == null) {
      if (!_track.hasGps(f.time) && f.accuracy < 200) {
        _emit(_current.copyWith(fix: f));
      }
      return;
    }
    _emit(
      _current.copyWith(
        fix: f.copyWith(lat: step.lat, lon: step.lon),
        tooFast: step.fast,
      ),
    );
    if (step.fast) return;

    final day = epochDay(DateTime.fromMillisecondsSinceEpoch(f.time));
    await _upkeep(day);
    final s = settings.now();
    final radius = revealM * (s.lanternUntil > f.time ? Shop.lanternFactor : 1.0);

    final points = <(double, double)>[];
    final from = step.from;
    final moved = step.meters;
    if (from == null) {
      points.add((step.lat, step.lon));
    } else {
      final steps = math.max(1, (moved / fillStep).ceil());
      for (var i = 1; i <= steps; i++) {
        final t = i / steps;
        points.add((from.$1 + (step.lat - from.$1) * t, from.$2 + (step.lon - from.$2) * t));
      }
    }

    final fresh = <int>[];
    final newSectors = <int>{};
    final touched = <int>{};
    for (final p in points) {
      Grid.around(p.$1, p.$2, radius, (k) {
        final sector = Grid.sector(k);
        final wasNew = fog.count(sector, Grid.sectorZ) == 0;
        if (fog.add(k)) {
          fresh.add(k);
          touched.add(sector);
          if (wasNew) newSectors.add(sector);
        }
      });
    }

    if (fresh.isNotEmpty) {
      await db.insertCells(fresh.map((k) => CellRow(k, f.time)).toList());
    }

    final week = Caches.week(day);
    if (week != _openedWeek) {
      _opened = (await db.findKeys('c:$week:')).toSet();
      _openedWeek = week;
    }
    var foundHere = 0;
    var rareHere = 0;
    final reach = Caches.openM + math.min(f.accuracy, 20.0);
    for (final c in Caches.near(step.lat, step.lon, nearM + moved, week)) {
      if (_opened.contains(c.key)) continue;
      final m = points.map((p) => Grid.distance(p.$1, p.$2, c.lat, c.lon)).reduce(math.min);
      if (m <= reach) {
        final loot = Caches.open(c, _ownedRelics);
        final find = FindRow(
          key: c.key,
          at: f.time,
          rarity: c.rarity.index,
          relic: loot.relic?.id ?? '',
          duplicate: loot.duplicate,
          coins: loot.coins,
          xp: loot.xp,
          lat: c.lat,
          lon: c.lon,
        );
        if (await db.insertFind(find)) {
          _opened.add(c.key);
          if (loot.relic != null) _ownedRelics.add(loot.relic!.id);
          foundHere++;
          if (c.rarity.index >= Rarity.rare.index) rareHere++;
          _events.add(OpenedEvent(find));
          await _grantSets(f.time);
        }
      } else if (!_nearNotified.contains(c.key)) {
        _nearNotified.add(c.key);
        _events.add(NearEvent(c, m.toInt()));
      }
    }

    var beacon = false;
    var b = s.beacon;
    if (b.day != day) {
      final level = Levels.level(Wallet.xp(fog.size, await db.allFinds(), await db.allLedger()));
      final placed = Beacons.place(
        day,
        0,
        step.lat,
        step.lon,
        level,
        (la, lo) => fog.exploredAround(la, lo, 120),
      );
      await settings.update((it) => it.copyWith(beacon: BeaconSpot(day, placed.$1, placed.$2)));
      b = BeaconSpot(day, placed.$1, placed.$2);
    }
    final today = await db.day(day) ?? DayRow(day: day);
    final toBeacon = points.map((p) => Grid.distance(p.$1, p.$2, b.lat, b.lon)).reduce(math.min);
    if (!today.beacon && toBeacon <= Beacons.reachM + math.min(f.accuracy, 20.0)) {
      beacon = true;
      await db.grant(EntryRow(ref: 'q:$day:2', at: f.time, coins: Beacons.coins, xp: Beacons.xp));
      _events.add(BeaconEvent());
    }

    for (final sector in touched) {
      final share = fog.sectorShare(sector);
      for (final m in Sectors.milestones) {
        if (share < m.$1) break;
        final ref = Sectors.ref(sector, m.$1);
        if (_grantedSectors.contains(ref)) continue;
        _grantedSectors.add(ref);
        if (await db.grant(EntryRow(ref: ref, at: f.time, coins: m.$2, xp: m.$3))) {
          _events.add(MilestoneEvent(sector, m.$1, m.$2));
        }
      }
    }
    for (final sct in newSectors) {
      _events.add(NewSectorEvent(sct));
    }

    final hour = DateTime.fromMillisecondsSinceEpoch(f.time).hour;
    if (fresh.isNotEmpty || moved > 0 || foundHere > 0 || beacon) {
      final wasActive = Streaks.active(today);
      final updated = today.copyWith(
        cells: today.cells + fresh.length,
        meters: today.meters + moved,
        caches: today.caches + foundHere,
        rare: today.rare + rareHere,
        beacon: today.beacon || beacon,
        night: today.night + ((hour >= 22 || hour < 4) ? fresh.length : 0),
        dawn: today.dawn + ((hour >= 4 && hour <= 6) ? fresh.length : 0),
      );
      await db.upsertDay(updated);
      if (!wasActive && Streaks.active(updated)) {
        await Alarms.onStreakCompleted(settings.now());
      }
      var w = _walk;
      if (w == null || f.time - w.end > walkGapMs) {
        w = WalkRow(start: f.time, end: f.time, lat: step.lat, lon: step.lon);
        final id = await db.insertWalk(w);
        w = w.copyWith(id: id);
        _emit(_current.copyWith(trail: const []));
      }
      w = w.copyWith(
        end: f.time,
        meters: w.meters + moved,
        cells: w.cells + fresh.length,
        caches: w.caches + foundHere,
      );
      await db.upsertWalk(w);
      _walk = w;
      if (from != null) {
        final route = <WaypointRow>[];
        if (_routed != w.id) {
          route.add(WaypointRow(walk: w.id, at: f.time, lat: from.$1, lon: from.$2));
        }
        route.add(WaypointRow(walk: w.id, at: f.time, lat: step.lat, lon: step.lon));
        await db.insertWaypoints(route);
        _routed = w.id;
      }
      if (from != null) {
        final trail = [
          ...(_current.trail.isEmpty ? [from] : _current.trail),
          ...points,
        ];
        _emit(
          _current.copyWith(
            walk: w,
            trail: trail.length > 4000 ? trail.sublist(trail.length - 4000) : trail,
          ),
        );
      } else {
        _emit(_current.copyWith(walk: w));
      }
    }
    if (fresh.isNotEmpty) {
      fog.changed();
      _revealed.add(fresh);
    }

    if (f.time - _lastSaved > 60000) {
      _lastSaved = f.time;
      await settings.update((it) => it.copyWith(lastLat: step.lat, lastLon: step.lon));
    }
  }

  Future<void> _grantSets(int at) async {
    for (final set in Relics.completeSets(_ownedRelics)) {
      final reward = Relics.setReward(set);
      await db.grant(EntryRow(ref: 'set:$set', at: at, coins: reward.$1, xp: reward.$2));
    }
  }

  Future<void> simulateTo(double lat, double lon) async {
    final from = _current.fix;
    if (from == null) return;
    final d = Grid.distance(from.lat, from.lon, lat, lon);
    final steps = math.max(1, (d / 8).toInt());
    _simulatingUntil = DateTime.now().millisecondsSinceEpoch + steps * 60 + 60000;
    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      submit(
        Fix(
          lat: from.lat + (lat - from.lat) * t,
          lon: from.lon + (lon - from.lon) * t,
          accuracy: 5,
          time: DateTime.now().millisecondsSinceEpoch,
          simulated: true,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 60));
    }
  }

  Future<bool> buy(String item, int price) async {
    final coins = Wallet.coins(await db.allFinds(), await db.allLedger());
    if (coins < price) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.grant(EntryRow(ref: 'buy:$item:$now', at: now, coins: -price, xp: 0));
    return true;
  }

  void dispose() {
    _queueSub?.cancel();
    _queue.close();
    _live.close();
    _events.close();
    _revealed.close();
  }
}
