import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

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
  // FIXED: Changed from int to TextEditingController for custom input
  final TextEditingController _timeController = TextEditingController(text: "5");
  int totalMetersSaved = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalMetersSaved = prefs.getInt('total_depth') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF001D3D), Colors.black],
          ),
        ),
        child: Center(
          child: SingleChildScrollView( // Prevents "Bottom Overflow" when keyboard pops up
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.waves, color: Colors.cyanAccent, size: 50),
                const Text("AQUANIMITY", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 8)),
                const SizedBox(height: 40),
                
                // Logbook
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text("LOGBOOK TOTAL", style: TextStyle(color: Colors.cyanAccent, fontSize: 14)),
                      Text("$totalMetersSaved m", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),

                // NEW: Duration Input Field
                const Text("Enter Dive Duration (Minutes):", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _timeController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, color: Colors.cyanAccent),
                    decoration: InputDecoration(
                      hintText: "Enter mins",
                      helperText: "Type '0' for Endless",
                      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(15)),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.cyanAccent), borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 22)
                  ),
                  onPressed: () async {
                    int mins = int.tryParse(_timeController.text) ?? 5;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DiveScreen(durationMinutes: mins == 0 ? -1 : mins)),
                    );
                    _loadHistory();
                  },
                  child: const Text("LAUNCH SUB", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DiveScreen extends StatefulWidget {
  final int durationMinutes;
  const DiveScreen({super.key, required this.durationMinutes});

  @override
  State<DiveScreen> createState() => _DiveScreenState();
}

class _DiveScreenState extends State<DiveScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  int secondsPassed = 0;
  bool isDiving = false;
  Timer? timer;
  String statusMessage = "Pressure Seals: Nominal";
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _radarController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _radarController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (isDiving && state == AppLifecycleState.paused) {
      _triggerTheBends();
    }
  }

  void _triggerTheBends() async {
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ VIBRATING: THE BENDS!"), duration: Duration(seconds: 2))
      );
    }

    bool? hasVib = await Vibration.hasVibrator();
    if (hasVib == true) {
      Vibration.vibrate(pattern: [0, 500, 200, 500]);
    }
    stopDive(wasforced: true);
  }

  void startDive() {
    setState(() {
      isDiving = true;
      secondsPassed = 0;
      statusMessage = "DESCENT INITIATED";
    });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        secondsPassed++;
        if (widget.durationMinutes != -1 && secondsPassed >= (widget.durationMinutes * 60)) {
          stopDive(wasforced: false);
        }
      });
    });
  }

  void stopDive({bool wasforced = false}) async {
    timer?.cancel();
    int finalDepth = secondsPassed;

    if (!wasforced && finalDepth > 0) {
      final prefs = await SharedPreferences.getInstance();
      int currentTotal = prefs.getInt('total_depth') ?? 0;
      await prefs.setInt('total_depth', currentTotal + finalDepth);
    }

    setState(() {
      isDiving = false;
      statusMessage = wasforced ? "HULL BREACH: THE BENDS" : "DIVE LOGGED: $finalDepth m";
      if (wasforced) secondsPassed = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Target depth calculation for the display
    String targetDisplay = widget.durationMinutes == -1 ? "ENDLESS" : "${widget.durationMinutes * 60}m";

    return Scaffold(
      backgroundColor: Color.lerp(Colors.blue[900], Colors.black, (secondsPassed / 1000).clamp(0, 1)),
      body: Stack(
        children: [
          // NEW: Target Depth in top-left corner
          Positioned(
            top: 50,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("TARGET DEPTH", style: TextStyle(fontSize: 10, color: Colors.cyanAccent, letterSpacing: 1)),
                Text(targetDisplay, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          if (isDiving)
            Positioned(
              top: 50,
              right: 20,
              child: AnimatedBuilder(
                animation: _radarController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _radarController.value * 2 * math.pi,
                    child: Icon(Icons.track_changes, color: Colors.cyanAccent.withOpacity(0.5), size: 40),
                  );
                },
              ),
            ),
            
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$secondsPassed m", 
                  style: TextStyle(
                    fontSize: 90, 
                    fontWeight: FontWeight.w100,
                    color: Colors.cyanAccent,
                    shadows: [Shadow(blurRadius: 20, color: Colors.cyanAccent.withOpacity(0.5))]
                  )
                ),
                Text(statusMessage.toUpperCase(), style: const TextStyle(letterSpacing: 2)),
                const SizedBox(height: 80),

                if (!isDiving && secondsPassed == 0)
                  ElevatedButton(onPressed: startDive, child: const Text("ENGAGE ENGINES")),
                  
                if (isDiving)
                  OutlinedButton(onPressed: () => stopDive(), child: const Text("INITIATE ASCENT")),

                if (!isDiving && secondsPassed > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context), 
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("BACK TO SHIP")
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}