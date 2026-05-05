import 'package:flutter/material.dart';

import '../widgets/shared_widgets.dart';
import 'inventory_screen.dart';
import 'loot_boxes_screen.dart';

class VaultScreen extends StatefulWidget {
  final int totalCoins;
  final VoidCallback onCoinsChanged;

  const VaultScreen({
    super.key,
    required this.totalCoins,
    required this.onCoinsChanged,
  });

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AbyssalBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              // Tab bar
              Container(
                color: Colors.black.withAlpha(50),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.cyanAccent,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: Colors.cyanAccent,
                  tabs: const [
                    Tab(text: 'TREASURES'),
                    Tab(text: 'LOOT BOXES'),
                  ],
                ),
              ),
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    const InventoryScreen(),
                    LootBoxesScreen(
                      totalCoins: widget.totalCoins,
                      onCoinsChanged: widget.onCoinsChanged,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
