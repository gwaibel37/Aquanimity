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
          content: Text("⚠️ HULL BREACH: EMERGENCY ASCENT DETECTED!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
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
    String imagePath;
    switch (style) {
      case 'Sleek Racer': imagePath = 'assets/boats/sleek_racer.png'; break;
      case 'Armored Beast': imagePath = 'assets/boats/armored_beast.png'; break;
      case 'Mythical Leviathan': imagePath = 'assets/boats/mythical_leviathan.png'; break;
      case 'Ion Cruiser': imagePath = 'assets/boats/ion_cruiser.png'; break;
      case 'Phantom Walker': imagePath = 'assets/boats/phantom_walker.png'; break;
      case 'Deep Navigator': imagePath = 'assets/boats/deep_navigator.png'; break;
      case 'Void Stalker': imagePath = 'assets/boats/void_stalker.png'; break;
      case 'Titan Explorer': imagePath = 'assets/boats/titan_explorer.png'; break;
      case 'Quantum Leap': imagePath = 'assets/boats/quantum_leap.png'; break;
      case 'Abyss Sovereign': imagePath = 'assets/boats/abyss_sovereign.png'; break;
      default: imagePath = 'assets/boats/classic_sub.png';
    }

    Widget boatImage = SizedBox(
      width: 150,
      height: 100,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildFallbackBoat(style),
      ),
    );

    if (!isDiving) {
      return AnimatedBuilder(
        animation: _subFloatController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _subFloatController.value * 8 - 4),
            child: boatImage,
          );
        },
      );
    }
    return boatImage;
  }

  Widget _buildFallbackBoat(String style) {
    final boatColor = _boatColor(style);
    switch (style) {
      case 'Sleek Racer': return _buildSleekRacer(boatColor);
      case 'Armored Beast': return _buildArmoredBeast(boatColor);
      case 'Mythical Leviathan': return _buildLeviathan(boatColor);
      case 'Ion Cruiser': return _buildIonCruiser(boatColor);
      case 'Phantom Walker': return _buildPhantomWalker(boatColor);
      case 'Deep Navigator': return _buildDeepNavigator(boatColor);
      case 'Void Stalker': return _buildVoidStalker(boatColor);
      case 'Titan Explorer': return _buildTitanExplorer(boatColor);
      case 'Quantum Leap': return _buildQuantumLeap(boatColor);
      case 'Abyss Sovereign': return _buildAbyssSovereign(boatColor);
      default: return _buildClassicSub(boatColor);
    }
  }

  Color _boatColor(String style) {
    switch (style) {
      case 'Sleek Racer': return Colors.lightBlueAccent;
      case 'Armored Beast': return Colors.amberAccent.shade200;
      case 'Mythical Leviathan': return Colors.purpleAccent.shade200;
      case 'Ion Cruiser': return Colors.yellowAccent;
      case 'Phantom Walker': return Colors.grey.shade400;
      case 'Deep Navigator': return Colors.blueAccent;
      case 'Void Stalker': return Colors.deepPurple.shade200;
      case 'Titan Explorer': return Colors.orange.shade300;
      case 'Quantum Leap': return Colors.cyanAccent;
      case 'Abyss Sovereign': return Colors.redAccent;
      default: return Colors.cyanAccent;
    }
  }

  Widget _buildClassicSub(Color color) {
    return SizedBox(width: 100, height: 72, child: Stack(alignment: Alignment.center, children: [
      Positioned(bottom: 0, child: Container(width: 90, height: 26, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: color.withAlpha(120), blurRadius: 18, spreadRadius: 4)]))),
      Positioned(top: 8, child: Container(width: 56, height: 28, decoration: BoxDecoration(color: color.withAlpha(220), borderRadius: BorderRadius.circular(14)))),
      Positioned(left: 22, child: Row(children: [_boatPorthole(color), const SizedBox(width: 8), _boatPorthole(color)])),
      Positioned(top: 24, right: 14, child: Container(width: 20, height: 10, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(6)))),
    ]));
  }

  Widget _buildSleekRacer(Color color) {
    return SizedBox(width: 140, height: 72, child: Stack(alignment: Alignment.center, children: [
      Positioned(bottom: 8, child: Container(width: 140, height: 30, decoration: BoxDecoration(color: Colors.blueGrey[900], borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: color.withAlpha(110), blurRadius: 18, spreadRadius: 3)]))),
      Positioned(bottom: 12, child: Container(width: 124, height: 24, decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withAlpha(240), color.withAlpha(160)]), borderRadius: BorderRadius.circular(16)))),
      Positioned(top: 12, left: 14, child: Transform.rotate(angle: -0.15, child: Container(width: 20, height: 26, decoration: BoxDecoration(color: color.withAlpha(220), borderRadius: BorderRadius.circular(10))))),
      Positioned(right: 14, child: Container(width: 28, height: 18, decoration: BoxDecoration(color: color.withAlpha(220), borderRadius: BorderRadius.circular(10)))),
      Positioned(top: 22, child: Container(width: 54, height: 10, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)))),
    ]));
  }

  Widget _buildArmoredBeast(Color color) {
    return SizedBox(width: 150, height: 78, child: Stack(alignment: Alignment.center, children: [
      Positioned(bottom: 6, child: Container(width: 136, height: 32, decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: color.withAlpha(120), blurRadius: 18, spreadRadius: 3)]))),
      Positioned(bottom: 10, child: Container(width: 118, height: 26, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)))),
      Positioned(left: 16, bottom: 18, child: Container(width: 18, height: 18, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(6)))),
      Positioned(right: 18, top: 18, child: Container(width: 26, height: 26, decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withAlpha(180), width: 2)))),
      Positioned(top: 22, child: Container(width: 100, height: 14, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)))),
      Positioned(left: 42, bottom: 12, child: Row(children: [_boatPorthole(color), const SizedBox(width: 6), _boatPorthole(color)])),
    ]));
  }

  Widget _buildLeviathan(Color color) {
    return SizedBox(width: 160, height: 86, child: Stack(alignment: Alignment.center, children: [
      Positioned(bottom: 10, child: Container(width: 140, height: 28, decoration: BoxDecoration(color: Colors.deepPurple[900], borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: color.withAlpha(100), blurRadius: 20, spreadRadius: 3)]))),
      Positioned(bottom: 14, child: Container(width: 120, height: 24, decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withAlpha(240), color.withAlpha(160)]), borderRadius: BorderRadius.circular(28)))),
      Positioned(left: 12, child: Container(width: 22, height: 22, decoration: BoxDecoration(color: color.withAlpha(220), shape: BoxShape.circle))),
      Positioned(right: 8, child: Transform.rotate(angle: 0.4, child: Container(width: 30, height: 16, decoration: BoxDecoration(color: color.withAlpha(220), borderRadius: BorderRadius.circular(12))))),
      Positioned(top: 12, child: Row(mainAxisSize: MainAxisSize.min, children: [_boatEye(), const SizedBox(width: 18), _boatEye()])),
    ]));
  }

  Widget _buildIonCruiser(Color color) {
    return SizedBox(width: 145, height: 75, child: Stack(alignment: Alignment.center, children: [
      Positioned(bottom: 8, child: Container(width: 135, height: 28, decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: color.withAlpha(140), blurRadius: 16, spreadRadius: 4)]))),
      Positioned(bottom: 12, child: Container(width: 120, height: 24, decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withAlpha(220), color.withAlpha(180)]), borderRadius: BorderRadius.circular(14)))),
      Positioned(top: 6, child: Container(width: 50, height: 30, decoration: BoxDecoration(color: color.withAlpha(210), borderRadius: BorderRadius.circular(15)))),
      Positioned(left: 18, top: 14, child: Container(width: 8, height: 16, decoration: BoxDecoration(color: Colors.white.withAlpha(80), borderRadius: BorderRadius.circular(4)))),
      Positioned(right: 18, top: 14, child: Container(width: 8, height: 16, decoration: BoxDecoration(color: Colors.white.withAlpha(80), borderRadius: BorderRadius.circular(4)))),
      Positioned(top: 26, child: Container(width: 60, height: 6, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(3), boxShadow: [BoxShadow(color: color.withAlpha(60), blurRadius: 6)]))),
    ]));
  }

  Widget _buildPhantomWalker(Color color) {
    return SizedBox(width: 155, height: 80, child: Stack(alignment: Alignment.center, children: [
      Positioned(bottom: 10, child: Container(width: 140, height: 26, decoration: BoxDecoration(color: Colors.grey[950], borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: color.withAlpha(60), blurRadius: 12, spreadRadius: 2)]))),
      Positioned(bottom: 14, child: Container(width: 130, height: 20, decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withAlpha(200), color.withAlpha(140)]), borderRadius: BorderRadius.circular(22)))),
      Positioned(top: 8, child: Container(width: 55, height: 32, decoration: BoxDecoration(color: color.withAlpha(180), borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))))),
      Positioned(left: 28, top: 16, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.white.withAlpha(40), shape: BoxShape.circle))),
      Positioned(right: 28, top: 16, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.white.withAlpha(40), shape: BoxShape.circle))),
    ]));
  }

  Widget _buildDeepNavigator(Color color) {
    return SizedBox(width: 150, height: 80, child: Stack(alignment: Alignment.center, children: [
      Positioned(bottom: 8, child: Container(width: 138, height: 30, decoration: BoxDecoration(color: Colors.blueGrey[900], borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: color.withAlpha(130), blurRadius: 18, spreadRadius: 3)]))),
      Positioned(bottom: 12, child: Container(width: 122, height: 26, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)))),
      Positioned(top: 10, child: Container(width: 52, height: 28, decoration: BoxDecoration(color: color.withAlpha(220), borderRadius: BorderRadius.circular(12)))),
      Positioned(left: 24, top: 18, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.white30, shape: BoxShape.circle))),
      Positioned(right: 24, top: 18, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.white30, shape: BoxShape.circle))),
      Positioned(left: 38, bottom: 14, child: Row(children: [_boatPorthole(color), const SizedBox(width: 6), _boatPorthole(color), const SizedBox(width: 6), _boatPorthole(color)])),
    ]));
  }

  Widget _buildVoidStalker(Color color) {
    return SizedBox(width: 160, height: 85, child: Stack(alignment: Alignment.center, children: [
      Positioned(bottom: 8, child: Container(width: 145, height: 32, decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: color.withAlpha(120), blurRadius: 18, spreadRadius: 3)]))),
      Positioned(bottom: 12, child: Container(width: 130, height: 28, decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withAlpha(240), color.withAlpha(160)]), borderRadius: BorderRadius.circular(16)))),
      Positioned(top: 10, child: Transform.rotate(angle: -0.1, child: Container(width: 58, height: 32, decoration: BoxDecoration(color: color.withAlpha(220), borderRadius: BorderRadius.circular(12))))),
      Positioned(left: 14, top: 20, child: Container(width: 16, height: 20, decoration: BoxDecoration(color: Colors.white.withAlpha(100), borderRadius: BorderRadius.circular(8)))),
      Positioned(right: 14, top: 20, child: Container(width: 16, height: 20, decoration: BoxDecoration(color: Colors.white.withAlpha(100), borderRadius: BorderRadius.circular(8)))),
      Positioned(bottom: 16, right: 10, child: Container(width: 12, height: 8, decoration: BoxDecoration(color: Colors.red.withAlpha(150), borderRadius: BorderRadius.circular(4)))),
    ]));
  }

  Widget _buildTitanExplorer(Color color) {
    return SizedBox(width: 170, height: 90, child: Stack(alignment: Alignment.center, children: [
      Positioned(bottom: 8, child: Container(width: 160, height: 35, decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: color.withAlpha(130), blurRadius: 20, spreadRadius: 4)]))),
      Positioned(bottom: 12, child: Container(width: 145, height: 30, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)))),
      Positioned(top: 12, child: Container(width: 60, height: 35, decoration: BoxDecoration(color: color.withAlpha(220), borderRadius: BorderRadius.circular(14)))),
      Positioned(left: 22, top: 20, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.white30, shape: BoxShape.circle))),
      Positioned(right: 22, top: 20, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.white30, shape: BoxShape.circle))),
      Positioned(left: 30, bottom: 16, child: Row(children: [_boatPorthole(color), const SizedBox(width: 8), _boatPorthole(color), const SizedBox(width: 8), _boatPorthole(color), const SizedBox(width: 8), _boatPorthole(color)])),
    ]));
  }

  Widget _buildQuantumLeap(Color color) {
    return SizedBox(width: 150, height: 80, child: Stack(alignment: Alignment.center, children: [
      Positioned(bottom: 10, child: Container(width: 140, height: 28, decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: color.withAlpha(150), blurRadius: 16, spreadRadius: 4)]))),
      Positioned(bottom: 14, child: Container(width: 125, height: 24, decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withAlpha(240), color.withAlpha(160)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)))),
      Positioned(top: 8, child: Container(width: 54, height: 30, decoration: BoxDecoration(color: color.withAlpha(220), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withAlpha(100), width: 1.5)))),
      Positioned(left: 20, top: 16, child: Container(width: 6, height: 16, decoration: BoxDecoration(color: Colors.white.withAlpha(120), borderRadius: BorderRadius.circular(3)))),
      Positioned(right: 20, top: 16, child: Container(width: 6, height: 16, decoration: BoxDecoration(color: Colors.white.withAlpha(120), borderRadius: BorderRadius.circular(3)))),
      Positioned(top: 25, child: Container(width: 70, height: 5, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2), boxShadow: [BoxShadow(color: color.withAlpha(80), blurRadius: 8)]))),
    ]));
  }

  Widget _buildAbyssSovereign(Color color) {
    return SizedBox(width: 170, height: 95, child: Stack(alignment: Alignment.center, children: [
      Positioned(bottom: 10, child: Container(width: 155, height: 35, decoration: BoxDecoration(color: Colors.grey[950], borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: color.withAlpha(120), blurRadius: 22, spreadRadius: 5)]))),
      Positioned(bottom: 14, child: Container(width: 140, height: 30, decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withAlpha(240), color.withAlpha(160)]), borderRadius: BorderRadius.circular(24)))),
      Positioned(top: 10, child: Container(width: 65, height: 38, decoration: BoxDecoration(color: color.withAlpha(220), borderRadius: BorderRadius.circular(16)))),
      Positioned(left: 18, top: 18, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.white.withAlpha(140), shape: BoxShape.circle))),
      Positioned(right: 18, top: 18, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.white.withAlpha(140), shape: BoxShape.circle))),
      Positioned(top: 28, child: Container(width: 50, height: 8, decoration: BoxDecoration(color: Colors.white.withAlpha(100), borderRadius: BorderRadius.circular(4), boxShadow: [BoxShadow(color: color.withAlpha(100), blurRadius: 10)]))),
      Positioned(bottom: 18, left: 20, child: Container(width: 10, height: 4, decoration: BoxDecoration(color: Colors.red.withAlpha(160), borderRadius: BorderRadius.circular(2)))),
      Positioned(bottom: 18, right: 20, child: Container(width: 10, height: 4, decoration: BoxDecoration(color: Colors.red.withAlpha(160), borderRadius: BorderRadius.circular(2)))),
    ]));
  }

  Widget _boatEye() => Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.white.withAlpha(120), blurRadius: 6, spreadRadius: 1)]), child: Center(child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle))));
  Widget _boatPorthole(Color color) => Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle, border: Border.all(color: Colors.white54, width: 1.5)));

  void startDive() {
    setState(() { isDiving = true; secondsPassed = 0; statusMessage = "DESCENT INITIATED"; reachedMilestones.clear(); });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        secondsPassed += 1000000000; // Change Speed here
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
      Map<String, dynamic> currentStats = await dbHelper.getUserStats();
      final todayStr = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
      bool isFirstDiveToday = (currentStats['last_dive_date'] ?? "") != todayStr;
      
      await dbHelper.updateUserStats({
        'total_depth': (currentStats['total_depth'] ?? 0) + finalDepth,
        'weekly_depth': (currentStats['weekly_depth'] ?? 0) + finalDepth,
        'successful_dives': (currentStats['successful_dives'] ?? 0) + 1,
      });
      
      foundLoot = Treasure.generate(finalDepth, guaranteedHighestInBracket: isFirstDiveToday);
      List<Map<String, dynamic>> inventory = await dbHelper.getInventory();
      isDuplicate = inventory.any((item) => item['name'] == foundLoot!.name);
      
      if (isDuplicate) { 
        coinReward = foundLoot.rarity.value; 
        await dbHelper.updateUserStats({'total_coins': (currentStats['total_coins'] ?? 0) + coinReward});
      } else { 
        await dbHelper.addTreasure(foundLoot);
      }
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

    // --- FORCED THEME-INDEPENDENT COLORS ---
    
    // Updated to a brighter, lighter ocean blue (Steel Blue/Light Sea Blue)
    const Color surfaceBlue = Color(0xFF005A9E); 
    
    const Color deepBlack = Colors.black;
    // Lerp background from Blue to Black based on 3000m depth
    final Color backgroundColor = Color.lerp(surfaceBlue, deepBlack, (secondsPassed / 3000).clamp(0.0, 1.0))!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            PDANotification(message: pdaMessage, color: pdaColor, visible: showPDA),
            
            AnimatedPositioned(
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeInOutCubic,
              top: isDiving ? screenHeight : screenHeight * 0.15,
              left: 0, right: 0,
              child: Center(child: _buildBoatWidget(selectedBoatStyle, isDiving)),
            ),

            Positioned(
              top: 20, left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("TARGET", style: TextStyle(fontSize: 10, color: Colors.cyanAccent, letterSpacing: 1)),
                  Text(targetDisplay, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                        child: TextButton.icon(
                          style: TextButton.styleFrom(foregroundColor: Colors.white70),
                          onPressed: () => Navigator.pop(context), 
                          icon: const Icon(Icons.arrow_back, size: 16), 
                          label: const Text("BACK TO SHIP")
                        ),
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