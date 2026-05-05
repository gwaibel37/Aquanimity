import 'dart:math' as math;
import '../models/loot_box.dart';

class UpgradeData {
  static const List<Map<String, dynamic>> upgrades = [
    // Common Rarity
    {
      'id': 1,
      'name': 'Deep Sea Theme',
      'description': 'A dark, mysterious theme with deep blue colors',
      'category': UpgradeCategory.theme,
      'minRarity': LootBoxRarity.common,
    },
    {
      'id': 5,
      'name': 'Classic Sub',
      'description': 'The standard submarine design',
      'category': UpgradeCategory.boatStyle,
      'minRarity': LootBoxRarity.common,
    },
    {
      'id': 10,
      'name': 'Ion Cruiser',
      'description': 'A sleek, electrified vessel powered by ionic propulsion',
      'category': UpgradeCategory.boatStyle,
      'minRarity': LootBoxRarity.common,
    },
    {
      'id': 17,
      'name': 'Coin Multiplier +5%',
      'description': 'Increases coin earnings from dives by 5%',
      'category': UpgradeCategory.perk,
      'minRarity': LootBoxRarity.common,
      'effect': {'type': 'coinMultiplier', 'value': 0.05},
    },

    // Uncommon Rarity
    {
      'id': 2,
      'name': 'Neon Dreams Theme',
      'description': 'Bright neon colors that pulse with energy',
      'category': UpgradeCategory.theme,
      'minRarity': LootBoxRarity.uncommon,
    },
    {
      'id': 6,
      'name': 'Sleek Racer', // Woah there speed racer
      'description': 'A sleek, aerodynamic submarine built for speed',
      'category': UpgradeCategory.boatStyle,
      'minRarity': LootBoxRarity.uncommon,
    },
    {
      'id': 11,
      'name': 'Phantom Walker',
      'description':
          'A silent, advanced cloaking submarine that moves undetected',
      'category': UpgradeCategory.boatStyle,
      'minRarity': LootBoxRarity.uncommon,
    },
    {
      'id': 12,
      'name': 'Deep Navigator',
      'description':
          'A robust explorer with advanced sonar and mapping systems',
      'category': UpgradeCategory.boatStyle,
      'minRarity': LootBoxRarity.uncommon,
    },
    {
      'id': 18,
      'name': 'Coin Multiplier +10%',
      'description': 'Increases coin earnings from dives by 10%',
      'category': UpgradeCategory.perk,
      'minRarity': LootBoxRarity.uncommon,
      'effect': {'type': 'coinMultiplier', 'value': 0.10},
    },
    {
      'id': 19,
      'name': 'Depth Bonus +2m',
      'description': 'Increases maximum dive depth by 2 meters',
      'category': UpgradeCategory.perk,
      'minRarity': LootBoxRarity.uncommon,
      'effect': {'type': 'depthBonus', 'value': 2},
    },

    // Rare Rarity
    {
      'id': 3,
      'name': 'Coral Reef Theme',
      'description': 'Vibrant coral colors with tropical vibes',
      'category': UpgradeCategory.theme,
      'minRarity': LootBoxRarity.rare,
    },
    {
      'id': 7,
      'name': 'Armored Beast',
      'description': 'A heavily armored submarine for deep dives',
      'category': UpgradeCategory.boatStyle,
      'minRarity': LootBoxRarity.rare,
    },
    {
      'id': 13,
      'name': 'Void Stalker',
      'description':
          'A predatory submarine designed for extreme depths and combat',
      'category': UpgradeCategory.boatStyle,
      'minRarity': LootBoxRarity.rare,
    },
    {
      'id': 14,
      'name': 'Titan Explorer',
      'description':
          'A massive, heavily reinforced submarine for the deepest trenches',
      'category': UpgradeCategory.boatStyle,
      'minRarity': LootBoxRarity.rare,
    },
    {
      'id': 20,
      'name': 'Coin Multiplier +15%',
      'description': 'Increases coin earnings from dives by 15%',
      'category': UpgradeCategory.perk,
      'minRarity': LootBoxRarity.rare,
      'effect': {'type': 'coinMultiplier', 'value': 0.15},
    },
    {
      'id': 21,
      'name': 'Lucky Charm +10%',
      'description':
          'Increases chance of finding higher rarity treasures by 10%',
      'category': UpgradeCategory.perk,
      'minRarity': LootBoxRarity.rare,
      'effect': {'type': 'luckBonus', 'value': 0.10},
    },

    // Legendary Rarity
    {
      'id': 4,
      'name': 'Bioluminescent Theme',
      'description': 'Glowing phosphorescent colors from the deep',
      'category': UpgradeCategory.theme,
      'minRarity': LootBoxRarity.legendary,
    },
    {
      'id': 8,
      'name': 'Mythical Leviathan',
      'description': 'A legendary creature-inspired submarine',
      'category': UpgradeCategory.boatStyle,
      'minRarity': LootBoxRarity.legendary,
    },
    {
      'id': 9,
      'name': 'Custom Theme',
      'description': 'Upload your own image to create a custom theme',
      'category': UpgradeCategory.theme,
      'minRarity': LootBoxRarity.legendary,
    },
    {
      'id': 15,
      'name': 'Quantum Leap',
      'description':
          'A futuristic submarine with impossible technologies from beyond',
      'category': UpgradeCategory.boatStyle,
      'minRarity': LootBoxRarity.legendary,
    },
    {
      'id': 16,
      'name': 'Abyss Sovereign',
      'description':
          'The ruler of the deep, an interdimensional submarine of immense power',
      'category': UpgradeCategory.boatStyle,
      'minRarity': LootBoxRarity.legendary,
    },
    {
      'id': 22,
      'name': 'Coin Multiplier +25%',
      'description': 'Increases coin earnings from dives by 25%',
      'category': UpgradeCategory.perk,
      'minRarity': LootBoxRarity.legendary,
      'effect': {'type': 'coinMultiplier', 'value': 0.25},
    },
    {
      'id': 23,
      'name': 'Lucky Charm +20%',
      'description':
          'Increases chance of finding higher rarity treasures by 20%',
      'category': UpgradeCategory.perk,
      'minRarity': LootBoxRarity.legendary,
      'effect': {'type': 'luckBonus', 'value': 0.20},
    },
    {
      'id': 24,
      'name': 'Depth Bonus +5m',
      'description': 'Increases maximum dive depth by 5 meters',
      'category': UpgradeCategory.perk,
      'minRarity': LootBoxRarity.legendary,
      'effect': {'type': 'depthBonus', 'value': 5},
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
      effect: data['effect'],
    );
  }

  static List<Upgrade> getUpgradesByCategory(UpgradeCategory category) {
    return upgrades
        .where((u) => u['category'] == category)
        .map(
          (u) => Upgrade(
            id: u['id'],
            name: u['name'],
            description: u['description'],
            category: u['category'],
            minRarity: u['minRarity'],
          ),
        )
        .toList();
  }

  static Upgrade? getRandomUpgradeForRarity(
    LootBoxRarity rarity, {
    Set<int>? excludeIds,
  }) {
    final possible = upgrades
        .where((u) => _rarityValue(u['minRarity']) <= _rarityValue(rarity))
        .where((u) => excludeIds == null || !excludeIds.contains(u['id']))
        .toList();
    if (possible.isEmpty) return null;
    final random = math.Random();
    final selected = possible[random.nextInt(possible.length)];
    return Upgrade(
      id: selected['id'],
      name: selected['name'],
      description: selected['description'],
      category: selected['category'],
      minRarity: selected['minRarity'],
      effect: selected['effect'],
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
