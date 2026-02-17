import 'dart:async';
import 'dart:convert';
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

// --- TREASURE SYSTEM ---
enum Rarity { common, uncommon, rare, epic, legendary, mythic }

class Treasure {
  final String name;
  final Rarity rarity;
  final Color color;

  Treasure(this.name, this.rarity, this.color);

  static Color getColor(String rarityName) {
    switch (rarityName) {
      case 'mythic': return Colors.redAccent;
      case 'legendary': return Colors.amber;
      case 'epic': return Colors.purpleAccent;
      case 'rare': return Colors.blueAccent;
      case 'uncommon': return Colors.greenAccent;
      default: return Colors.grey;
    }
  }

  static Treasure generate(int depth) {
    final random = math.Random();
    double commonW = 100.0;
    double uncommonW = 50.0 + (depth / 10);
    double rareW = 20.0 + (depth / 5);
    double epicW = 5.0 + (depth / 2);
    double legendaryW = 1.0 + (depth / 1.5);
    double mythicW = 0.1 + (depth / 1);

    double totalWeight = commonW + uncommonW + rareW + epicW + legendaryW + mythicW;
    double roll = random.nextDouble() * totalWeight;

    if (roll < mythicW) return Treasure("Abyssal Relic", Rarity.mythic, Colors.redAccent);
    if (roll < mythicW + legendaryW) return Treasure("Golden Trident", Rarity.legendary, Colors.amber);
    if (roll < mythicW + legendaryW + epicW) return Treasure("Pearl of Atlas", Rarity.epic, Colors.purpleAccent);
    if (roll < mythicW + legendaryW + epicW + rareW) return Treasure("Sunken Coin", Rarity.rare, Colors.blueAccent);
    if (roll < mythicW + legendaryW + epicW + rareW + uncommonW) return Treasure("Bio-Luminescent Kelp", Rarity.uncommon, Colors.greenAccent);
    return Treasure("Rusty Anchor", Rarity.common, Colors.grey);
  }

