import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/shared_widgets.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int success = 0, forfeit = 0, lost = 0, totalDepth = 0, currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // These keys should match what we use in DiveScreen
      success = prefs.getInt('successful_dives') ?? 0;
      forfeit = prefs.getInt('forfeit_dives') ?? 0;
      lost = prefs.getInt('meters_lost') ?? 0;
      totalDepth = prefs.getInt('total_depth') ?? 0;
      currentStreak = prefs.getInt('current_streak') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AbyssalBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const OneShotFloat(
                child: Icon(Icons.analytics_outlined, color: Colors.cyanAccent, size: 40)
              ),
              const OneShotFloat(
                delayMs: 200, 
                child: Text("LOGBOOK", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 6))
              ),
              const SizedBox(height: 20),

              // Streak Indicator
              OneShotFloat(
                delayMs: 300,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orangeAccent.withAlpha(100)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.whatshot, color: Colors.orangeAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "$currentStreak DAY STREAK", 
                        style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, letterSpacing: 1)
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Column(
                    children: [
                      // --- FIRST ROW ---
                      Row(
                        children: [
                          Expanded(
                            child: OneShotFloat(
                              delayMs: 400, 
                              child: _buildStatCard("TOTAL DEPTH", "$totalDepth m", Colors.cyanAccent)
                            ),
                          ),
                          Expanded(
                            child: OneShotFloat(
                              delayMs: 500, 
                              child: _buildStatCard("SUCCESSFUL", "$success", Colors.greenAccent)
                            ),
                          ),
                        ],
                      ),
                      
                      // --- SECOND ROW ---
                      Row(
                        children: [
                          Expanded(
                            child: OneShotFloat(
                              delayMs: 600, 
                              child: _buildStatCard("BREACHES", "$forfeit", Colors.redAccent)
                            ),
                          ),
                          Expanded(
                            child: OneShotFloat(
                              delayMs: 700, 
                              child: _buildStatCard("DATA LOST", "$lost m", Colors.white38)
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      const Text(
                        "CAPTAIN'S LOG: VERIFIED", 
                        style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2)
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context), 
                  icon: const Icon(Icons.arrow_back, color: Colors.white60, size: 18), 
                  label: const Text("BACK TO SHIP", style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold))
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      // Height set to ensure all boxes are identical even if text wraps
      height: 110, 
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      margin: const EdgeInsets.all(6), // Consistent spacing between boxes
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withAlpha(60), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label, 
            textAlign: TextAlign.center, 
            maxLines: 2,
            style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2)
          ),
          const SizedBox(height: 8),
          FittedBox( // Prevents large numbers from breaking the box layout
            fit: BoxFit.scaleDown,
            child: Text(
              value, 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'monospace')
            ),
          ),
        ],
      ),
    );
  }
}