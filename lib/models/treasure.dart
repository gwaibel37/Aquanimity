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

  Treasure(this.name, this.rarity);

  static Treasure generate(int depth) {
    final random = math.Random();
    final Map<Rarity, double> weights = {
      Rarity.mythic: (depth >= 900) ? 1.0 + (depth / 60) : 0.0,
      Rarity.legendary: (depth >= 600) ? 2.0 + (depth / 60) : 0.0,
      Rarity.epic: (depth >= 350) ? 5.0 + (depth / 50) : 0.0,
      Rarity.rare: (depth >= 1200) ? 0.0 : 10.0 + (depth / 40),
      Rarity.uncommon: (depth >= 1000) ? 0.0 : math.max(10.0, 40.0 + (depth / 20) - (depth / 15)),
      Rarity.common: (depth >= 600) ? 0.0 : math.max(5.0, 150.0 - (depth / 5)),
    };

    double totalWeight = weights.values.fold(0.0, (sum, w) => sum + w);
    double roll = random.nextDouble() * totalWeight;
    double cursor = 0;
    for (Rarity r in Rarity.values) {
      cursor += weights[r]!;
      if (roll < cursor) return Treasure(_getItemName(r), r);
    }
    return Treasure("Rusty Anchor", Rarity.common);
  }

  static String _getItemName(Rarity rarity) {
    final list = treasurePool[rarity] ?? ["Strange Object"];
    return list[math.Random().nextInt(list.length)];
  }

  Map<String, String> toMap() => {'name': name, 'rarity': rarity.name};
}