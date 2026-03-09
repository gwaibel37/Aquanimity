import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/shared_widgets.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int success = 0, forfeit = 0, lost = 0, totalDepth = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      success = prefs.getInt('successful_dives') ?? 0;
      forfeit = prefs.getInt('forfeit_dives') ?? 0;
      lost = prefs.getInt('meters_lost') ?? 0;
      totalDepth = prefs.getInt('total_depth') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AbyssalBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header stays fixed at the top
              const SizedBox(height: 20),
              const OneShotFloat(child: Icon(Icons.analytics, color: Colors.blueAccent, size: 40)),
              const OneShotFloat(
                delayMs: 200, 
                child: Text("STATISTICS", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 6))
              ),
              const SizedBox(height: 10),

              // The scrollable area for stats
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      OneShotFloat(delayMs: 300, child: _buildStatCard("TOTAL DIVE ATTEMPTS", "${success + forfeit}", Colors.white70)),
                      OneShotFloat(delayMs: 400, child: _buildStatCard("SUCCESSFUL EXPEDITIONS", "$success", Colors.greenAccent)),
                      OneShotFloat(delayMs: 500, child: _buildStatCard("SUCCESSFUL DEPTH", "$totalDepth m", Colors.greenAccent)),
                      OneShotFloat(delayMs: 600, child: _buildStatCard("HULL BREACHES", "$forfeit", Colors.orangeAccent)),
                      OneShotFloat(delayMs: 700, child: _buildStatCard("METERS LOST TO SEA", "$lost m", Colors.redAccent)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Footer stays fixed at the bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context), 
                  icon: const Icon(Icons.arrow_back, color: Colors.white60), 
                  label: const Text("BACK TO SHIP", style: TextStyle(color: Colors.white60))
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withAlpha(100), width: 1),
      ),
      child: Column(
        children: [
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}