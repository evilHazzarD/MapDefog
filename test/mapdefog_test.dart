import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapdefog/data/models.dart';
import 'package:mapdefog/data/settings_store.dart';
import 'package:mapdefog/domain/caches.dart';
import 'package:mapdefog/domain/fog.dart';
import 'package:mapdefog/domain/progress.dart';
import 'package:mapdefog/domain/quests.dart';
import 'package:mapdefog/domain/relics.dart';
import 'package:mapdefog/explore/fix.dart';
import 'package:mapdefog/explore/track.dart';
import 'package:mapdefog/geo/grid.dart';
import 'package:mapdefog/geo/long_set.dart';
import 'package:mapdefog/l10n/app_localizations.dart';
import 'package:mapdefog/l10n/game_text.dart';
import 'package:mapdefog/l10n/locale_resolve.dart';

final contentEn = lookupAppLocalizations(const Locale('en'));
final contentRu = lookupAppLocalizations(const Locale('ru'));
final contentUk = lookupAppLocalizations(const Locale('uk'));

void main() {
  test('resolveAppLocale honors language preference', () {
    expect(resolveAppLocale(const Settings(language: LanguagePref.en)).languageCode, 'en');
    expect(resolveAppLocale(const Settings(language: LanguagePref.ru)).languageCode, 'ru');
    expect(resolveAppLocale(const Settings(language: LanguagePref.uk)).languageCode, 'uk');
    final system = resolveAppLocale(const Settings(language: LanguagePref.system));
    expect(
      ['en', 'ru', 'uk'].contains(system.languageCode) || system.languageCode.isNotEmpty,
      isTrue,
    );
  });

  test('content chrome switches with locale', () {
    expect(contentUk.localeName, 'uk');
    expect(contentEn.tabMap, 'Map');
    expect(contentRu.tabMap, 'Карта');
    expect(contentUk.tabMap, 'Карта');
    expect(contentEn.cancel, 'Cancel');
    expect(contentRu.cancel, 'Отмена');
    expect(contentUk.cancel, 'Скасувати');
    expect(contentEn.notifyChestNearby, 'A chest nearby');
    expect(contentRu.notifyChestNearby, isNot(contentEn.notifyChestNearby));
    expect(contentUk.notifyChestNearby, isNot(contentEn.notifyChestNearby));
    expect(contentUk.languageUkrainian, 'Українська');
  });

  test('counts read naturally in every language', () {
    expect(contentEn.daysLeft(1), '1 day left');
    expect(contentEn.daysLeft(3), '3 days left');
    expect(contentEn.activeDays(1), '1 active day');
    expect(contentEn.exploreToSave(1), 'Explore 1 cell to save today');
    expect(contentEn.buyCost(1, 5), 'Cost 1 coin. You have 5.');
    expect(contentRu.badgeRelic(21), 'Соберите 21 разную реликвию');
    expect(contentRu.badgeRelic(3), 'Соберите 3 разные реликвии');
    expect(contentRu.badgeRelic(12), 'Соберите 12 разных реликвий');
    expect(contentRu.badgeSector(21), 'Побывайте в 21 земле');
    expect(contentRu.badgeBeacon(21), 'Дойдите до 21 святилища');
    expect(contentRu.badgeRare(22), 'Откройте 22 редких сундука или лучше');
    expect(contentRu.notifyStreakTitle(21), 'Серия из 21 дня под угрозой');
    expect(contentRu.notifyStreakTitle(5), 'Серия из 5 дней под угрозой');
    expect(contentRu.notifyWalkStats(2, '1 км'), '2 клетки · 1 км');
    expect(contentUk.badgeRelic(21), 'Зберіть 21 різну реліквію');
    expect(contentUk.badgeRare(2), 'Відкрийте 2 рідкісні скрині або кращі');
    expect(contentUk.notifyStreakTitle(5), 'Серія з 5 днів під загрозою');
  });

  test('gridRoundTrips', () {
    final k = Grid.cell(55.7558, 37.6173);
    expect(Grid.centerLat(k), closeTo(55.7558, 0.001));
    expect(Grid.centerLon(k), closeTo(37.6173, 0.001));
    expect(Grid.cellMeters(55.75), closeTo(21.6, 0.5));
    expect(Grid.sector(k), Grid.key(Grid.xOf(k) >> 6, Grid.yOf(k) >> 6));
  });

  test('revealCircleCoversTheRadius', () {
    var n = 0;
    Grid.around(55.75, 37.6, 40.0, (_) => n++);
    expect(n, inInclusiveRange(8, 14));
  });

  test('distanceAndOffsetAgree', () {
    final p = Grid.offset(55.75, 37.6, 1000.0, 90.0);
    expect(Grid.distance(55.75, 37.6, p.$1, p.$2), closeTo(1000.0, 1.0));
    expect(Grid.bearing(55.75, 37.6, p.$1, p.$2), closeTo(90.0, 0.5));
  });

  test('longSetBehavesLikeASet', () {
    final s = LongSet(4);
    final ref = <int>{};
    final rnd = math.Random(1);
    for (var i = 0; i < 20000; i++) {
      final v = (rnd.nextInt(5000) << 32) | rnd.nextInt(5000);
      expect(s.add(v), !ref.contains(v));
      ref.add(v);
    }
    expect(s.size, ref.length);
    for (final it in ref) {
      expect(s.contains(it), isTrue);
    }
    final m = LongIntMap();
    m.increment(7);
    m.increment(7);
    expect(m[7], 2);
    expect(m[8], 0);
  });

  test('fogCountsCoarserLevels', () {
    final fog = FogStore();
    Grid.around(55.75, 37.6, 40.0, fog.add);
    final k = Grid.cell(55.75, 37.6);
    expect(fog.count(Grid.sector(k), Grid.sectorZ), fog.size);
    expect(fog.add(k), isFalse);
    expect(fog.areaM2 > 4000, isTrue);
  });

  test('cachesAreStableWithinAWeekAndChangeAcrossWeeks', () {
    final a = Caches.inTile(39000, 20000, 2900);
    expect(Caches.inTile(39000, 20000, 2900), a);
    final total = List.generate(
      50,
      (i) => Caches.inTile(39000 + i, 20000, 2900).length,
    ).fold<int>(0, (s, n) => s + n);
    expect(total, inInclusiveRange(40, 90));
    final weeks = List.generate(10, (i) => Caches.inTile(39000, 20000, 2900 + i));
    expect(weeks.toSet().length > 3, isTrue);
    const monday = 20738;
    expect(Caches.week(monday), Caches.week(monday + 6));
    expect(Caches.week(monday), isNot(Caches.week(monday + 7)));
  });

  test('levelsAreMonotonic', () {
    expect(Levels.level(0), 1);
    expect(Levels.level(120), 2);
    var prev = 0;
    for (var l = 1; l <= 60; l++) {
      expect(Levels.start(l + 1) - Levels.start(l), Levels.need(l));
      expect(Levels.start(l) >= prev, isTrue);
      prev = Levels.start(l);
    }
  });

  test('streakCountsBackFromToday', () {
    const today = 20000;
    final days = [
      const DayRow(day: today - 3, cells: 40),
      const DayRow(day: today - 2, meters: 1500),
      const DayRow(day: today - 1, beacon: true),
    ];
    final s = Streaks.of(days, {}, today);
    expect(s.current, 3);
    expect(s.todayDone, isFalse);
    final gap = [const DayRow(day: today - 3, cells: 40), const DayRow(day: today - 2, cells: 40)];
    expect(Streaks.toShield(gap, {}, 1, today), [today - 1]);
    expect(Streaks.toShield(gap, {}, 0, today), isEmpty);
  });

  test('questsAreFixedForTheDay', () {
    expect(Quests.daily(20000, 5), Quests.daily(20000, 5));
    expect(Quests.daily(20000, 5).length, 3);
    expect(Relics.all.length, 36);
  });

  test('everyDeedHasWordsInAllLanguages', () {
    expect(Badges.all.length >= 150, isTrue);
    expect(Badges.all.map((b) => b.id).toSet().length, Badges.all.length);
    for (final c in [contentEn, contentRu, contentUk]) {
      for (final b in Badges.all) {
        expect(c.badgeTitle(b.id), isNot(b.id));
        expect(c.badgeText(b).isNotEmpty, isTrue);
      }
      for (final g in Badges.groups) {
        expect(c.groupName(g.id).isNotEmpty, isTrue);
      }
      for (final r in Relics.all) {
        expect(c.relicName(r.id), isNot(r.id));
      }
    }
    final bad = List.generate(
      500,
      (i) => contentRu.sectorName(i * 7919),
    ).any((n) => n.endsWith('ый Роща') || n.endsWith('ий Лощина'));
    expect(bad, isFalse);
    final ukNames = List.generate(500, (i) => contentUk.sectorName(i * 7919));
    expect(ukNames.any((n) => RegExp('[ыэъё]').hasMatch(n)), isFalse);
  });

  List<Fix> noisyWalk({
    required int seconds,
    required double speed,
    required double sigma,
    required bool spikes,
    required bool network,
    required bool doppler,
  }) {
    final rnd = _JavaRandom(7);
    const lat0 = 55.75;
    const lon0 = 37.6;
    final mLon = 111320.0 * math.cos(lat0 * math.pi / 180);
    var ex = 0.0;
    var ey = 0.0;
    final out = <Fix>[];
    for (var t = 0; t < seconds; t++) {
      ex = ex * 0.9 + rnd.nextGaussian() * sigma * 0.45;
      ey = ey * 0.9 + rnd.nextGaussian() * sigma * 0.45;
      var x = speed * t + ex + rnd.nextGaussian() * 2;
      var y = ey + rnd.nextGaussian() * 2;
      if (spikes && t % 37 == 0 && t > 0) {
        x += 70;
        y -= 50;
      }
      final time = 1000000 + t * 1000;
      out.add(
        Fix(
          lat: lat0 + y / 111320.0,
          lon: lon0 + x / mLon,
          accuracy: sigma * 1.5,
          time: time,
          speed: doppler ? speed : null,
        ),
      );
      if (network && t % 5 == 2) {
        out.add(
          Fix(
            lat: lat0 + (y + 35) / 111320.0,
            lon: lon0 + (x - 30) / mLon,
            accuracy: 30,
            time: time + 1,
            gps: false,
          ),
        );
      }
    }
    return out;
  }

  (double, int, int) run(List<Fix> fixes) {
    final track = Track();
    var meters = 0.0;
    var fast = 0;
    var steps = 0;
    for (final f in fixes) {
      final s = track.add(f);
      if (s == null) continue;
      meters += s.meters;
      if (s.fast) fast++;
      if (s.from != null) steps++;
    }
    return (meters, fast, steps);
  }

  test('noisyWalkCountsTheRealDistance', () {
    for (final doppler in [true, false]) {
      final r = run(
        noisyWalk(
          seconds: 720,
          speed: 1.4,
          sigma: 8.0,
          spikes: true,
          network: true,
          doppler: doppler,
        ),
      );
      expect(r.$1, inInclusiveRange(850.0, 1150.0), reason: 'doppler=$doppler');
      expect(r.$2, 0, reason: 'doppler=$doppler');
    }
  });

  test('standingStillAddsAlmostNothing', () {
    final r = run(
      noisyWalk(seconds: 900, speed: 0.0, sigma: 10.0, spikes: true, network: true, doppler: true),
    );
    expect(r.$1 < 60, isTrue);
    expect(r.$2, 0);
  });

  test('aCarIsTooFast', () {
    for (final doppler in [true, false]) {
      final r = run(
        noisyWalk(
          seconds: 120,
          speed: 14.0,
          sigma: 5.0,
          spikes: false,
          network: false,
          doppler: doppler,
        ),
      );
      expect(r.$2 > 60, isTrue, reason: 'doppler=$doppler');
      expect(r.$1 < 150, isTrue, reason: 'doppler=$doppler');
    }
  });
}

/// java.util.Random for parity with MapDefogTest noisy walks.
class _JavaRandom {
  _JavaRandom(int seed) : _seed = (seed ^ 0x5DEECE66D) & ((1 << 48) - 1);

  int _seed;
  double? _nextNextGaussian;

  int next(int bits) {
    _seed = (_seed * 0x5DEECE66D + 0xB) & ((1 << 48) - 1);
    return (_seed >> (48 - bits)).toSigned(32);
  }

  double nextDouble() {
    return ((next(26) << 27) + next(27)) / (1 << 53).toDouble();
  }

  double nextGaussian() {
    final cached = _nextNextGaussian;
    if (cached != null) {
      _nextNextGaussian = null;
      return cached;
    }
    double v1, v2, s;
    do {
      v1 = 2 * nextDouble() - 1;
      v2 = 2 * nextDouble() - 1;
      s = v1 * v1 + v2 * v2;
    } while (s >= 1 || s == 0);
    final multiplier = math.sqrt(-2 * math.log(s) / s);
    _nextNextGaussian = v2 * multiplier;
    return v1 * multiplier;
  }
}