  Map<String, String> toMap() => {'name': name, 'rarity': rarity.name};
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

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.waves, color: Colors.cyanAccent, size: 50),
                const Text("AQUANIMITY", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 8)),
                const SizedBox(height: 40),

                // Stylized Logbook Total
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
                    ],
                  ),
                ),

                const SizedBox(height: 60),
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
                      hintText: "Mins",
                      helperText: "Type '0' for Endless",
                      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(15)),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.cyanAccent), borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent[700], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 22)),
                  onPressed: () async {
                    int mins = int.tryParse(_timeController.text) ?? 5;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DiveScreen(durationMinutes: mins == 0 ? -1 : mins)),
                    );
                    if (context.mounted) _loadHistory();
                  },
                  child: const Text("LAUNCH SUB", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent[700], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 22)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryScreen())),
                  child: const Text("TREASURE VAULT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[800], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 22)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatsScreen())),
                  child: const Text("DEPTH STATS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    if (isDiving && state == AppLifecycleState.paused) _triggerTheBends();
  }

  void _triggerTheBends() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ VIBRATING: THE BENDS!")));
    }
    if (await Vibration.hasVibrator()) { 
      Vibration.vibrate(pattern: [0, 500, 200, 500]);
    }
    stopDive(wasforced: true);
  }

  void startDive() {
    setState(() { isDiving = true; secondsPassed = 0; statusMessage = "DESCENT INITIATED"; });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        secondsPassed++;
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
      inventory.add(jsonEncode(loot.toMap()));
      await prefs.setStringList('treasure_inventory', inventory);

      if (mounted) _showRewardDialog(loot);
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(side: BorderSide(color: treasure.color), borderRadius: BorderRadius.circular(20)),
        title: Text("SUNKEN TREASURE FOUND!", style: TextStyle(color: treasure.color, fontSize: 14, letterSpacing: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2, size: 80, color: treasure.color),
            const SizedBox(height: 20),
            Text(treasure.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: treasure.color.withAlpha(50), borderRadius: BorderRadius.circular(10)),
              child: Text(treasure.rarity.name.toUpperCase(), style: TextStyle(color: treasure.color, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("SALVAGE ITEM", style: TextStyle(color: Colors.white))))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String targetDisplay = widget.durationMinutes == -1 ? "ENDLESS" : "${widget.durationMinutes * 60}m";
    return Scaffold(
      backgroundColor: Color.lerp(Colors.blue[900], Colors.black, (secondsPassed / 1000).clamp(0, 1)),
      body: Stack(
        children: [
          // Target Depth restored
          Positioned(
            top: 50, left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("TARGET DEPTH", style: TextStyle(fontSize: 10, color: Colors.cyanAccent, letterSpacing: 1)),
                Text(targetDisplay, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Radar Animation restored
          if (isDiving)
            Positioned(
              top: 50, right: 20,
              child: AnimatedBuilder(
                animation: _radarController,
                builder: (context, child) => Transform.rotate(
                  angle: _radarController.value * 2 * math.pi,
                  child: Icon(Icons.track_changes, color: Colors.cyanAccent.withAlpha(128), size: 40),
                ),
              ),
            ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glow text restored
                Text("$secondsPassed m", style: TextStyle(fontSize: 90, fontWeight: FontWeight.w100, color: Colors.cyanAccent, shadows: [Shadow(blurRadius: 20, color: Colors.cyanAccent.withAlpha(128))])),
                Text(statusMessage.toUpperCase(), style: const TextStyle(letterSpacing: 2)),
                const SizedBox(height: 80),
                if (!isDiving && secondsPassed == 0) ElevatedButton(onPressed: startDive, child: const Text("ENGAGE ENGINES")),
                if (isDiving) OutlinedButton(onPressed: () => stopDive(), child: const Text("INITIATE ASCENT")),
                if (!isDiving && secondsPassed > 0)
                  TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text("BACK TO SHIP")),
              ],
            ),
          ),
        ],
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

  @override
  void initState() { super.initState(); _loadInventory(); }

  Future<void> _loadInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedItems = prefs.getStringList('treasure_inventory') ?? [];
    setState(() {
      items = savedItems.map((item) => jsonDecode(item) as Map<String, dynamic>).toList().reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF001D3D), Colors.black]),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Icon(Icons.inventory_2, color: Colors.purpleAccent, size: 50),
            const Text("TREASURE VAULT", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 4)),
            const SizedBox(height: 20),
            Expanded(
              child: items.isEmpty 
                ? const Center(child: Text("Vault is empty. Log successful dives."))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final color = Treasure.getColor(item['rarity']);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                          color: color.withAlpha(20),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: color.withAlpha(80)),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.stars, color: color),
                          title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(item['rarity'].toString().toUpperCase(), style: TextStyle(color: color, fontSize: 10, letterSpacing: 1)),
                        ),
                      );
                    },
                  ),
            ),
            TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text("BACK TO SHIP")),
            const SizedBox(height: 20),
          ],
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
    setState(() {
      success = prefs.getInt('successful_dives') ?? 0;
      forfeit = prefs.getInt('forfeit_dives') ?? 0;
      lost = prefs.getInt('meters_lost') ?? 0;
    });
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(128)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF001D3D), Colors.black])),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.analytics, color: Colors.blueAccent, size: 50),
              const Text("STATISTICS", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 8)),
              const SizedBox(height: 40),
              _buildStatCard("SUCCESSFUL EXPEDITIONS", "$success", Colors.greenAccent),
              _buildStatCard("HULL BREACHES", "$forfeit", Colors.orangeAccent),
              _buildStatCard("METERS LOST TO SEA", "$lost m", Colors.redAccent),
              const SizedBox(height: 40),
              TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text("BACK TO SHIP")),
            ],
          ),
        ),
      ),
    );
  }
}