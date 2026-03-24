import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/dive_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/stats_screen.dart';
import 'widgets/shared_widgets.dart';

void main() => runApp(const AquanimityApp());

class AquanimityApp extends StatelessWidget {
  const AquanimityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
          ),
        ),
      ),
      home: const MenuScreen(),
    );
  }
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _timeController = TextEditingController(text: "5");
  int totalMetersSaved = 0;
  int totalCoins = 0;
  int currentStreak = 0; 
  
  String splashText = "";
  final List<String> splashes = [
    "Better than Michael's Group!",
    "Is water wet?",
    "WE, YES WE, love Gavin",
    "How low can you go?",
    "Searching for Atlantis...",
    "Don't forget to breathe!",
    "Standard issue submarine.",
    "Warning: Wetter than it appears.",
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    splashText = splashes[math.Random().nextInt(splashes.length)];
  }

  // Logic to reset the weekly rank every Monday
  Future<void> _handleWeeklyReset(SharedPreferences prefs) async {
    final now = DateTime.now();
    String lastReset = prefs.getString('last_weekly_reset') ?? "";
    
    // Find the most recent Monday
    DateTime lastMonday = now.subtract(Duration(days: now.weekday - 1));
    String currentMondayStr = "${lastMonday.year}-${lastMonday.month}-${lastMonday.day}";

    if (lastReset != currentMondayStr) {
      int weeklyDepth = prefs.getInt('weekly_depth') ?? 0;
      List<String> history = prefs.getStringList('rank_history') ?? [];
      
      // Archive current progress if there was activity
      if (weeklyDepth > 0) {
        history.add("${now.month}/${now.day} | $weeklyDepth m | ARCHIVED");
        await prefs.setStringList('rank_history', history);
      }
      
      await prefs.setInt('weekly_depth', 0); // Reset for the new week
      await prefs.setString('last_weekly_reset', currentMondayStr);
    }
  }

  // Refreshes the UI by pulling the latest totals from SharedPreferences
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await _handleWeeklyReset(prefs); // Perform reset check on startup

    if (!mounted) return;
    setState(() {
      totalMetersSaved = prefs.getInt('total_depth') ?? 0;
      totalCoins = prefs.getInt('total_coins') ?? 0;
      currentStreak = prefs.getInt('current_streak') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AbyssalBackground provides the thematic dark blue gradient
      body: AbyssalBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const OneShotFloat(child: Icon(Icons.waves, color: Colors.cyanAccent, size: 50)),
                  const OneShotFloat(delayMs: 200, child: Text("AQUANIMITY", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 8))),
                  OneShotFloat(
                    delayMs: 400,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(splashText, style: const TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Stats Dashboard
                  OneShotFloat(
                    delayMs: 600,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        children: [
                          const Text("LOGBOOK TOTAL", style: TextStyle(color: Colors.cyanAccent, fontSize: 14)),
                          Text("$totalMetersSaved m", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                          const Divider(color: Colors.white10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                              const SizedBox(width: 8),
                              Text("$totalCoins", style: const TextStyle(fontSize: 18, color: Colors.amber, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 20),
                              const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 20),
                              const SizedBox(width: 8),
                              Text("$currentStreak", style: const TextStyle(fontSize: 18, color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  const Text("Dive Duration (Mins):", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  
                  // Duration Input
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _timeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  _menuButton("LAUNCH SUB", Colors.cyanAccent[700]!, () async {
                    int mins = int.tryParse(_timeController.text) ?? 5;
                    // Passing -1 for infinite/test mode if mins is 0
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => DiveScreen(durationMinutes: mins == 0 ? -1 : mins)));
                    if (mounted) _loadHistory(); 
                  }),
                  
                  _menuButton("TREASURE VAULT", Colors.purpleAccent[700]!, () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryScreen()));
                    if (mounted) _loadHistory(); // Refresh in case items were sold for coins
                  }),
                  
                  _menuButton("DEPTH STATS", Colors.blueGrey[800]!, () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const StatsScreen()));
                    if (mounted) _loadHistory(); 
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuButton(String text, Color color, VoidCallback pressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color, 
          foregroundColor: Colors.white, 
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 22),
          elevation: 10,
        ),
        onPressed: pressed,
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
    );
  }
}