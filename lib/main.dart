import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'screens/dive_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/stats_screen.dart';
import 'widgets/shared_widgets.dart';
import 'data/database_helper.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const AquanimityApp());
}

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
  int weeklyDepth = 0;
  bool _gayMode = false;

  final List<Color> _rainbowColors = [
    Colors.red, Colors.orange, Colors.yellow, Colors.green,
    Colors.blue, Colors.indigo, Colors.purple,
  ];

  Color _getRainbowColor(int index, Color defaultColor) {
    if (!_gayMode) return defaultColor;
    return _rainbowColors[index % _rainbowColors.length];
  }

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
    "My g-g-generation!",
    "Dive like a pro, or just pretend to be one.",
    "CECIL!",
    "Are you sure?",
    "Yo Taylor I'mma let you finish but this is the best dive of all time!",
    "Aquanimity, assemble!",
    "Yes King!",
    "Please Speed, I need this...",
    "LOCK IN!",
    "YAYYYYYYYY!",
    "Couldn't afford a car so she named her daughter Alexus",
    "This is my last resort.",
    "I am the one who dives.",
    "I hate sand, it's coarse and rough and irritating and it gets everywhere.",
    "JERRY! JERRY! JERRY! JERRY!",
    "Why don't you get a job?",
    "Gotta keep em' separated",
    "Do you have the time?",
    "How dare we speak Merry Christmas",
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
    splashText = splashes[math.Random().nextInt(splashes.length)];
  }

  Future<void> _initializeData() async {
    final dbHelper = DatabaseHelper();
    if (await dbHelper.needsMigration()) {
      await dbHelper.migrateFromSharedPreferences();
    }
    await _loadHistory();
  }

  Future<void> _loadHistory() async {
    final dbHelper = DatabaseHelper();
    if (!mounted) return;
    Map<String, dynamic> stats = await dbHelper.getUserStats();
    setState(() {
      totalMetersSaved = stats['total_depth'] ?? 0;
      totalCoins = stats['total_coins'] ?? 0;
      currentStreak = stats['current_streak'] ?? 0;
      weeklyDepth = stats['weekly_depth'] ?? 0;
    });
    await _refreshStreakNotification(stats);
  }

  Future<void> _refreshStreakNotification(Map<String, dynamic> stats) async {
    final String lastDiveDate = stats['last_dive_date'] ?? '';
    final int streak = stats['current_streak'] ?? 0;

    if (streak > 0 && !_didDiveToday(lastDiveDate)) {
      await NotificationService().scheduleStreakReminder(_nextStreakReminderTime());
    } else {
      await NotificationService().cancelStreakReminder();
    }
  }

  bool _didDiveToday(String lastDiveDate) {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    return lastDiveDate == todayStr;
  }

  DateTime _nextStreakReminderTime() {
    final now = DateTime.now();
    final todayReminder = DateTime(now.year, now.month, now.day, 20, 0);
    if (now.isBefore(todayReminder)) {
      return todayReminder;
    }
    return now.add(const Duration(minutes: 1));
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[900],
          title: const Text('Aquanimity Help Guide', 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _helpSection(Icons.waves, 'Welcome to Aquanimity', 'Dive into the depths of the ocean in this underwater adventure game. Your goal is to explore the abyss and collect treasures while practicing to stay off your devices.', Colors.cyanAccent),
                  const SizedBox(height: 20),
                  _helpSection(Icons.timer, 'Dive Duration', 'Set the duration of your dive in minutes. The longer you dive, the deeper you can go, but be careful - running out of oxygen ends your dive!', Colors.yellowAccent),
                  const SizedBox(height: 20),
                  _helpSection(Icons.subdirectory_arrow_right, 'Launch Sub', 'Start your submarine dive! Control your descent and collect treasures. Watch your oxygen meter and depth gauge.', Colors.cyanAccent[700]!),
                  const SizedBox(height: 20),
                  _helpSection(Icons.inventory, 'Treasure Vault', 'View all the treasures you\'ve collected during your dives. Sell them for coins to upgrade your equipment.', Colors.purpleAccent[700]!),
                  const SizedBox(height: 20),
                  _helpSection(Icons.bar_chart, 'Depth Stats', 'Check your diving statistics, including total depth achieved, weekly progress, and ranking system.', Colors.blueGrey[400]!),
                  const SizedBox(height: 20),
                  _helpSection(Icons.emoji_events, 'Ranking System', 'Climb the ranks from Copper to Champion based on your weekly diving achievements. Rankings reset every Monday.', Colors.amber),
                  const SizedBox(height: 20),
                  _helpSection(Icons.monetization_on, 'Coins & Treasures', 'Earn coins by selling treasures. Use coins to... well, more features coming soon!', Colors.amber),
                  const SizedBox(height: 20),
                  _helpSection(Icons.local_fire_department, 'Streak System', 'Maintain your diving streak by completing successful dives. Don\'t let it break!', Colors.orangeAccent),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it!', style: TextStyle(color: Colors.cyanAccent))),
          ],
        );
      },
    );
  }

  Widget _helpSection(IconData icon, String title, String desc, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color aquaLogo = _getRainbowColor(0, Colors.cyanAccent);
    final Color yellowSplash = _getRainbowColor(1, Colors.yellowAccent);

    return Scaffold(
      body: Stack(
        children: [
          AbyssalBackground(
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OneShotFloat(child: Icon(Icons.waves, color: aquaLogo, size: 50)),
                        OneShotFloat(
                          delayMs: 200,
                          child: Text("AQUANIMITY", 
                            style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 8, color: aquaLogo)),
                        ),
                        OneShotFloat(
                          delayMs: 400,
                          child: Text(splashText, 
                            style: TextStyle(color: yellowSplash, fontWeight: FontWeight.bold, fontSize: 16, shadows: const [Shadow(blurRadius: 10, color: Colors.black)])),
                        ),
                        const SizedBox(height: 40),
                        
                        // RESTORED ORIGINAL STATS DASHBOARD LAYOUT
                        OneShotFloat(
                          delayMs: 600,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: aquaLogo.withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              children: [
                                Text("LOGBOOK TOTAL", style: TextStyle(color: _getRainbowColor(3, aquaLogo), fontSize: 14)),
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
                        Text("Dive Duration (Mins):", style: TextStyle(color: _getRainbowColor(4, Colors.white60), fontSize: 12)),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: _timeController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: aquaLogo),
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: aquaLogo)),
                              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        _menuButton("LAUNCH SUB", Colors.cyanAccent[700]!, () async {
                          int mins = int.tryParse(_timeController.text) ?? 5;
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => DiveScreen(durationMinutes: mins == 0 ? -1 : mins)));
                          if (mounted) _loadHistory(); 
                        }, 7),
                        _menuButton("TREASURE VAULT", Colors.purpleAccent[700]!, () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryScreen()));
                          if (mounted) _loadHistory(); 
                        }, 8),
                        _menuButton("DEPTH STATS", Colors.blueGrey[800]!, () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => const StatsScreen()));
                          if (mounted) _loadHistory(); 
                        }, 9),

                        if (weeklyDepth >= 30000)
                          _menuButton("GAY MODE", Colors.pinkAccent, () {
                            setState(() => _gayMode = !_gayMode);
                          }, 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white70, size: 30),
              onPressed: _showHelpDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton(String text, Color color, VoidCallback pressed, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 30, right: 30),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _gayMode ? _rainbowColors[index % _rainbowColors.length] : color, 
            foregroundColor: Colors.white, 
            padding: const EdgeInsets.symmetric(vertical: 22),
          ),
          onPressed: pressed,
          child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
        ),
      ),
    );
  }
}