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
            mainAxisSize: MainAxisSize.min,
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
}

// --- IMPROVED TREASURE SYSTEM ---
enum Rarity {
  common(Colors.grey, 15),
  uncommon(Colors.greenAccent, 50),
  rare(Colors.blueAccent, 100),
  epic(Colors.purpleAccent, 200),
  legendary(Colors.amber, 500),
  mythic(Colors.redAccent, 1000);

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

    // Logic: 0 weight until specific depth milestones are met
    final Map<Rarity, double> weights = {
      Rarity.mythic: (depth >= 900) ? 0.05 + (depth / 150) : 0.0,
      Rarity.legendary: (depth >= 600) ? 0.5 + (depth / 80) : 0.0,
      Rarity.epic: (depth >= 350) ? 2.0 + (depth / 40) : 0.0,
      Rarity.rare: 10.0 + (depth / 20),
      Rarity.uncommon: 40.0 + (depth / 10),
      Rarity.common: 150.0, // The baseline anchor
    };

    double totalWeight = weights.values.fold(0, (sum, w) => sum + w);
    double roll = random.nextDouble() * totalWeight;

    double cursor = 0;
    // Iterate through rarities. Checking Common first prevents rare luck early.
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

// --- LIGHTWEIGHT BACKGROUND ---
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

// --- SCREENS ---
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
                  const Icon(Icons.waves, color: Colors.cyanAccent, size: 50),
                  const Text("AQUANIMITY", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 8)),
                  
                  Transform.rotate(
                    angle: -0.1,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(splashText, style: const TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(13),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.cyanAccent.withAlpha(77)),
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
                    if (context.mounted) _loadHistory();
                  }),
                  _menuButton("TREASURE VAULT", Colors.purpleAccent[700]!, () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryScreen()));
                    if (context.mounted) _loadHistory();
                  }),
                  _menuButton("DEPTH STATS", Colors.blueGrey[800]!, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatsScreen()))),
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

