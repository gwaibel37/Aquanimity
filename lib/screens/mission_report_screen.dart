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
                const OneShotFloat(
                  child: Icon(
                    Icons.assignment_turned_in,
                    color: Colors.cyanAccent,
                    size: 40,
                  ),
                ),
                const OneShotFloat(
                  delayMs: 200,
                  child: Text(
                    "MISSION SUMMARY",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Mission Stats
                OneShotFloat(
                  delayMs: 400,
                  child: _reportRow(
                    "MAX DEPTH REACHED",
                    "$depth m",
                    Colors.white,
                  ),
                ),
                const OneShotFloat(
                  delayMs: 500,
                  child: Divider(color: Colors.white10, height: 40),
                ),

                if (loot != null) ...[
                  OneShotFloat(
                    delayMs: 600,
                    child: Text(
                      isDuplicate
                          ? "IDENTICAL SIGNATURE DETECTED"
                          : "NEW ARTIFACT SECURED",
                      style: TextStyle(
                        color: isDuplicate ? Colors.amber : loot!.rarity.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Loot Card
                  OneShotFloat(
                    delayMs: 700,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: loot!.rarity.color.withAlpha(15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: loot!.rarity.color.withAlpha(80),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: loot!.rarity.color.withAlpha(30),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            isDuplicate ? Icons.cached : Icons.auto_awesome,
                            size: 50,
                            color: isDuplicate
                                ? Colors.amber
                                : loot!.rarity.color,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            loot!.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            loot!.rarity.name.toUpperCase(),
                            style: TextStyle(
                              color: loot!.rarity.color,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                if (isDuplicate)
                  OneShotFloat(
                    delayMs: 800,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "+$coinReward COINS CREDITED (DUPLICATE)",
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 60),

                OneShotFloat(
                  delayMs: 900,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 20,
                      ),
                      elevation: 10,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "RETURN TO SHIP",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
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
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
