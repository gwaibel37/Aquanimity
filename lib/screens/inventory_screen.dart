import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      items = savedItems.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
      totalCoins = prefs.getInt('total_coins') ?? 0;
      _applySort(); // Initial sort
    });
  }

  void _applySort() {
    setState(() {
      switch (_currentSort) {
        case SortMode.newest:
          // Items are stored in chronological order; show last added first
          items = items.reversed.toList(); 
          break;
        case SortMode.rarity:
          items.sort((a, b) {
            final rA = Rarity.values.firstWhere((e) => e.name == a['rarity']).index;
            final rB = Rarity.values.firstWhere((e) => e.name == b['rarity']).index;
            return rB.compareTo(rA); // Higher index (Mythic) first
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
    // We save the current list state
    await prefs.setStringList('treasure_inventory', items.map((i) => jsonEncode(i)).toList());
    await prefs.setInt('total_coins', totalCoins);
  }

  void _bulkSell(Rarity rarity) {
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
      _saveState();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: rarity.color.withAlpha(200), content: Text("Sold $count ${rarity.name} items for $gain coins!", style: const TextStyle(fontWeight: FontWeight.bold)))
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
              
              // Stats & Sort Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                        const SizedBox(width: 5),
                        Text("$totalCoins", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    // THE SORT BUTTON
                    TextButton.icon(
                      style: TextButton.styleFrom(backgroundColor: Colors.white10, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: _toggleSort,
                      icon: const Icon(Icons.sort, size: 16, color: Colors.cyanAccent),
                      label: Text(_currentSort.name.toUpperCase(), style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              // Bulk Sell Quick-Actions
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
                        backgroundColor: hasItems ? r.color.withAlpha(50) : Colors.transparent,
                        side: BorderSide(color: hasItems ? r.color : Colors.white10),
                        onPressed: hasItems ? () => _bulkSell(r) : null,
                      ),
                    );
                  }).toList(),
                ),
              ),

              // The Compact Grid
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text("NO CARGO DETECTED", style: TextStyle(color: Colors.white24, letterSpacing: 2)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(15),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.8,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final rarity = Rarity.values.firstWhere((e) => e.name == item['rarity']);
                          return Container(
                            decoration: BoxDecoration(
                              color: rarity.color.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: rarity.color.withAlpha(80), width: 1),
                            ),
                            child: ListTile(
                              visualDensity: VisualDensity.compact,
                              leading: Icon(Icons.token, color: rarity.color, size: 16),
                              title: Text(item['name'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
                              subtitle: Text("${rarity.value}c", style: TextStyle(color: rarity.color, fontSize: 9)),
                            ),
                          );
                        },
                      ),
              ),
              
              TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), label: const Text("CLOSE VAULT")),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}