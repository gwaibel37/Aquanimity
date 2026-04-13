import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../models/treasure.dart';
import '../services/notification_service.dart';
import '../widgets/shared_widgets.dart';
import '../data/database_helper.dart';
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
  String selectedBoatStyle = 'default';
  
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
    _loadSelectedBoatStyle();
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

  Future<void> _loadSelectedBoatStyle() async {
    final dbHelper = DatabaseHelper();
    final stats = await dbHelper.getUserStats();
    if (!mounted) return;
    setState(() {
      selectedBoatStyle = stats['selected_boat_style'] as String? ?? 'Classic Sub';
      if (selectedBoatStyle == 'default') selectedBoatStyle = 'Classic Sub';
    });
  }

  Widget _buildBoatWidget(String style, bool isDiving) {
    final boatColor = _boatColor(style);
    switch (style) {
      case 'Sleek Racer':
        return _buildSleekRacer(boatColor);
      case 'Armored Beast':
        return _buildArmoredBeast(boatColor);
      case 'Mythical Leviathan':
        return _buildLeviathan(boatColor);
      default:
        return _buildClassicSub(boatColor);
    }
  }

  Color _boatColor(String style) {
    switch (style) {
      case 'Sleek Racer':
        return Colors.lightBlueAccent;
      case 'Armored Beast':
        return Colors.amberAccent.shade200;
      case 'Mythical Leviathan':
        return Colors.purpleAccent.shade200;
      default:
        return Colors.cyanAccent;
    }
  }

  Widget _buildClassicSub(Color color) {
    return SizedBox(
      width: 100,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 90,
              height: 26,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: color.withAlpha(120), blurRadius: 18, spreadRadius: 4)],
              ),
            ),
          ),
          Positioned(
            top: 8,
            child: Container(
              width: 56,
              height: 28,
              decoration: BoxDecoration(
                color: color.withAlpha(220),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Positioned(
            left: 22,
            child: Row(
              children: [
                _boatPorthole(color),
                const SizedBox(width: 8),
                _boatPorthole(color),
              ],
            ),
          ),
          Positioned(
            top: 24,
            right: 14,
            child: Container(
              width: 20,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleekRacer(Color color) {
    return SizedBox(
      width: 140,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 8,
            child: Container(
              width: 140,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.blueGrey[900],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: color.withAlpha(110), blurRadius: 18, spreadRadius: 3)],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            child: Container(
              width: 124,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color.withAlpha(240), color.withAlpha(160)]),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 14,
            child: Transform.rotate(
              angle: -0.15,
              child: Container(
                width: 20,
                height: 26,
                decoration: BoxDecoration(
                  color: color.withAlpha(220),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Positioned(
            right: 14,
            child: Container(
              width: 28,
              height: 18,
              decoration: BoxDecoration(
                color: color.withAlpha(220),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            top: 22,
            child: Container(
              width: 54,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArmoredBeast(Color color) {
    return SizedBox(
      width: 150,
      height: 78,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 6,
            child: Container(
              width: 136,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: color.withAlpha(120), blurRadius: 18, spreadRadius: 3)],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: Container(
              width: 118,
              height: 26,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 18,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          Positioned(
            right: 18,
            top: 18,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withAlpha(180), width: 2),
              ),
            ),
          ),
          Positioned(
            top: 22,
            child: Container(
              width: 100,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            left: 42,
            bottom: 12,
            child: Row(
              children: [
                _boatPorthole(color),
                const SizedBox(width: 6),
                _boatPorthole(color),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeviathan(Color color) {
    return SizedBox(
      width: 160,
      height: 86,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 10,
            child: Container(
              width: 140,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.deepPurple[900],
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: color.withAlpha(100), blurRadius: 20, spreadRadius: 3)],
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            child: Container(
              width: 120,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color.withAlpha(240), color.withAlpha(160)]),
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          Positioned(
            left: 12,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: color.withAlpha(220),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 8,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: 30,
                height: 16,
                decoration: BoxDecoration(
                  color: color.withAlpha(220),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _boatEye(),
                const SizedBox(width: 18),
                _boatEye(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _boatEye() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.white.withAlpha(120), blurRadius: 6, spreadRadius: 1)],
      ),
      child: Center(
        child: Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _boatPorthole(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white54, width: 1.5),
      ),
    );
  }

  void startDive() {
    int testMultiplier = 100000000; 
    setState(() { isDiving = true; secondsPassed = 0; statusMessage = "DESCENT INITIATED"; reachedMilestones.clear(); });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        secondsPassed += testMultiplier;
        
        if (secondsPassed >= 350 && !reachedMilestones.contains(350)) {
          _triggerPDA("EPIC TIER REACHED: NEW SIGNATURES", Colors.purpleAccent);
          NotificationService().showNotification(201, "Dive Milestone", "Epic tier reached at $secondsPassed m.");
          reachedMilestones.add(350);
        } else if (secondsPassed >= 600 && !reachedMilestones.contains(600)) {
          _triggerPDA("LEGENDARY SIGNALS DETECTED", Colors.amber);
          NotificationService().showNotification(202, "Dive Milestone", "Legendary signals detected at $secondsPassed m.");
          reachedMilestones.add(600);
        }

        if (widget.durationMinutes > 0 && secondsPassed >= (widget.durationMinutes * 60)) stopDive();
      });
    });
  }

  Future<void> _updateStreak(DatabaseHelper dbHelper, Map<String, dynamic> currentStats) async {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayStr = "${yesterday.year}-${yesterday.month}-${yesterday.day}";

    String lastDate = currentStats['last_dive_date'] ?? "";
    int currentStreak = currentStats['current_streak'] ?? 0;

    if (lastDate == todayStr) return; 
    
    if (lastDate == yesterdayStr || lastDate == "") {
      currentStreak++; 
    } else {
      currentStreak = 1; 
    }

    await dbHelper.updateUserStats({
      'last_dive_date': todayStr,
      'current_streak': currentStreak,
    });
  }

  Future<void> stopDive({bool wasforced = false}) async {
    timer?.cancel();
    timer = null;
    final int finalDepth = secondsPassed;
    final dbHelper = DatabaseHelper();
    
    Treasure? foundLoot;
    int coinReward = 0;
    bool isDuplicate = false;
    bool isSuccessful = !wasforced && (widget.durationMinutes <= 0 || secondsPassed >= (widget.durationMinutes * 60));

    if (isSuccessful) {
      // Get current stats
      Map<String, dynamic> currentStats = await dbHelper.getUserStats();
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month}-${now.day}";
      bool isFirstDiveToday = (currentStats['last_dive_date'] ?? "") != todayStr;
      
      // 1. Log Depths
      int newTotalDepth = (currentStats['total_depth'] ?? 0) + finalDepth;
      int newWeeklyDepth = (currentStats['weekly_depth'] ?? 0) + finalDepth;
      int newSuccessfulDives = (currentStats['successful_dives'] ?? 0) + 1;
      
      await dbHelper.updateUserStats({
        'total_depth': newTotalDepth,
        'weekly_depth': newWeeklyDepth,
        'successful_dives': newSuccessfulDives,
      });
      
      await _updateStreak(dbHelper, currentStats);
      await NotificationService().cancelStreakReminder();

      foundLoot = Treasure.generate(finalDepth, guaranteedHighestInBracket: isFirstDiveToday);
      List<Map<String, dynamic>> inventory = await dbHelper.getInventory();
      isDuplicate = inventory.any((item) => item['name'] == foundLoot!.name);
      
      if (isDuplicate) { 
        coinReward = foundLoot.rarity.value; 
        int newTotalCoins = (currentStats['total_coins'] ?? 0) + coinReward;
        await dbHelper.updateUserStats({'total_coins': newTotalCoins});
        NotificationService().showNotification(301, 'Treasure Duplicate', 'Duplicate treasure converted to $coinReward coins.');
      } else { 
        await dbHelper.addTreasure(foundLoot);
        NotificationService().showNotification(302, 'Sunken Treasure Found!', 'You recovered ${foundLoot.name} (${foundLoot.rarity.name.toUpperCase()}).');
      }
    } else if (wasforced) {
      Map<String, dynamic> currentStats = await dbHelper.getUserStats();
      int currentTotal = currentStats['total_depth'] ?? 0;
      int newTotalDepth = (currentTotal - (finalDepth * 2)).clamp(0, 9999999);
      int newForfeitDives = (currentStats['forfeit_dives'] ?? 0) + 1;
      await dbHelper.updateUserStats({
        'total_depth': newTotalDepth,
        'forfeit_dives': newForfeitDives,
      });
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
      backgroundColor: Color.lerp(Theme.of(context).colorScheme.primary.withAlpha(180), Theme.of(context).colorScheme.background, (secondsPassed / 3000).clamp(0, 1)),
      body: SafeArea(
        child: Stack(
          children: [
            PDANotification(message: pdaMessage, color: pdaColor, visible: showPDA),
            
            AnimatedPositioned(
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeInOutCubic,
              top: isDiving ? screenHeight : screenHeight * 0.15,
              left: 0, right: 0,
              child: Center(
                child: _buildBoatWidget(selectedBoatStyle, isDiving),
              ),
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