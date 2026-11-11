import 'package:mapdefog/domain/rarity.dart';

class Relic {
  const Relic(this.id, this.set, this.rarity);
  final String id;
  final String set;
  final Rarity rarity;
}

class Relics {
  Relics._();

  static const sets = ['wayfarer', 'maps', 'curios', 'stones', 'myths', 'stars'];

  static const _setRarity = {
    'wayfarer': Rarity.common,
    'maps': Rarity.common,
    'curios': Rarity.rare,
    'stones': Rarity.rare,
    'myths': Rarity.epic,
    'stars': Rarity.legendary,
  };

  static const _ids = {
    'wayfarer': ['compass', 'boots', 'lantern', 'staff', 'flask', 'rope'],
    'maps': ['torn_map', 'sea_chart', 'star_chart', 'city_plan', 'treasure_map', 'nowhere_map'],
    'curios': ['watch', 'spyglass', 'music_box', 'hourglass', 'quill', 'snow_globe'],
    'stones': ['moonstone', 'amber', 'pearl', 'fossil', 'geode', 'meteorite'],
    'myths': [
      'dragon_scale',
      'phoenix_feather',
      'mermaid_comb',
      'griffin_claw',
      'unicorn_hair',
      'kraken_ink',
    ],
    'stars': ['comet_tail', 'star_seed', 'sun_coin', 'moon_key', 'aurora_ribbon', 'void_pearl'],
  };

  static final List<Relic> all = [
    for (final s in sets)
      for (final id in _ids[s]!) Relic(id, s, _setRarity[s]!),
  ];

  static Relic? byId(String id) {
    for (final r in all) {
      if (r.id == id) return r;
    }
    return null;
  }

  static List<Relic> inSet(String set) => all.where((r) => r.set == set).toList();

  static Rarity setRarity(String set) => _setRarity[set]!;

  static int dupeCoins(Relic r) => 10 + r.rarity.index * 25;

  static (int coins, int xp) setReward(String set) => switch (setRarity(set)) {
    Rarity.common => (150, 200),
    Rarity.rare => (300, 400),
    Rarity.epic => (600, 800),
    Rarity.legendary => (1500, 2000),
  };

  static List<String> completeSets(Set<String> owned) =>
      sets.where((s) => inSet(s).every((r) => owned.contains(r.id))).toList();
}
