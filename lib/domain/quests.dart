import 'package:mapdefog/data/models.dart';
import 'package:mapdefog/geo/grid.dart';
import 'package:mapdefog/util/random.dart';

class Beacons {
  Beacons._();
  static const reachM = 40.0;
  static const coins = 60;
  static const xp = 120;

  static (double, double) place(
    int day,
    int salt,
    double lat,
    double lon,
    int level,
    int Function(double, double) explored,
  ) {
    final rnd = Random(day * 7919 + salt * 104729);
    final reach = (900 + level * 25).clamp(0, 1700).toDouble();
    final base = rnd.nextDouble() * 360;
    (double, double)? best;
    var bestScore = 1 << 30;
    for (var i = 0; i < 10; i++) {
      final d = 600 + rnd.nextDouble() * (reach - 600);
      final p = Grid.offset(lat, lon, d, base + i * 36 + rnd.nextDouble() * 12);
      final score = explored(p.$1, p.$2);
      if (score < bestScore) {
        bestScore = score;
        best = p;
      }
    }
    return best!;
  }
}

enum Goal { cells, meters, caches, rare, beacon }

class Quest {
  const Quest(this.ref, this.goal, this.target, this.coins, this.xp);
  final String ref;
  final Goal goal;
  final int target;
  final int coins;
  final int xp;

  @override
  bool operator ==(Object other) =>
      other is Quest &&
      other.ref == ref &&
      other.goal == goal &&
      other.target == target &&
      other.coins == coins &&
      other.xp == xp;

  @override
  int get hashCode => Object.hash(ref, goal, target, coins, xp);
}

class Quests {
  Quests._();

  static List<Quest> daily(int day, int level) {
    final rnd = Random(day * 31 + 17);
    final l = level.clamp(1, 30);
    final cells = _round10(60 + l * 8 + rnd.nextInt(40));
    final Quest second;
    switch (rnd.nextInt(3)) {
      case 0:
        second = Quest(
          'q:$day:1',
          Goal.meters,
          _round100(1500 + l * 80 + rnd.nextInt(1500)),
          40,
          60,
        );
      case 1:
        second = Quest('q:$day:1', Goal.caches, 1 + rnd.nextInt(l < 5 ? 2 : 3), 40, 60);
      default:
        if (l >= 6) {
          second = Quest('q:$day:1', Goal.rare, 1, 60, 90);
        } else {
          second = Quest('q:$day:1', Goal.meters, _round100(2000 + rnd.nextInt(1000)), 40, 60);
        }
    }
    return [
      Quest('q:$day:0', Goal.cells, cells, 30, 50),
      second,
      Quest('q:$day:2', Goal.beacon, 1, Beacons.coins, Beacons.xp),
    ];
  }

  static Quest weekly(int week, int level) {
    final l = level.clamp(1, 30);
    final mod = ((week % 3) + 3) % 3;
    return switch (mod) {
      0 => Quest('w:$week', Goal.cells, _round10(600 + l * 60).clamp(0, 2500), 250, 400),
      1 => Quest('w:$week', Goal.meters, _round100(12000 + l * 600).clamp(0, 30000), 250, 400),
      _ => Quest('w:$week', Goal.caches, (6 + l ~/ 3).clamp(0, 15), 250, 400),
    };
  }

  static int progress(Quest q, List<DayRow> days) {
    return switch (q.goal) {
      Goal.cells => days.fold<int>(0, (a, d) => a + d.cells),
      Goal.meters => days.fold<double>(0, (a, d) => a + d.meters).toInt(),
      Goal.caches => days.fold<int>(0, (a, d) => a + d.caches),
      Goal.rare => days.fold<int>(0, (a, d) => a + d.rare),
      Goal.beacon => days.where((d) => d.beacon).length,
    };
  }

  static int _round10(int v) => (v + 5) ~/ 10 * 10;
  static int _round100(int v) => (v + 50) ~/ 100 * 100;
}

class Sectors {
  Sectors._();
  static const milestones = [(0.05, 20, 50), (0.15, 50, 120), (0.25, 100, 250), (0.40, 250, 500)];
  static const charted = 0.25;
  static String ref(int sector, double share) => 'sec:$sector:${(share * 100).toInt()}';
}

class Shop {
  Shop._();
  static const styles = [
    Style('mist', 0),
    Style('parchment', 200),
    Style('snow', 250),
    Style('midnight', 300),
    Style('ember', 400),
    Style('aurora', 500),
  ];
  static const lantern = 60;
  static const radar = 40;
  static const shield = 120;
  static const reroll = 25;
  static const maxShields = 3;
  static const boostMs = 60 * 60 * 1000;
  static const lanternFactor = 1.6;
}

class Style {
  const Style(this.id, this.price);
  final String id;
  final int price;
}
