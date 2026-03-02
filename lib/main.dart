import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

// Importing loot data
import 'loot_data.dart';

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

// --- PDA NOTIFICATION WIDGET ---
class PDANotification extends StatelessWidget {
  final String message;
  final Color color;
  final bool visible;

  const PDANotification({
    super.key,
    required this.message,
    required this.color,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      top: visible ? 60 : -120,
      left: 20,
      right: 20,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(230),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
            boxShadow: [BoxShadow(color: color.withAlpha(80), blurRadius: 15)],
          ),
          child: Row(
            mainAxisSize: minAxisSize,
            children: [
              Icon(Icons.sensors, color: color, size: 24),
              const SizedBox(width: 15),
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  MainAxisSize get minAxisSize => MainAxisSize.min;
}

// --- IMPROVED TREASURE SYSTEM ---
enum Rarity {
  common(Colors.grey, 10),
  uncommon(Colors.greenAccent, 40),
  rare(Colors.blueAccent, 125),
  epic(Colors.purpleAccent, 450),
  legendary(Colors.amber, 1750),
  mythic(Colors.redAccent, 5000);

  final Color color;
  final int value;
  const Rarity(this.color, this.value);
}

class Treasure {
  final String name;
  final Rarity rarity;

  Treasure(this.name, this.rarity);

  static Treasure generate(int depth) {
    final random = math.Random();

    final Map<Rarity, double> weights = {
      // Mythic: Only after 900m
      Rarity.mythic: (depth >= 900) ? 1.0 + (depth / 60) : 0.0,
      // Legendary: Only after 600m
      Rarity.legendary: (depth >= 600) ? 2.0 + (depth / 60) : 0.0,
      // Epic: Only after 350m
      Rarity.epic: (depth >= 350) ? 5.0 + (depth / 50) : 0.0,
      // Rare: Always available (acts as the new "Common" in the deep)
      Rarity.rare: (depth >= 1200) ? 0.0 : 10.0 + (depth / 40),
      // Uncommon: DISAPPEARS after 1000m
      Rarity.uncommon: (depth >= 1000) ? 0.0 : math.max(10.0, 40.0 + (depth / 20) - (depth / 15)),
      // Common: DISAPPEARS after 600m
      Rarity.common: (depth >= 600) ? 0.0 : math.max(5.0, 150.0 - (depth / 5)),
    };

    double totalWeight = weights.values.fold(0.0, (sum, w) => sum + w);
    double roll = random.nextDouble() * totalWeight;

    double cursor = 0;
    for (Rarity r in Rarity.values) {
      cursor += weights[r]!;
      if (roll < cursor) {
        return Treasure(_getItemName(r), r);
      }
    }
    return Treasure("Rusty Anchor", Rarity.common);
  }

  static String _getItemName(Rarity rarity) {
    final list = treasurePool[rarity] ?? ["Strange Object"];
    return list[math.Random().nextInt(list.length)];
  }

  Map<String, String> toMap() => {'name': name, 'rarity': rarity.name};
}

class AbyssalBackground extends StatelessWidget {
  final Widget child;
  const AbyssalBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [Color(0xFF001D3D), Colors.black],
          stops: [0.0, 0.8],
        ),
      ),
      child: child,
    );
  }
}

