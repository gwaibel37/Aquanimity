import 'package:flutter/material.dart';
import '../models/loot_box.dart';
import '../data/database_helper.dart';
import '../data/upgrade_data.dart';
import '../widgets/shared_widgets.dart';

class LootBoxesScreen extends StatefulWidget {
  final int totalCoins;
  final VoidCallback onCoinsChanged;

  const LootBoxesScreen({
    super.key,
    required this.totalCoins,
    required this.onCoinsChanged,
  });

  @override
  State<LootBoxesScreen> createState() => _LootBoxesScreenState();
}

class _LootBoxesScreenState extends State<LootBoxesScreen> {
  late DatabaseHelper _dbHelper;
  int currentCoins = 0;
  Upgrade? openedUpgrade;
  bool isOpening = false;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    currentCoins = widget.totalCoins;
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

  Future<void> _purchaseLootBox(LootBoxRarity rarity) async {
    if (currentCoins < rarity.price) {
      _showMessage('Not enough coins!', Colors.redAccent);
      return;
    }

    setState(() {
      currentCoins -= rarity.price;
      isOpening = true;
    });

    // Update coins in database
    final dbHelper = DatabaseHelper();
    await dbHelper.updateUserStats({'total_coins': currentCoins});
    widget.onCoinsChanged();

    final openingDialog = _showOpeningDialog(rarity);

    final purchasedUpgrades = await _dbHelper.getPurchasedUpgrades();
    final purchasedIds = purchasedUpgrades
        .map((item) => item['upgrade_id'] as int)
        .toSet();

    final reward = UpgradeData.getRandomUpgradeForRarity(
      rarity,
      excludeIds: purchasedIds,
    );

    if (reward == null) {
      // All upgrades purchased, give coins
      final coinReward = rarity.price;
      await _dbHelper.updateUserStats({'total_coins': currentCoins + coinReward});
      setState(() {
        currentCoins += coinReward;
      });
      widget.onCoinsChanged();
      if (mounted) {
        setState(() {
          isOpening = false;
        });
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
      await openingDialog;
      _showMessage('All upgrades unlocked! Got $coinReward coins instead.', Colors.amber);
      return;
    }

    bool isDuplicate = purchasedIds.contains(reward.id);
    if (!isDuplicate) {
      await _dbHelper.purchaseUpgrade(
        reward.id,
        reward.name,
        reward.category.toString(),
      );
    } else {
      final coinReward = rarity.price ~/ 2;
      await _dbHelper.updateUserStats({'total_coins': currentCoins + coinReward});
      setState(() {
        currentCoins += coinReward;
      });
      widget.onCoinsChanged();
    }

    if (mounted) {
      setState(() {
        openedUpgrade = reward;
        isOpening = false;
      });
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
    await openingDialog;
    await _showRewardDialog(reward, rarity, isDuplicate);
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showOpeningDialog(LootBoxRarity rarity) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[900],
          title: Text('Opening ${rarity.displayName} Loot Box', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SizedBox(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(color: Colors.cyanAccent),
                SizedBox(height: 20),
                Text('Preparing your reward...', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showRewardDialog(Upgrade reward, LootBoxRarity rarity, bool isDuplicate) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[900],
          title: Text(isDuplicate ? 'Duplicate from ${rarity.displayName} Box' : 'Unlocked from ${rarity.displayName} Box', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You opened a ${rarity.displayName} Loot Box.', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              if (isDuplicate)
                Text('Duplicate: ${reward.name}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))
              else
                Text('Unlocked: ${reward.name}', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (isDuplicate)
                Text('You already have this upgrade. Got coins instead!', style: const TextStyle(color: Colors.white70))
              else
                Text(reward.description, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(isDuplicate ? 'Okay' : 'Nice!', style: const TextStyle(color: Colors.cyanAccent)),
            ),
          ],
        );
      },
    );
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
                        'LOOT BOXES',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: Colors.cyanAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              '$currentCoins',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      if (openedUpgrade == null && !isOpening) ...[
                        _buildLootBoxGrid(),
                      ] else if (isOpening) ...[
                        _buildOpeningAnimation(),
                      ] else ...[
                        _buildUpgradeReward(),
                      ],
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

  Widget _buildLootBoxGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final rarity in LootBoxRarity.values)
          _buildLootBoxCard(rarity),
      ],
    );
  }

  Widget _buildLootBoxCard(LootBoxRarity rarity) {
    final color = _getRarityColor(rarity);
    final canAfford = currentCoins >= rarity.price;

    return GestureDetector(
      onTap: canAfford ? () => _purchaseLootBox(rarity) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: canAfford ? color : Colors.grey[600]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard,
              size: 48,
              color: canAfford ? color : Colors.grey[600],
            ),
            const SizedBox(height: 12),
            Text(
              rarity.displayName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: canAfford ? color : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${rarity.price}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: canAfford ? Colors.amber : Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (!canAfford) ...[
              const SizedBox(height: 8),
              Text(
                'Not enough',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[300],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOpeningAnimation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.card_giftcard,
            size: 120,
            color: Colors.cyanAccent,
          ),
          const SizedBox(height: 40),
          const Text(
            'Opening...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildUpgradeReward() {
    if (openedUpgrade == null) return const SizedBox.shrink();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: _getRarityColor(openedUpgrade!.minRarity),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _getRarityColor(openedUpgrade!.minRarity)
                      .withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'YOU GOT:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getRarityColor(openedUpgrade!.minRarity),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Icon(
                  openedUpgrade!.category == UpgradeCategory.theme
                      ? Icons.palette
                      : Icons.directions_boat,
                  size: 64,
                  color: _getRarityColor(openedUpgrade!.minRarity),
                ),
                const SizedBox(height: 16),
                Text(
                  openedUpgrade!.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getRarityColor(openedUpgrade!.minRarity),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  openedUpgrade!.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent[700],
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            onPressed: () {
              setState(() {
                openedUpgrade = null;
              });
            },
            child: const Text(
              'AWESOME!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 60),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent[700],
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text(
              'BACK',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
