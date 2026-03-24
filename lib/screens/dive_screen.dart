import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import '../models/treasure.dart';
import '../widgets/shared_widgets.dart';
import 'mission_report_screen.dart';

class DiveScreen extends StatefulWidget {
  final int durationMinutes;
  const DiveScreen({super.key, required this.durationMinutes});

  @override
  State<DiveScreen> createState() => _DiveScreenState();
}

class _DiveScreenState extends State<DiveScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  int secondsPassed = 0;
  bool isDiving = false;
  Timer? timer;
  String statusMessage = "Pressure Seals: Nominal";
  
  late AnimationController _radarController;
  late AnimationController _subFloatController;
  
  String pdaMessage = "";
  Color pdaColor = Colors.cyanAccent;
  bool showPDA = false;
  Timer? pdaDismissTimer;
  final Set<int> reachedMilestones = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _radarController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _subFloatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _radarController.dispose();
    _subFloatController.dispose();
    timer?.cancel();
    pdaDismissTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (isDiving && state == AppLifecycleState.paused) _triggerTheBends();
  }

  void _triggerTheBends() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("⚠️ HULL BREACH: EMERGENCY ASCENT DETECTED!", style: TextStyle(fontWeight: FontWeight.bold))
        )
      );
    }
    if (await Vibration.hasVibrator()) { 
      Vibration.vibrate(pattern: [0, 500, 200, 500]); 
    }
    stopDive(wasforced: true);
  }

  void _triggerPDA(String message, Color color) async {
    pdaDismissTimer?.cancel();
    if (mounted) setState(() { pdaMessage = message; pdaColor = color; showPDA = true; });
    if (await Vibration.hasVibrator()) { Vibration.vibrate(duration: 100); }
    pdaDismissTimer = Timer(const Duration(seconds: 5), () { if (mounted) setState(() => showPDA = false); });
  }

  void startDive() {
    int testMultiplier = 100000; 
    setState(() { isDiving = true; secondsPassed = 0; statusMessage = "DESCENT INITIATED"; reachedMilestones.clear(); });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        secondsPassed += testMultiplier;
        
        if (secondsPassed >= 350 && !reachedMilestones.contains(350)) {
          _triggerPDA("EPIC TIER REACHED: NEW SIGNATURES", Colors.purpleAccent);
          reachedMilestones.add(350);
        } else if (secondsPassed >= 600 && !reachedMilestones.contains(600)) {
          _triggerPDA("LEGENDARY SIGNALS DETECTED", Colors.amber);
          reachedMilestones.add(600);
        }

        if (widget.durationMinutes > 0 && secondsPassed >= (widget.durationMinutes * 60)) stopDive();
      });
    });
  }

  Future<void> _updateStreak(SharedPreferences prefs) async {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayStr = "${yesterday.year}-${yesterday.month}-${yesterday.day}";

    String lastDate = prefs.getString('last_dive_date') ?? "";
    int currentStreak = prefs.getInt('current_streak') ?? 0;

    if (lastDate == todayStr) return; 
    
    if (lastDate == yesterdayStr || lastDate == "") {
      currentStreak++; 
    } else {
      currentStreak = 1; 
    }

    await prefs.setString('last_dive_date', todayStr);
    await prefs.setInt('current_streak', currentStreak);
  }

  Future<void> stopDive({bool wasforced = false}) async {
    timer?.cancel();
    timer = null;
    final int finalDepth = secondsPassed;
    final prefs = await SharedPreferences.getInstance();
    
    Treasure? foundLoot;
    int coinReward = 0;
    bool isDuplicate = false;
    bool isSuccessful = !wasforced && (widget.durationMinutes <= 0 || secondsPassed >= (widget.durationMinutes * 60));

    if (isSuccessful) {
      // 1. Log Depths
      await prefs.setInt('total_depth', (prefs.getInt('total_depth') ?? 0) + finalDepth);
      // UPDATED: Increment weekly depth for the rank system
      await prefs.setInt('weekly_depth', (prefs.getInt('weekly_depth') ?? 0) + finalDepth);
      
      await _updateStreak(prefs);

      foundLoot = Treasure.generate(finalDepth);
      List<String> inventory = prefs.getStringList('treasure_inventory') ?? [];
      isDuplicate = inventory.any((itemJson) => jsonDecode(itemJson)['name'] == foundLoot!.name);
      
      if (isDuplicate) { 
        coinReward = foundLoot.rarity.value; 
        await prefs.setInt('total_coins', (prefs.getInt('total_coins') ?? 0) + coinReward); 
      } else { 
        inventory.add(jsonEncode(foundLoot.toMap())); 
        await prefs.setStringList('treasure_inventory', inventory); 
      }
    } else if (wasforced) {
      int currentTotal = prefs.getInt('total_depth') ?? 0;
      await prefs.setInt('total_depth', (currentTotal - (finalDepth * 2)).clamp(0, 9999999));
    }

    if (!mounted) return;
    setState(() { isDiving = false; statusMessage = wasforced ? "HULL BREACH" : "DIVE LOGGED"; });

    if (isSuccessful) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MissionReportScreen(
        depth: finalDepth, loot: foundLoot, coinReward: coinReward, isDuplicate: isDuplicate
      ))).then((_) { if (mounted) setState(() => secondsPassed = 0); });
    } else {
      setState(() => secondsPassed = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final String targetDisplay = widget.durationMinutes == -1 ? "ENDLESS" : "${widget.durationMinutes * 60}m";

    return Scaffold(
      backgroundColor: Color.lerp(const Color.fromARGB(255, 35, 118, 226), Colors.black, (secondsPassed / 3000).clamp(0, 1)),
      body: SafeArea(
        child: Stack(
          children: [
            PDANotification(message: pdaMessage, color: pdaColor, visible: showPDA),
            
            AnimatedPositioned(
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeInOutCubic,
              top: isDiving ? screenHeight : screenHeight * 0.15,
              left: 0, right: 0,
              child: Icon(Icons.directions_boat, color: Colors.cyanAccent.withAlpha(isDiving ? 50 : 255), size: 60),
            ),

            Positioned(
              top: 20, left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("TARGET", style: TextStyle(fontSize: 10, color: Colors.cyanAccent, letterSpacing: 1)),
                  Text(targetDisplay, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            if (isDiving) 
              Positioned(
                top: 20, right: 20,
                child: AnimatedBuilder(
                  animation: _radarController,
                  builder: (context, child) => Transform.rotate(
                    angle: _radarController.value * 2 * math.pi,
                    child: Icon(Icons.track_changes, color: Colors.cyanAccent.withAlpha(128), size: 40),
                  ),
                ),
              ),

            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$secondsPassed m", 
                      style: TextStyle(
                        fontSize: 80, 
                        fontWeight: FontWeight.w100, 
                        color: Colors.cyanAccent,
                        shadows: [Shadow(blurRadius: 20, color: Colors.cyanAccent.withAlpha(128))]
                      )
                    ),
                    Text(statusMessage.toUpperCase(), style: const TextStyle(letterSpacing: 2, fontSize: 12, color: Colors.white54)),
                    const SizedBox(height: 60),
                    if (!isDiving && secondsPassed == 0) 
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent[700], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                        onPressed: startDive, 
                        child: const Text("ENGAGE ENGINES", style: TextStyle(fontWeight: FontWeight.bold))
                      ),
                    if (isDiving) 
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.cyanAccent), foregroundColor: Colors.cyanAccent, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                        onPressed: () => stopDive(), 
                        child: const Text("INITIATE ASCENT", style: TextStyle(fontWeight: FontWeight.bold))
                      ),
                    if (!isDiving)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, size: 16), label: const Text("BACK TO SHIP")),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}