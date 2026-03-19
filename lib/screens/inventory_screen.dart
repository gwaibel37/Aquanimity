import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart'; // Added for feedback
import '../models/treasure.dart';
import '../widgets/shared_widgets.dart';

enum SortMode { newest, rarity, value }

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Map<String, dynamic>> items = [];
  int totalCoins = 0;
  SortMode _currentSort = SortMode.newest;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedItems = prefs.getStringList('treasure_inventory') ?? [];
    setState(() {
      // Correctly parsing the JSON objects from SharedPreferences
      items = savedItems.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
      totalCoins = prefs.getInt('total_coins') ?? 0;
      _applySort(); 
    });
  }

  void _applySort() {
    setState(() {
      switch (_currentSort) {
        case SortMode.newest:
          // Showing the items in the order they were found (reversed for newest first)
          items = items.reversed.toList(); 
          break;
        case SortMode.rarity:
          items.sort((a, b) {
            final rA = Rarity.values.firstWhere((e) => e.name == a['rarity']).index;
            final rB = Rarity.values.firstWhere((e) => e.name == b['rarity']).index;
            return rB.compareTo(rA);
          });
          break;
        case SortMode.value:
          items.sort((a, b) {
            final vA = Rarity.values.firstWhere((e) => e.name == a['rarity']).value;
            final vB = Rarity.values.firstWhere((e) => e.name == b['rarity']).value;
            return vB.compareTo(vA);
          });
          break;
      }
    });
  }

  void _toggleSort() {
    setState(() {
      _currentSort = SortMode.values[(_currentSort.index + 1) % SortMode.values.length];
      _applySort();
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('treasure_inventory', items.map((i) => jsonEncode(i)).toList());
    await prefs.setInt('total_coins', totalCoins);
  }

  void _bulkSell(Rarity rarity) async {
    int count = 0;
    int gain = 0;
    setState(() {
      items.removeWhere((item) {
        if (item['rarity'] == rarity.name) {
          count++;
          gain += rarity.value;
          return true;
        }
        return false;
      });
      totalCoins += gain;
    });

    if (count > 0) {
      if (await Vibration.hasVibrator()) Vibration.vibrate(duration: 50);
      await _saveState();
      if(!mounted) return; // Safety check before showing SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: rarity.color.withAlpha(200), 
          content: Text("Liquidated $count ${rarity.name} items for $gain coins!", 
          style: const TextStyle(fontWeight: FontWeight.bold))
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AbyssalBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text("TREASURE VAULT", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 4)),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text("$totalCoins", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 20)),
                      ],
                    ),
                    ActionChip(
                      label: Text(_currentSort.name.toUpperCase(), style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      avatar: const Icon(Icons.sort, size: 14, color: Colors.cyanAccent),
                      backgroundColor: Colors.white10,
                      onPressed: _toggleSort,
                    ),
                  ],
                ),
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                  children: Rarity.values.map((r) {
                    bool hasItems = items.any((i) => i['rarity'] == r.name);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text("Sell ${r.name}", style: const TextStyle(fontSize: 10, color: Colors.white)),
                        backgroundColor: hasItems ? r.color.withAlpha(40) : Colors.transparent,
                        side: BorderSide(color: hasItems ? r.color : Colors.white10),
                        onPressed: hasItems ? () => _bulkSell(r) : null,
                      ),
                    );
                  }).toList(),
                ),
              ),

              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text("VAULT IS EMPTY", style: TextStyle(color: Colors.white24, letterSpacing: 2)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(15),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 250,
                          childAspectRatio: 2.2, 
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final rarity = Rarity.values.firstWhere((e) => e.name == item['rarity']);
                          // Hero tags must be unique even if items have the same name
                          final String heroTag = "treasure_${item['name']}_${item['rarity']}_$index";

                          return Hero(
                            tag: heroTag,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => TreasureDetailScreen(item: item, rarity: rarity, heroTag: heroTag))
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: rarity.color.withAlpha(15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: rarity.color.withAlpha(60), width: 1.5),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 12),
                                      Icon(Icons.token, color: rarity.color, size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
                                            Text("${rarity.value}c", style: TextStyle(color: rarity.color.withAlpha(180), fontSize: 11, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => Navigator.pop(context), 
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white38), 
                label: const Text("CLOSE VAULT", style: TextStyle(color: Colors.white38))
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class TreasureDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  final Rarity rarity;
  final String heroTag;

  const TreasureDetailScreen({super.key, required this.item, required this.rarity, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AbyssalBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back), 
                  onPressed: () => Navigator.pop(context)
                ),
              ),
              const Spacer(),
              Hero(
                tag: heroTag,
                child: Material(
                  color: Colors.transparent,
                  child: Icon(Icons.token, color: rarity.color, size: 120),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                item['name'].toUpperCase(), 
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 2)
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: rarity.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: rarity.color.withAlpha(100))
                ),
                child: Text(
                  rarity.name.toUpperCase(), 
                  style: TextStyle(color: rarity.color, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                child: Divider(color: Colors.white10),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  // Handling the JSON description or providing a generic fallback
                  item['description'] ?? "An uncharted treasure recovered from the crushing depths of the abyss. Its properties are yet to be fully understood.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.6, fontStyle: FontStyle.italic),
                ),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.only(bottom: 50),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.black38, 
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.amber.withAlpha(50))
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      "VALUE: ${rarity.value} COINS", 
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, letterSpacing: 1)
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