// --- HELPER WRAPPER FOR FLOATING ANIMATION ---
class OneShotFloat extends StatelessWidget {
  final Widget child;
  final double offset;
  final int delayMs;
  const OneShotFloat({super.key, required this.child, this.offset = 30.0, this.delayMs = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: UniqueKey(),
      tween: Tween(begin: offset, end: 0.0),
      duration: Duration(milliseconds: 800 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Opacity(
            opacity: (1 - (value / offset)).clamp(0, 1),
            child: child,
          ),
        );
      },
      child: child,
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

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      totalMetersSaved = prefs.getInt('total_depth') ?? 0;
      totalCoins = prefs.getInt('total_coins') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  OneShotFloat(
                    delayMs: 600,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(13),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.cyanAccent.withAlpha(100)),
                      ),
                      child: Column(
                        children: [
                          const Text("LOGBOOK TOTAL", style: TextStyle(color: Colors.cyanAccent, fontSize: 14)),
                          Text("$totalMetersSaved m", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                          const Divider(color: Colors.white10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                              const SizedBox(width: 8),
                              Text("$totalCoins Coins", style: const TextStyle(fontSize: 18, color: Colors.amber, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Dive Duration (Mins):", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _timeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent))),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _menuButton("LAUNCH SUB", Colors.cyanAccent[700]!, () async {
                    int mins = int.tryParse(_timeController.text) ?? 5;
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => DiveScreen(durationMinutes: mins == 0 ? -1 : mins)));
                    if (context.mounted) { _loadHistory(); setState(() {}); }
                  }),
                  _menuButton("TREASURE VAULT", Colors.purpleAccent[700]!, () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryScreen()));
                    if (context.mounted) { _loadHistory(); setState(() {}); }
                  }),
                  _menuButton("DEPTH STATS", Colors.blueGrey[800]!, () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const StatsScreen()));
                    if (context.mounted) setState(() {}); 
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
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 22)),
        onPressed: pressed,
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ VIBRATING: THE BENDS!")));
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) { Vibration.vibrate(pattern: [0, 500, 200, 500]); }
    stopDive(wasforced: true);
  }

  void _triggerPDA(String message, Color color) async {
    pdaDismissTimer?.cancel();
    setState(() { pdaMessage = message; pdaColor = color; showPDA = true; });
    if (await Vibration.hasVibrator()) { Vibration.vibrate(duration: 100); }
    pdaDismissTimer = Timer(const Duration(seconds: 5), () { if (mounted) setState(() => showPDA = false); });
  }

  void startDive() {
    int testMultiplier = 20;
    setState(() { isDiving = true; secondsPassed = 0; statusMessage = "DESCENT INITIATED"; reachedMilestones.clear(); });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        secondsPassed += testMultiplier;
        if (secondsPassed == 350 && !reachedMilestones.contains(350)) { _triggerPDA("EPIC TIER REACHED: DISCOVERING NEW SIGNATURES", Colors.purpleAccent); reachedMilestones.add(350); }
        else if (secondsPassed == 600 && !reachedMilestones.contains(600)) { _triggerPDA("LEGENDARY TREASURE FOUND ON SCANNER: COMMON SIGNATURES FADING", Colors.amber); reachedMilestones.add(600); }
        else if (secondsPassed == 900 && !reachedMilestones.contains(900)) { _triggerPDA("MYTHIC TIER REACHED: ECOLOGICAL DATA REQUIRED", Colors.redAccent); reachedMilestones.add(900); }
        else if (secondsPassed == 1000 && !reachedMilestones.contains(1000)) { _triggerPDA("WARNING: UNCHARTED WATERS REACHED. NO UNCOMMON SIGNATURES DETECTED", const Color.fromARGB(255, 59, 44, 143)); reachedMilestones.add(1000); }
        else if (secondsPassed == 1200 && !reachedMilestones.contains(1200)) { _triggerPDA("WARNING: UNSEEN DEPTHS AHEAD. RARE SIGNATURES FADING", const Color.fromARGB(255, 33, 25, 73)); reachedMilestones.add(1200); }
        if (widget.durationMinutes > 0 && secondsPassed >= (widget.durationMinutes * 60)) stopDive();
      });
    });
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
      await prefs.setInt('total_depth', (prefs.getInt('total_depth') ?? 0) + finalDepth);
      await prefs.setInt('successful_dives', (prefs.getInt('successful_dives') ?? 0) + 1);
      foundLoot = Treasure.generate(finalDepth);
      List<String> inventory = prefs.getStringList('treasure_inventory') ?? [];
      isDuplicate = inventory.any((itemJson) => jsonDecode(itemJson)['name'] == foundLoot!.name);
      if (isDuplicate) { coinReward = foundLoot.rarity.value; await prefs.setInt('total_coins', (prefs.getInt('total_coins') ?? 0) + coinReward); }
      else { inventory.add(jsonEncode(foundLoot.toMap())); await prefs.setStringList('treasure_inventory', inventory); }
    } else if (wasforced) {
      await prefs.setInt('forfeit_dives', (prefs.getInt('forfeit_dives') ?? 0) + 1);
      await prefs.setInt('meters_lost', (prefs.getInt('meters_lost') ?? 0) + finalDepth);
      int currentTotal = prefs.getInt('total_depth') ?? 0;
      await prefs.setInt('total_depth', (currentTotal - finalDepth).clamp(0, 9999999));
    }

    if (!mounted) return;
    setState(() { isDiving = false; statusMessage = wasforced ? "HULL BREACH: THE BENDS" : "DIVE LOGGED: $finalDepth m"; });

    if (isSuccessful) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => MissionReportScreen(depth: finalDepth, loot: foundLoot, coinReward: coinReward, isDuplicate: isDuplicate))).then((_) {
          if (mounted) setState(() => secondsPassed = 0);
        });
      });
    } else if (wasforced) { setState(() => secondsPassed = 0); }
  }

  @override
  Widget build(BuildContext context) {
    String targetDisplay = widget.durationMinutes == -1 ? "ENDLESS" : "${widget.durationMinutes * 60}m";
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color.lerp(Colors.blue[900], Colors.black, (secondsPassed / 1000).clamp(0, 1)),
      body: SafeArea(
        child: Stack(
          children: [
            PDANotification(message: pdaMessage, color: pdaColor, visible: showPDA),
            
            // Back Button
            if (!isDiving) 
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

            // Submarine Animation
            AnimatedPositioned(
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeInOutCubic,
              top: isDiving ? screenHeight : screenHeight * 0.15,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _subFloatController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, isDiving ? 0 : _subFloatController.value * 15),
                    child: Column(
                      children: [
                        Icon(Icons.directions_boat, color: Colors.cyanAccent.withAlpha(isDiving ? 100 : 255), size: 60),
                        if (!isDiving) const Icon(Icons.keyboard_double_arrow_down, color: Colors.cyanAccent, size: 20),
                      ],
                    ),
                  );
                },
              ),
            ),

            Positioned(top: 20, left: 60, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("TARGET DEPTH", style: TextStyle(fontSize: 10, color: Colors.cyanAccent, letterSpacing: 1)),
              Text(targetDisplay, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ])),

            if (isDiving) Positioned(top: 20, right: 20, child: AnimatedBuilder(animation: _radarController, builder: (context, child) => Transform.rotate(angle: _radarController.value * 2 * math.pi, child: Icon(Icons.track_changes, color: Colors.cyanAccent.withAlpha(128), size: 40)))),
            
            Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("$secondsPassed m", style: TextStyle(fontSize: 90, fontWeight: FontWeight.w100, color: Colors.cyanAccent, shadows: [Shadow(blurRadius: 20, color: Colors.cyanAccent.withAlpha(128))])),
              Text(statusMessage.toUpperCase(), style: const TextStyle(letterSpacing: 2)),
              const SizedBox(height: 80),
              if (!isDiving && secondsPassed == 0) ElevatedButton(onPressed: startDive, child: const Text("ENGAGE ENGINES")),
              if (isDiving) OutlinedButton(onPressed: () => stopDive(), child: const Text("INITIATE ASCENT")),
              if (!isDiving && secondsPassed > 0) TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text("BACK TO SHIP")),
            ])),
          ],
        ),
      ),
    );
  }
}

