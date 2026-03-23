enum Rarity { common, rare, epic }

class Recipe {
  final List<int> ids;
  final String name;
  final Rarity rarity;
  final String icon;
  final int unlockLevel;
  final int baseBrewTime;
  final int sellPrice;
  final int xpValue;

  const Recipe({
    required this.ids,
    required this.name,
    required this.rarity,
    required this.icon,
    required this.unlockLevel,
    required this.baseBrewTime,
    required this.sellPrice,
    required this.xpValue,
  });

  String get key {
    final sorted = List<int>.from(ids)..sort();
    return sorted.join("_");
  }

  int get plantTier => ids.first;
}