class _DiveScreenState extends State<DiveScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  int secondsPassed = 0;
  bool isDiving = false;
  Timer? timer;
  String statusMessage = "Pressure Seals: Nominal";
  late AnimationController _radarController;

  // PDA State
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _radarController.dispose();
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
    if (hasVibrator == true) { 
      Vibration.vibrate(pattern: [0, 500, 200, 500]);
    }
    stopDive(wasforced: true);
  }

  void _triggerPDA(String message, Color color) async {
    pdaDismissTimer?.cancel();
    setState(() {
      pdaMessage = message;
      pdaColor = color;
      showPDA = true;
    });

    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 100);
    }

    pdaDismissTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => showPDA = false);
    });
  }

  void startDive() {
    setState(() { 
      isDiving = true; 
      secondsPassed = 0; 
      statusMessage = "DESCENT INITIATED"; 
      reachedMilestones.clear();
    });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        secondsPassed++;

        // Threshold checks for PDA
        if (secondsPassed == 350 && !reachedMilestones.contains(350)) {
          _triggerPDA("EPIC TIER REACHED: SCANNING NEW SIGNATURES", Colors.purpleAccent);
          reachedMilestones.add(350);
        } else if (secondsPassed == 600 && !reachedMilestones.contains(600)) {
          _triggerPDA("LEGENDARY TIER REACHED: ANOMALOUS MASS DETECTED", Colors.amber);
          reachedMilestones.add(600);
        } else if (secondsPassed == 900 && !reachedMilestones.contains(900)) {
          _triggerPDA("MYTHIC TIER REACHED: ECOLOGICAL DATA REQUIRED", Colors.redAccent);
          reachedMilestones.add(900);
        }

        if (widget.durationMinutes > 0 && secondsPassed >= (widget.durationMinutes * 60)) stopDive(wasforced: false);
      });
    });
  }

  void stopDive({bool wasforced = false}) async {
    timer?.cancel();
    final int finalDepth = secondsPassed;
    final prefs = await SharedPreferences.getInstance();

    bool isSuccessful = !wasforced && (widget.durationMinutes <= 0 || secondsPassed >= (widget.durationMinutes * 60));

    if (isSuccessful) {
      await prefs.setInt('total_depth', (prefs.getInt('total_depth') ?? 0) + finalDepth);
      await prefs.setInt('successful_dives', (prefs.getInt('successful_dives') ?? 0) + 1);

      Treasure loot = Treasure.generate(finalDepth);
      List<String> inventory = prefs.getStringList('treasure_inventory') ?? [];
      
      bool isDuplicate = inventory.any((itemJson) => jsonDecode(itemJson)['name'] == loot.name);

      if (isDuplicate) {
        int coinReward = loot.rarity.value;
        await prefs.setInt('total_coins', (prefs.getInt('total_coins') ?? 0) + coinReward);
        if (mounted) _showDuplicateDialog(loot, coinReward);
      } else {
        inventory.add(jsonEncode(loot.toMap()));
        await prefs.setStringList('treasure_inventory', inventory);
        if (mounted) _showRewardDialog(loot);
      }
    } else if (wasforced) {
      await prefs.setInt('forfeit_dives', (prefs.getInt('forfeit_dives') ?? 0) + 1);
      await prefs.setInt('meters_lost', (prefs.getInt('meters_lost') ?? 0) + finalDepth);
      int currentTotal = prefs.getInt('total_depth') ?? 0;
      await prefs.setInt('total_depth', (currentTotal - finalDepth).clamp(0, 9999999));
    }

    if (mounted) {
      setState(() {
        isDiving = false;
        statusMessage = wasforced ? "HULL BREACH: THE BENDS" : "DIVE LOGGED: $finalDepth m";
        if (wasforced) secondsPassed = 0;
      });
    }
  }

  void _showRewardDialog(Treasure treasure) {
    showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(side: BorderSide(color: treasure.rarity.color), borderRadius: BorderRadius.circular(20)),
      title: Text("SUNKEN TREASURE FOUND!", style: TextStyle(color: treasure.rarity.color, fontSize: 14, letterSpacing: 2)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inventory_2, size: 80, color: treasure.rarity.color),
        const SizedBox(height: 20),
        Text(treasure.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: treasure.rarity.color.withAlpha(50), borderRadius: BorderRadius.circular(10)),
        child: Text(treasure.rarity.name.toUpperCase(), style: TextStyle(color: treasure.rarity.color, fontWeight: FontWeight.bold))),
      ]),
      actions: [Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("SALVAGE ITEM", style: TextStyle(color: Colors.white))))],
    ));
  }

  void _showDuplicateDialog(Treasure treasure, int reward) {
    showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.amber), borderRadius: BorderRadius.circular(20)),
      title: const Text("DUPLICATE SALVAGED", style: TextStyle(color: Colors.amber, fontSize: 14, letterSpacing: 2)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.monetization_on, size: 80, color: Colors.amber),
        const SizedBox(height: 20),
        Text(treasure.name, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        Text("+$reward COINS", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.amber)),
      ]),
      actions: [Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("COLLECT GOLD", style: TextStyle(color: Colors.white))))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    String targetDisplay = widget.durationMinutes == -1 ? "ENDLESS" : "${widget.durationMinutes * 60}m";
    return Scaffold(
      backgroundColor: Color.lerp(Colors.blue[900], Colors.black, (secondsPassed / 1000).clamp(0, 1)),
      body: SafeArea(
        child: Stack(
          children: [
            // PDA OVERLAY
            PDANotification(
              message: pdaMessage,
              color: pdaColor,
              visible: showPDA,
            ),

            if (!isDiving && secondsPassed == 0)
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
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
    setState(() {
      items = savedItems.map((item) => jsonDecode(item) as Map<String, dynamic>).toList().reversed.toList();
      totalCoins = prefs.getInt('total_coins') ?? 0;
    });
  }

  Future<bool?> _showConfirmDialog(Map<String, dynamic> item, Color color) {
    final rarity = Rarity.values.firstWhere((e) => e.name == item['rarity']);
    final value = rarity.value;
    return showDialog<bool>(context: context, builder: (context) => AlertDialog(
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(side: BorderSide(color: color), borderRadius: BorderRadius.circular(20)),
      title: Text("SELL ITEM?", style: TextStyle(color: color)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(item['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text("VALUE: $value COINS", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () => Navigator.pop(context, true), child: const Text("SELL")),
      ],
    ));
  }

  Future<void> _sellItem(int index) async {
    final item = items[index];
    final rarity = Rarity.values.firstWhere((e) => e.name == item['rarity']);
    final sellValue = rarity.value;
    final prefs = await SharedPreferences.getInstance();
    setState(() { items.removeAt(index); totalCoins += sellValue; });
    await prefs.setStringList('treasure_inventory', items.reversed.map((i) => jsonEncode(i)).toList());
    await prefs.setInt('total_coins', totalCoins);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AbyssalBackground(
        child: SafeArea(
          child: Column(children: [
            const SizedBox(height: 20),
            const Icon(Icons.inventory_2, color: Colors.purpleAccent, size: 50),
            const Text("TREASURE VAULT", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 4)),
            Text("$totalCoins Coins", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(child: items.isEmpty ? const Center(child: Text("Vault is empty.")) : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final rarity = Rarity.values.firstWhere((e) => e.name == item['rarity']);
                final color = rarity.color;
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (dir) => _showConfirmDialog(item, color),
                  onDismissed: (dir) => _sellItem(index),
                  background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), decoration: BoxDecoration(color: Colors.redAccent.withAlpha(100), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.delete_forever)),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withAlpha(80))),
                    child: ListTile(leading: Icon(Icons.stars, color: color), title: Text(item['name']), subtitle: Text(item['rarity'].toUpperCase(), style: TextStyle(color: color, fontSize: 10))),
                  ),
                );
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
  int success = 0, forfeit = 0, lost = 0;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { success = prefs.getInt('successful_dives') ?? 0; forfeit = prefs.getInt('forfeit_dives') ?? 0; lost = prefs.getInt('meters_lost') ?? 0; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AbyssalBackground(
        child: SafeArea(
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.analytics, color: Colors.blueAccent, size: 50),
            const Text("STATISTICS", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 8)),
            const SizedBox(height: 20),
            _buildStatCard("SUCCESSFUL EXPEDITIONS", "$success", Colors.greenAccent),
            _buildStatCard("HULL BREACHES", "$forfeit", Colors.orangeAccent),
            _buildStatCard("METERS LOST TO SEA", "$lost m", Colors.redAccent),
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