import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/loot_data.dart';

enum Rarity {
  common(Colors.grey, 10),
  uncommon(Colors.greenAccent, 40),
  rare(Colors.blueAccent, 125),
  epic(Colors.purpleAccent, 450),
  legendary(Colors.amber, 1750),
  mythic(Colors.redAccent, 5000);

  final Color color;
  final int value;
  const Rarity(this.color, this.value);
}

class Treasure {
  final String name;
  final Rarity rarity;
  final String description; // New field for the flavor text

  Treasure({
    required this.name,
    required this.rarity,
    required this.description,
  });

  static Treasure generate(
    int depth, {
    bool guaranteedHighestInBracket = false,
    double luckBonus = 0.0,
  }) {
    final random = math.Random();

    // Your depth-based weight logic (kept intact because it's well-balanced!)
    final Map<Rarity, double> baseWeights = {
      Rarity.mythic: (depth >= 900) ? 1.0 + (depth / 60) : 0.0,
      Rarity.legendary: (depth >= 600) ? 2.0 + (depth / 60) : 0.0,
      Rarity.epic: (depth >= 350) ? 5.0 + (depth / 50) : 0.0,
      Rarity.rare: (depth >= 1200) ? 0.0 : 10.0 + (depth / 40),
      Rarity.uncommon: (depth >= 1000)
          ? 0.0
          : math.max(10.0, 40.0 + (depth / 20) - (depth / 15)),
      Rarity.common: (depth >= 600) ? 0.0 : math.max(5.0, 150.0 - (depth / 5)),
    };

    // Apply luck bonus to higher rarities
    final Map<Rarity, double> weights = {};
    for (Rarity r in Rarity.values) {
      double multiplier = 1.0;
      if (r == Rarity.rare ||
          r == Rarity.epic ||
          r == Rarity.legendary ||
          r == Rarity.mythic) {
        multiplier += luckBonus;
      }
      weights[r] = (baseWeights[r] ?? 0.0) * multiplier;
    }

    if (guaranteedHighestInBracket) {
      for (Rarity rarity in Rarity.values.toList().reversed) {
        if ((weights[rarity] ?? 0.0) > 0) {
          return _createTreasureFromPool(rarity);
        }
      }
    }

    double totalWeight = weights.values.fold(0.0, (sum, w) => sum + w);
    double roll = random.nextDouble() * totalWeight;
    double cursor = 0;

    for (Rarity r in Rarity.values) {
      cursor += weights[r] ?? 0.0;
      if (roll < cursor) {
        return _createTreasureFromPool(r);
      }
    }

    // Hard fallback just in case the abyss stares back too hard
    return _createTreasureFromPool(Rarity.common);
  }

  static Treasure _createTreasureFromPool(Rarity rarity) {
    final random = math.Random();
    // Accessing the new Map structure: TreasureData.treasurePool[rarity]
    final pool =
        TreasureData.treasurePool[rarity] ??
        {"Mystery Object": "A strange glitch in the sonar."};

    // Pick a random key (the name)
    String name = pool.keys.elementAt(random.nextInt(pool.length));
    // Get the corresponding value (the description)
    String description = pool[name]!;

    return Treasure(name: name, rarity: rarity, description: description);
  }

  // Converts the object to a Map for JSON encoding
  Map<String, dynamic> toMap() => {
    'name': name,
    'rarity': rarity.name,
    'description': description,
  };

  // Useful for creating a Treasure object back from SharedPreferences
  factory Treasure.fromMap(Map<String, dynamic> map) {
    return Treasure(
      name: map['name'] ?? "Unknown",
      rarity: Rarity.values.firstWhere(
        (e) => e.name == map['rarity'],
        orElse: () => Rarity.common,
      ),
      description: map['description'] ?? "No description available.",
    );
  }
}
