enum LootBoxRarity { common, uncommon, rare, legendary }

extension LootBoxRarityExt on LootBoxRarity {
  String get displayName {
    switch (this) {
      case LootBoxRarity.common:
        return 'Common';
      case LootBoxRarity.uncommon:
        return 'Uncommon';
      case LootBoxRarity.rare:
        return 'Rare';
      case LootBoxRarity.legendary:
        return 'Legendary';
    }
  }

  int get price {
    switch (this) {
      case LootBoxRarity.common:
        return 50;
      case LootBoxRarity.uncommon:
        return 125;
      case LootBoxRarity.rare:
        return 300;
      case LootBoxRarity.legendary:
        return 750;
    }
  }
}

class LootBox {
  final int id;
  final LootBoxRarity rarity;
  final int quantity;

  LootBox({required this.id, required this.rarity, this.quantity = 1});

  int get totalPrice => rarity.price * quantity;
}

enum UpgradeCategory { theme, boatStyle, perk }

class Upgrade {
  final int id;
  final String name;
  final String description;
  final UpgradeCategory category;
  final LootBoxRarity minRarity;
  final bool isPurchased;
  final Map<String, dynamic>? effect;

  Upgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.minRarity,
    this.isPurchased = false,
    this.effect,
  });
}
