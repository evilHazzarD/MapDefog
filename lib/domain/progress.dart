import 'package:mapdefog/data/models.dart';

class Levels {
  Levels._();
  static int need(int level) => 120 + 60 * (level - 1);
  static int start(int level) => 120 * (level - 1) + 30 * (level - 1) * (level - 2);
  static int level(int xp) {
    var l = 1;
    while (xp >= start(l + 1)) {
      l++;
    }
    return l;
  }

  static const _rankFrom = [1, 4, 8, 12, 17, 23, 30, 40];
  static int rank(int level) {
    var i = 0;
    for (var j = 0; j < _rankFrom.length; j++) {
      if (level >= _rankFrom[j]) i = j;
    }
    return i;
  }

  static int reward(int level) => 40 + level * 10;
}

class Streaks {
  Streaks._();
  static const cells = 25;
  static const meters = 1000.0;

  static bool active(DayRow? d) =>
      d != null && (d.cells >= cells || d.meters >= meters || d.beacon);

  static Streak of(List<DayRow> days, Set<int> shielded, int today) {
    final on = {...days.where(active).map((d) => d.day), ...shielded};
    final todayDone = on.contains(today);
    var current = 0;
    var d = todayDone ? today : today - 1;
    while (on.contains(d)) {
      current++;
      d--;
    }
    var best = 0;
    var run = 0;
    var prev = -1 << 62;
    final sorted = on.toList()..sort();
    for (final x in sorted) {
      run = x == prev + 1 ? run + 1 : 1;
      if (run > best) best = run;
      prev = x;
    }
    return Streak(current, best > current ? best : current, todayDone);
  }

  static List<int> toShield(List<DayRow> days, Set<int> shielded, int shields, int today) {
    if (shields <= 0) return const [];
    final on = {...days.where(active).map((d) => d.day), ...shielded};
    final gap = <int>[];
    var d = today - 1;
    while (!on.contains(d) && gap.length <= shields) {
      gap.add(d);
      d--;
      if (today - d > 10) return const [];
    }
    if (gap.isNotEmpty && gap.length <= shields && on.contains(d)) return gap;
    return const [];
  }
}

class Streak {
  const Streak(this.current, this.best, this.todayDone);
  final int current;
  final int best;
  final bool todayDone;
}

class Facts {
  const Facts({
    required this.areaKm2,
    required this.km,
    required this.cells,
    required this.caches,
    required this.rare,
    required this.epic,
    required this.legendary,
    required this.relics,
    required this.sets,
    required this.sectors,
    required this.charted,
    required this.half,
    required this.bestStreak,
    required this.beacons,
    required this.quests,
    required this.weeklies,
    required this.activeDays,
    required this.bestDayCells,
    required this.bestDayKm,
    required this.night,
    required this.dawn,
    required this.level,
    required this.walks,
    required this.gold,
    required this.styles,
  });

  final double areaKm2;
  final double km;
  final int cells;
  final int caches;
  final int rare;
  final int epic;
  final int legendary;
  final int relics;
  final int sets;
  final int sectors;
  final int charted;
  final int half;
  final int bestStreak;
  final int beacons;
  final int quests;
  final int weeklies;
  final int activeDays;
  final int bestDayCells;
  final double bestDayKm;
  final int night;
  final int dawn;
  final int level;
  final int walks;
  final int gold;
  final int styles;
}

class Badge {
  const Badge(this.id, this.group, this.tier, this.goal, this.value);
  final String id;
  final String group;
  final int tier;
  final double goal;
  final double Function(Facts) value;

  bool unlocked(Facts f) => value(f) >= goal;
  double share(Facts f) => (value(f) / goal).clamp(0.0, 1.0);
}

class BadgeGroup {
  const BadgeGroup(this.id, this.goals, this.value);
  final String id;
  final List<double> goals;
  final double Function(Facts) value;
}

class Badges {
  Badges._();

  static BadgeGroup _g(String id, List<num> goals, num Function(Facts) value) =>
      BadgeGroup(id, goals.map((e) => e.toDouble()).toList(), (f) => value(f).toDouble());

  static final groups = <BadgeGroup>[
    _g('km', [
      1,
      3,
      5,
      10,
      25,
      50,
      100,
      200,
      300,
      500,
      750,
      1000,
      1500,
      2000,
      3000,
      5000,
    ], (f) => f.km),
    _g('area', [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2, 3, 5, 10, 20, 30, 50, 100], (f) => f.areaKm2),
    _g('cells', [100, 500, 1000, 2500, 5000, 10000, 25000, 50000, 100000, 250000], (f) => f.cells),
    _g('cache', [1, 5, 10, 25, 50, 100, 150, 250, 500, 1000], (f) => f.caches),
    _g('rare', [1, 10, 50, 100], (f) => f.rare),
    _g('epic', [1, 10, 25], (f) => f.epic),
    _g('legend', [1, 5, 10], (f) => f.legendary),
    _g('relic', [3, 6, 12, 18, 24, 30, 36], (f) => f.relics),
    _g('set', [1, 2, 3, 4, 5, 6], (f) => f.sets),
    _g('sector', [1, 3, 5, 10, 20, 30, 50, 75, 100, 200], (f) => f.sectors),
    _g('charted', [1, 3, 5, 10, 25], (f) => f.charted),
    _g('half', [1, 3, 10], (f) => f.half),
    _g('streak', [3, 7, 14, 30, 60, 100, 200, 365], (f) => f.bestStreak),
    _g('beacon', [1, 5, 10, 25, 50, 100, 200], (f) => f.beacons),
    _g('quest', [1, 10, 25, 50, 100, 200, 500], (f) => f.quests),
    _g('weekly', [1, 5, 10, 25, 52], (f) => f.weeklies),
    _g('days', [7, 30, 60, 100, 200, 365], (f) => f.activeDays),
    _g('bigday', [200, 500, 1000, 2000], (f) => f.bestDayCells),
    _g('longday', [5, 10, 15, 20, 30, 42], (f) => f.bestDayKm),
    _g('night', [50, 250, 1000], (f) => f.night),
    _g('dawn', [50, 250, 1000], (f) => f.dawn),
    _g('level', [5, 10, 15, 20, 25, 30, 40, 50], (f) => f.level),
    _g('walks', [1, 10, 50, 100, 250, 500], (f) => f.walks),
    _g('gold', [500, 2000, 10000], (f) => f.gold),
    _g('style', [2, 4, 6], (f) => f.styles),
  ];

  static final all = [
    for (final gr in groups)
      for (var i = 0; i < gr.goals.length; i++)
        Badge('${gr.id}_${i + 1}', gr.id, i, gr.goals[i], gr.value),
  ];

  static List<Badge> unlocked(Facts f) => all.where((b) => b.unlocked(f)).toList();
}

class Wallet {
  Wallet._();
  static int coins(List<FindRow> finds, List<EntryRow> ledger) =>
      finds.fold<int>(0, (a, f) => a + f.coins) + ledger.fold<int>(0, (a, e) => a + e.coins);

  static int xp(int cells, List<FindRow> finds, List<EntryRow> ledger) =>
      cells + finds.fold<int>(0, (a, f) => a + f.xp) + ledger.fold<int>(0, (a, e) => a + e.xp);
}