class MissionReportScreen extends StatelessWidget {
  final int depth;
  final Treasure? loot;
  final int coinReward;
  final bool isDuplicate;
  const MissionReportScreen({super.key, required this.depth, this.loot, this.coinReward = 0, this.isDuplicate = false});

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
                  OneShotFloat(delayMs: 600, child: Text(isDuplicate ? "STALE DATA DETECTED" : "NEW SIGNAL ACQUIRED", style: TextStyle(color: isDuplicate ? Colors.amber : loot!.rarity.color, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2))),
                  const SizedBox(height: 15),
                  OneShotFloat(delayMs: 700, child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: loot!.rarity.color.withAlpha(20), borderRadius: BorderRadius.circular(15), border: Border.all(color: loot!.rarity.color.withAlpha(100), width: 2)),
                      child: Column(children: [
                        Icon(isDuplicate ? Icons.monetization_on : Icons.inventory_2, size: 60, color: isDuplicate ? Colors.amber : loot!.rarity.color),
                        const SizedBox(height: 10),
                        Text(loot!.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(loot!.rarity.name.toUpperCase(), style: TextStyle(color: loot!.rarity.color, fontSize: 12, fontWeight: FontWeight.bold)),
                      ]),
                  )),
                ],
                if (isDuplicate) OneShotFloat(delayMs: 800, child: Text("+$coinReward COINS ADDED", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))),
                const SizedBox(height: 50),
                OneShotFloat(delayMs: 900, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent[700], padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20)), onPressed: () => Navigator.pop(context), child: const Text("RETURN TO SHIP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _reportRow(String label, String value, Color color) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
      Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
    ]);
  }
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Map<String, dynamic>> items = [];
  int totalCoins = 0;
  @override
  void initState() { super.initState(); _loadInventory(); }
  Future<void> _loadInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedItems = prefs.getStringList('treasure_inventory') ?? [];
    setState(() { items = savedItems.map((item) => jsonDecode(item) as Map<String, dynamic>).toList().reversed.toList(); totalCoins = prefs.getInt('total_coins') ?? 0; });
  }
  Future<bool?> _showConfirmDialog(Map<String, dynamic> item, Color color) {
    final rarity = Rarity.values.firstWhere((e) => e.name == item['rarity']);
    return showDialog<bool>(context: context, builder: (context) => AlertDialog(
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(side: BorderSide(color: color), borderRadius: BorderRadius.circular(20)),
      title: Text("SELL ITEM?", style: TextStyle(color: color)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [Text(item['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text("VALUE: ${rarity.value} COINS", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))]),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () => Navigator.pop(context, true), child: const Text("SELL"))],
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AbyssalBackground(
        child: SafeArea(
          child: Column(children: [
            const OneShotFloat(child: Padding(padding: EdgeInsets.only(top: 20), child: Icon(Icons.inventory_2, color: Colors.purpleAccent, size: 50))),
            const OneShotFloat(delayMs: 200, child: Text("TREASURE VAULT", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 4))),
            OneShotFloat(delayMs: 300, child: Text("$totalCoins Coins", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            Expanded(child: items.isEmpty ? const Center(child: Text("Vault is empty.")) : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final rarity = Rarity.values.firstWhere((e) => e.name == item['rarity']);
                return OneShotFloat(delayMs: 100 * index.clamp(0, 5), child: Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (dir) => _showConfirmDialog(item, rarity.color),
                  onDismissed: (dir) async {
                    final prefs = await SharedPreferences.getInstance();
                    setState(() { items.removeAt(index); totalCoins += rarity.value; });
                    await prefs.setStringList('treasure_inventory', items.reversed.map((i) => jsonEncode(i)).toList());
                    await prefs.setInt('total_coins', totalCoins);
                  },
                  background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: Colors.redAccent.withAlpha(100), child: const Icon(Icons.delete_forever)),
                  child: Container(margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5), decoration: BoxDecoration(color: rarity.color.withAlpha(20), borderRadius: BorderRadius.circular(15), border: Border.all(color: rarity.color.withAlpha(80))), child: ListTile(leading: Icon(Icons.stars, color: rarity.color), title: Text(item['name']), subtitle: Text(item['rarity'].toUpperCase(), style: TextStyle(color: rarity.color, fontSize: 10)))),
                ));
              },
            )),
            TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text("BACK TO SHIP")),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int success = 0, forfeit = 0, lost = 0, totalDepth = 0;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { success = prefs.getInt('successful_dives') ?? 0; forfeit = prefs.getInt('forfeit_dives') ?? 0; lost = prefs.getInt('meters_lost') ?? 0; totalDepth = prefs.getInt('total_depth') ?? 0; });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AbyssalBackground(
        child: SafeArea(
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const OneShotFloat(child: Icon(Icons.analytics, color: Colors.blueAccent, size: 50)),
            const OneShotFloat(delayMs: 200, child: Text("STATISTICS", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 8))),
            const SizedBox(height: 20),
            OneShotFloat(delayMs: 200, child: _buildStatCard("TOTAL DIVE ATTEMPTS:", "${success + forfeit}", Colors.white70)),
            OneShotFloat(delayMs: 400, child: _buildStatCard("SUCCESSFUL EXPEDITIONS", "$success", Colors.greenAccent)),
            OneShotFloat(delayMs: 600, child: _buildStatCard("SUCCESSFUL DEPTH", "$totalDepth m", Colors.greenAccent)),
            OneShotFloat(delayMs: 800, child: _buildStatCard("HULL BREACHES", "$forfeit", Colors.orangeAccent)),
            OneShotFloat(delayMs: 1000, child: _buildStatCard("METERS LOST TO SEA", "$lost m", Colors.redAccent)),
            const SizedBox(height: 40),
            TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text("BACK TO SHIP")),
          ])),
        ),
      ),
    );
  }
  Widget _buildStatCard(String label, String value, Color color) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20), margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), width: double.infinity, decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withAlpha(128))),
    child: Column(children: [Text(label, style: TextStyle(color: color, fontSize: 14)), Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold))]));
  }
}