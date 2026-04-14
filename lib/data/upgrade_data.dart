import 'dart:math' as math;
import '../models/loot_box.dart';

class UpgradeData {
  static const List<Map<String, dynamic>> upgrades = [
    // Themes
    {
      'id': 1,
      'name': 'Deep Sea Theme',
      'description': 'A dark, mysterious theme with deep blue colors',
      'category': UpgradeCategory.theme,
      'minRarity': LootBoxRarity.common,
    },
    {
      'id': 2,
      'name': 'Neon Dreams Theme',
      'description': 'Bright neon colors that pulse with energy',
      'category': UpgradeCategory.theme,
      'minRarity': LootBoxRarity.uncommon,
    },
    {
      'id': 3,
      'name': 'Coral Reef Theme',
      'description': 'Vibrant coral colors with tropical vibes',
      'category': UpgradeCategory.theme,
      'minRarity': LootBoxRarity.rare,
    },
    {
      'id': 4,
      'name': 'Bioluminescent Theme',
      'description': 'Glowing phosphorescent colors from the deep',
      'category': UpgradeCategory.theme,
      'minRarity': LootBoxRarity.legendary,
    },
    {
      'id': 9,
      'name': 'Custom Theme',
      'description': 'Upload your own image to create a custom theme',
      'category': UpgradeCategory.theme,
      'minRarity': LootBoxRarity.legendary,
    },

    // Boat Styles
    {
      'id': 5,
      'name': 'Classic Sub',
      'description': 'The standard submarine design',
      'category': UpgradeCategory.boatStyle,
      'minRarity': LootBoxRarity.common,
    },
    {
      'id': 6,
      'name': 'Sleek Racer', // Woah there speed racer 
      'description': 'A sleek, aerodynamic submarine built for speed',
      'category': UpgradeCategory.boatStyle,
      'minRarity': LootBoxRarity.uncommon,
    },
    {
      'id': 7,
      'name': 'Armored Beast',
      'description': 'A heavily armored submarine for deep dives',
      'category': UpgradeCategory.boatStyle,
      'minRarity': LootBoxRarity.rare,
    },
    {
      'id': 8,
      'name': 'Mythical Leviathan',
      'description': 'A legendary creature-inspired submarine',
      'category': UpgradeCategory.boatStyle,
      'minRarity': LootBoxRarity.legendary,
    },
  ];

  static Upgrade getUpgradeById(int id) {
    final data = upgrades.firstWhere(
      (u) => u['id'] == id,
      orElse: () => throw Exception('Upgrade not found'),
    );
    return Upgrade(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      category: data['category'],
      minRarity: data['minRarity'],
    );
  }

  static List<Upgrade> getUpgradesByCategory(UpgradeCategory category) {
    return upgrades
        .where((u) => u['category'] == category)
        .map((u) => Upgrade(
              id: u['id'],
              name: u['name'],
              description: u['description'],
              category: u['category'],
              minRarity: u['minRarity'],
            ))
        .toList();
  }

  static Upgrade getRandomUpgradeForRarity(LootBoxRarity rarity, {Set<int>? excludeIds}) {
    final possible = upgrades
        .where((u) => _rarityValue(u['minRarity']) <= _rarityValue(rarity))
        .where((u) => excludeIds == null || !excludeIds.contains(u['id']))
        .toList();
    final fallback = upgrades
        .where((u) => _rarityValue(u['minRarity']) <= _rarityValue(rarity))
        .toList();
    final validChoices = possible.isNotEmpty ? possible : fallback;
    final random = math.Random();
    final selected = validChoices[random.nextInt(validChoices.length)];
    return Upgrade(
      id: selected['id'],
      name: selected['name'],
      description: selected['description'],
      category: selected['category'],
      minRarity: selected['minRarity'],
    );
  }

  static int _rarityValue(LootBoxRarity rarity) {
    switch (rarity) {
      case LootBoxRarity.common:
        return 0;
      case LootBoxRarity.uncommon:
        return 1;
      case LootBoxRarity.rare:
        return 2;
      case LootBoxRarity.legendary:
        return 3;
    }
  }
}
