import 'package:flutter/material.dart';
import '../models/treasure.dart';
import '../widgets/shared_widgets.dart';

class MissionReportScreen extends StatelessWidget {
  final int depth;
  final Treasure? loot;
  final int coinReward;
  final bool isDuplicate;

  const MissionReportScreen({
    super.key,
    required this.depth,
    this.loot,
    this.coinReward = 0,
    this.isDuplicate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AbyssalBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const OneShotFloat(child: Icon(Icons.assignment_turned_in, color: Colors.cyanAccent, size: 40)),
                const OneShotFloat(delayMs: 200, child: Text("MISSION SUMMARY", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 4))),
                const SizedBox(height: 30),
                OneShotFloat(delayMs: 400, child: _reportRow("MAX DEPTH REACHED", "$depth m", Colors.white)),
                const OneShotFloat(delayMs: 500, child: Divider(color: Colors.white10, height: 40)),
                if (loot != null) ...[
                  OneShotFloat(
                    delayMs: 600,
                    child: Text(
                      isDuplicate ? "STALE DATA DETECTED" : "NEW SIGNAL ACQUIRED",
                      style: TextStyle(color: isDuplicate ? Colors.amber : loot!.rarity.color, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(height: 15),
                  OneShotFloat(
                    delayMs: 700,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: loot!.rarity.color.withAlpha(20),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: loot!.rarity.color.withAlpha(100), width: 2),
                      ),
                      child: Column(
                        children: [
                          Icon(isDuplicate ? Icons.monetization_on : Icons.inventory_2, size: 60, color: isDuplicate ? Colors.amber : loot!.rarity.color),
                          const SizedBox(height: 10),
                          Text(loot!.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text(loot!.rarity.name.toUpperCase(), style: TextStyle(color: loot!.rarity.color, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
                if (isDuplicate) 
                  OneShotFloat(delayMs: 800, child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text("+$coinReward COINS ADDED", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  )),
                const SizedBox(height: 50),
                OneShotFloat(
                  delayMs: 900,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent[700],
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("RETURN TO SHIP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _reportRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }
}