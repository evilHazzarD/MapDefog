enum Rarity {
  common(12, 15, 62, 0.45),
  rare(35, 40, 26, 0.75),
  epic(90, 100, 9, 1.0),
  legendary(220, 250, 3, 1.0);

  const Rarity(this.coins, this.xp, this.weight, this.relicChance);
  final int coins;
  final int xp;
  final int weight;
  final double relicChance;
}
