import 'package:flutter/material.dart';
import '../models/loot_box.dart';
import '../data/database_helper.dart';
import '../data/upgrade_data.dart';
import '../widgets/shared_widgets.dart';

class PersonalizeScreen extends StatefulWidget {
  final ValueChanged<String> onThemeChanged;
  const PersonalizeScreen({super.key, required this.onThemeChanged});

  @override
  State<PersonalizeScreen> createState() => _PersonalizeScreenState();
}

class _PersonalizeScreenState extends State<PersonalizeScreen> {
  late DatabaseHelper _dbHelper;
  late Future<List<Map<String, dynamic>>> _purchasedUpgrades;
  String selectedTheme = 'default';
  String selectedBoatStyle = 'default';

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _purchasedUpgrades = _dbHelper.getPurchasedUpgrades();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final stats = await _dbHelper.getUserStats();
    setState(() {
      selectedTheme = stats['selected_theme'] as String? ?? 'default';
      selectedBoatStyle = (stats['selected_boat_style'] as String?) ?? 'Classic Sub';
      if (selectedBoatStyle == 'default') selectedBoatStyle = 'Classic Sub';
    });
  }

  Color _getRarityColor(LootBoxRarity rarity) {
    switch (rarity) {
      case LootBoxRarity.common:
        return Colors.grey[600]!;
      case LootBoxRarity.uncommon:
        return Colors.greenAccent;
      case LootBoxRarity.rare:
        return Colors.blueAccent;
      case LootBoxRarity.legendary:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AbyssalBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'PERSONALIZE',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildCategorySection(
                        'THEMES',
                        UpgradeCategory.theme,
                        Icons.palette,
                      ),
                      const SizedBox(height: 40),
                      _buildCategorySection(
                        'BOAT STYLES',
                        UpgradeCategory.boatStyle,
                        Icons.directions_boat,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    String title,
    UpgradeCategory category,
    IconData icon,
  ) {
    final upgrades = UpgradeData.getUpgradesByCategory(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _purchasedUpgrades,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final purchasedIds = snapshot.data!
                .map((u) => u['upgrade_id'] as int)
                .toSet();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upgrades.length,
              itemBuilder: (context, index) {
                final upgrade = upgrades[index];
                final isPurchased = upgrade.id == 5 || purchasedIds.contains(upgrade.id);

                return _buildUpgradeCard(
                  upgrade,
                  isPurchased,
                  category,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpgradeCard(
    Upgrade upgrade,
    bool isPurchased,
    UpgradeCategory category,
  ) {
    final color = _getRarityColor(upgrade.minRarity);
    final isSelected = (category == UpgradeCategory.theme &&
            selectedTheme == upgrade.name) ||
        (category == UpgradeCategory.boatStyle &&
            selectedBoatStyle == upgrade.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: isSelected ? Colors.cyanAccent : color,
          width: isSelected ? 3 : 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        upgrade.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        upgrade.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPurchased) ...[
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.cyanAccent,
                          size: 32,
                        )
                      else
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text(
                            'Select',
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () async {
                            setState(() {
                              if (category == UpgradeCategory.theme) {
                                selectedTheme = upgrade.name;
                              } else {
                                selectedBoatStyle = upgrade.name;
                              }
                            });
                            await _dbHelper.updateUserStats({
                              if (category == UpgradeCategory.theme) 'selected_theme': upgrade.name,
                              if (category == UpgradeCategory.boatStyle) 'selected_boat_style': upgrade.name,
                            });
                            if (category == UpgradeCategory.theme) {
                              widget.onThemeChanged(upgrade.name);
                            }
                          },
                        ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Locked',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
