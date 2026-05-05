import 'package:flutter/material.dart';

class RankTier {
  final String name;
  final Color color;
  final int minMeters;
  final String icon; // Path to your emblem asset

  const RankTier({
    required this.name,
    required this.color,
    required this.minMeters,
    required this.icon,
  });
}

class RankSystem {
  static const List<RankTier> levels = [
    RankTier(
      name: "Diamond",
      color: Colors.purpleAccent,
      minMeters: 10000,
      icon: "💎",
    ),
    RankTier(
      name: "Platinum I",
      color: Colors.cyanAccent,
      minMeters: 8500,
      icon: "💠",
    ),
    RankTier(
      name: "Platinum II",
      color: Colors.cyanAccent,
      minMeters: 7000,
      icon: "💠",
    ),
    RankTier(
      name: "Platinum III",
      color: Colors.cyanAccent,
      minMeters: 5500,
      icon: "💠",
    ),
    RankTier(
      name: "Gold I",
      color: Colors.yellowAccent,
      minMeters: 4500,
      icon: "🟡",
    ),
    RankTier(
      name: "Gold II",
      color: Colors.yellowAccent,
      minMeters: 3500,
      icon: "🟡",
    ),
    RankTier(
      name: "Gold III",
      color: Colors.yellowAccent,
      minMeters: 2500,
      icon: "🟡",
    ),
    RankTier(name: "Silver I", color: Colors.grey, minMeters: 1800, icon: "⚪"),
    RankTier(name: "Silver II", color: Colors.grey, minMeters: 1200, icon: "⚪"),
    RankTier(
      name: "Bronze I",
      color: Colors.orangeAccent,
      minMeters: 600,
      icon: "🟤",
    ),
    RankTier(
      name: "Copper I",
      color: Colors.redAccent,
      minMeters: 0,
      icon: "🧱",
    ),
  ];

  static RankTier getRank(int meters) {
    return levels.firstWhere(
      (rank) => meters >= rank.minMeters,
      orElse: () => levels.last,
    );
  }

  static double calculateAverageRank(List<String> history) {
    if (history.isEmpty) return 0;
    int totalIndex = 0;
    for (var entry in history) {
      String rankName = entry.split('|')[2];
      totalIndex += levels.indexWhere((r) => r.name == rankName);
    }
    // Returns the average index in the levels list
    return totalIndex / history.length;
  }
}
