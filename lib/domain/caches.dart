import 'package:mapdefog/domain/rarity.dart';
import 'package:mapdefog/domain/relics.dart';
import 'package:mapdefog/geo/grid.dart';
import 'package:mapdefog/util/random.dart';

class Cache {
  const Cache(this.key, this.lat, this.lon, this.rarity);
  final String key;
  final double lat;
  final double lon;
  final Rarity rarity;

  @override
  bool operator ==(Object other) =>
      other is Cache &&
      other.key == key &&
      other.lat == lat &&
      other.lon == lon &&
      other.rarity == rarity;

  @override
  int get hashCode => Object.hash(key, lat, lon, rarity);
}

class Loot {
  const Loot(this.coins, this.xp, this.relic, this.duplicate);
  final int coins;
  final int xp;
  final Relic? relic;
  final bool duplicate;
}

class Caches {
  Caches._();

  static const int z = 16;
  static const int _side = 1 << z;
  static const double openM = 30.0;
  static const double senseM = 300.0;

  /// Weeks start on Monday; epoch day 0 was a Thursday.
  static int week(int epochDay) => (epochDay + 3) ~/ 7;

  static List<Cache> inTile(int tx, int ty, int week) {
    final rnd = Random(_seed(tx, ty, week));
    final roll = rnd.nextInt(100);
    final n = roll < 20
        ? 0
        : roll < 65
        ? 1
        : roll < 93
        ? 2
        : 3;
    return List.generate(n, (i) {
      final fx = 0.08 + rnd.nextDouble() * 0.84;
      final fy = 0.08 + rnd.nextDouble() * 0.84;
      final lat = Grid.lat((ty + fy) / _side);
      final lon = Grid.lon((tx + fx) / _side);
      return Cache('c:$week:$tx:$ty:$i', lat, lon, _rarity(rnd));
    });
  }

  static List<Cache> near(double lat, double lon, double radius, int week) {
    final tileM = Grid.cellMeters(lat) * (1 << (Grid.z - z));
    final span = (radius / tileM).toInt() + 1;
    final cx = (Grid.mx(lon) * _side).floor();
    final cy = (Grid.my(lat) * _side).floor();
    final out = <Cache>[];
    for (var tx = cx - span; tx <= cx + span; tx++) {
      for (var ty = cy - span; ty <= cy + span; ty++) {
        if (tx < 0 || tx >= _side || ty < 0 || ty >= _side) continue;
        for (final c in inTile(tx, ty, week)) {
          if (Grid.distance(lat, lon, c.lat, c.lon) <= radius) out.add(c);
        }
      }
    }
    return out;
  }

  static List<Cache> inBox(int tx0, int ty0, int tx1, int ty1, int week) {
    if ((tx1 - tx0 + 1) * (ty1 - ty0 + 1) > 900) return const [];
    final out = <Cache>[];
    for (var tx = tx0; tx <= tx1; tx++) {
      for (var ty = ty0; ty <= ty1; ty++) {
        if (tx < 0 || tx >= _side || ty < 0 || ty >= _side) continue;
        out.addAll(inTile(tx, ty, week));
      }
    }
    return out;
  }

  static Rarity _rarity(Random rnd) {
    var r = rnd.nextInt(Rarity.values.fold<int>(0, (a, e) => a + e.weight));
    for (final q in Rarity.values) {
      if (r < q.weight) return q;
      r -= q.weight;
    }
    return Rarity.common;
  }

  static int _seed(int tx, int ty, int week) =>
      (tx * 73856093) ^ (ty * 19349663) ^ (week * 83492791) ^ 0x5DEECE66D;

  static Loot open(Cache cache, Set<String> owned) {
    final rnd = Random(stringHashCode(cache.key) * 31 + 7);
    final coins = cache.rarity.coins + rnd.nextInt(cache.rarity.coins ~/ 2 + 1);
    if (rnd.nextDouble() >= cache.rarity.relicChance) {
      return Loot(coins, cache.rarity.xp, null, false);
    }
    final tier = cache.rarity.index > 0 && rnd.nextDouble() < 0.3
        ? cache.rarity.index - 1
        : cache.rarity.index;
    final pool = Relics.all.where((r) => r.rarity.index == tier).toList();
    var relic = pool[rnd.nextInt(pool.length)];
    if (owned.contains(relic.id)) relic = pool[rnd.nextInt(pool.length)];
    final duplicate = owned.contains(relic.id);
    return Loot(
      coins + (duplicate ? Relics.dupeCoins(relic) : 0),
      cache.rarity.xp,
      relic,
      duplicate,
    );
  }
}
