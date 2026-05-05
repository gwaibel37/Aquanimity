import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/dive_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/vault_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/shared_widgets.dart';
import 'data/database_helper.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const AquanimityApp());
}

class AquanimityApp extends StatefulWidget {
  const AquanimityApp({super.key});

  @override
  State<AquanimityApp> createState() => _AquanimityAppState();
}

class _AquanimityAppState extends State<AquanimityApp> {
  String selectedThemeName = 'default';
  _ThemeColors? customThemeColors;
  String? customBackgroundImagePath;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final stats = await DatabaseHelper().getUserStats();
    if (!mounted) return;
    setState(() {
      selectedThemeName =
          stats['selected_theme'] as String? ?? 'Deep Sea Theme';
      customThemeColors = selectedThemeName == 'Custom Theme'
          ? _loadCustomThemeColors(stats)
          : null;
      customBackgroundImagePath = selectedThemeName == 'Custom Theme'
          ? stats['custom_background_image'] as String?
          : null;
    });
  }

  _ThemeColors? _loadCustomThemeColors(Map<String, dynamic> stats) {
    final primary = stats['custom_theme_primary'] as int?;
    final accent = stats['custom_theme_accent'] as int?;
    final background = stats['custom_theme_background'] as int?;
    final surface = stats['custom_theme_surface'] as int?;

    if (primary != null &&
        accent != null &&
        background != null &&
        surface != null) {
      return _ThemeColors(
        primary: Color(primary),
        accent: Color(accent),
        background: Color(background),
        surface: Color(surface),
      );
    }
    return null;
  }

  void _handleThemeChanged(String themeName) async {
    final stats = await DatabaseHelper().getUserStats();
    setState(() {
      selectedThemeName = themeName;
      customThemeColors = themeName == 'Custom Theme'
          ? _loadCustomThemeColors(stats)
          : null;
      customBackgroundImagePath = themeName == 'Custom Theme'
          ? stats['custom_background_image'] as String?
          : null;
    });
  }

  ThemeData _themeForName(String themeName) {
    final colors = _themeColorsForName(themeName);
    final scheme = ColorScheme.dark(
      surface: colors.surface,
      primary: colors.primary,
      secondary: colors.accent,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
    );
    return ThemeData.from(colorScheme: scheme).copyWith(
      scaffoldBackgroundColor: colors.background,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          backgroundColor: colors.accent,
          foregroundColor: Colors.black,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.accent),
      ),
    );
  }

  _ThemeColors _themeColorsForName(String themeName) {
    switch (themeName) {
      case 'Deep Sea Theme':
        return _ThemeColors(
          primary: const Color.fromARGB(255, 2, 152, 252),
          accent: const Color.fromARGB(255, 230, 255, 2),
          background: const Color.fromARGB(255, 0, 15, 22),
          surface: const Color.fromARGB(255, 0, 13, 17),
        );
      case 'Neon Dreams Theme':
        return _ThemeColors(
          primary: const Color.fromARGB(255, 255, 0, 127),
          accent: const Color.fromARGB(255, 0, 255, 255),
          background: const Color.fromARGB(255, 10, 5, 20),
          surface: const Color.fromARGB(255, 20, 10, 30),
        );
      case 'Coral Reef Theme':
        return _ThemeColors(
          primary: const Color.fromARGB(255, 255, 127, 80),
          accent: const Color.fromARGB(255, 0, 255, 200),
          background: const Color.fromARGB(255, 15, 25, 35),
          surface: const Color.fromARGB(255, 25, 35, 45),
        );
      case 'Bioluminescent Theme':
        return _ThemeColors(
          primary: Colors.lightGreenAccent,
          accent: Colors.greenAccent,
          background: const Color(0xFF120A23),
          surface: const Color(0xFF1E102D),
        );
      case 'Custom Theme':
        return customThemeColors ??
            _ThemeColors(
              primary: Colors.cyanAccent,
              accent: Colors.cyanAccent,
              background: const Color(0xFF001D3D),
              surface: Colors.black,
            );
      default:
        return _ThemeColors(
          primary: const Color.fromARGB(255, 2, 152, 252),
          accent: const Color.fromARGB(255, 230, 255, 2),
          background: const Color.fromARGB(255, 0, 15, 22),
          surface: const Color.fromARGB(255, 0, 13, 17),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _themeForName(selectedThemeName),
      home: MenuScreen(
        onThemeChanged: _handleThemeChanged,
        backgroundImagePath: customBackgroundImagePath,
      ),
    );
  }
}

class _ThemeColors {
  final Color primary;
  final Color accent;
  final Color background;
  final Color surface;

  const _ThemeColors({
    required this.primary,
    required this.accent,
    required this.background,
    required this.surface,
  });
}

class MenuScreen extends StatefulWidget {
  final ValueChanged<String> onThemeChanged;
  final String? backgroundImagePath;
  const MenuScreen({
    super.key,
    required this.onThemeChanged,
    this.backgroundImagePath,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _timeController = TextEditingController(
    text: "5",
  );
  int totalMetersSaved = 0;
  int totalCoins = 0;
  int currentStreak = 0;
  int weeklyDepth = 0;
  bool _gayMode = false;

  final List<Color> _rainbowColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
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
    await _maybeShowFirstRunGuide();
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

  Future<void> _maybeShowFirstRunGuide() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding =
        prefs.getBool('aquanimity_onboarding_seen') ?? false;
    if (!hasSeenOnboarding && mounted) {
      await prefs.setBool('aquanimity_onboarding_seen', true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showHelpDialog();
      });
    }
  }

  Future<void> _refreshStreakNotification(Map<String, dynamic> stats) async {
    final String lastDiveDate = stats['last_dive_date'] ?? '';
    final int streak = stats['current_streak'] ?? 0;

    if (streak > 0 && !_didDiveToday(lastDiveDate)) {
      await NotificationService().scheduleStreakReminder(
        _nextStreakReminderTime(),
      );
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
          title: const Text(
            'Aquanimity Help Guide',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.92,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _helpSection(
                    Icons.waves,
                    'Welcome to Aquanimity',
                    'Dive into the depths of the ocean in this underwater adventure game. Your goal is to explore the abyss and collect treasures while practicing to stay off your devices.',
                    Colors.cyanAccent,
                  ),
                  const SizedBox(height: 20),
                  _helpSection(
                    Icons.timer,
                    'Dive Duration',
                    'Set the duration of your dive in minutes. The longer you dive, the deeper you can go, but be careful - running out of oxygen ends your dive!',
                    Colors.yellowAccent,
                  ),
                  const SizedBox(height: 20),
                  _helpSection(
                    Icons.subdirectory_arrow_right,
                    'Launch Sub',
                    'Start your submarine dive! Control your descent and collect treasures. Watch your oxygen meter and depth gauge.',
                    Colors.cyanAccent[700]!,
                  ),
                  const SizedBox(height: 20),
                  _helpSection(
                    Icons.inventory,
                    'Treasure Vault',
                    'View all the treasures you\'ve collected during your dives. Sell them for coins to upgrade your equipment.',
                    Colors.purpleAccent[700]!,
                  ),
                  const SizedBox(height: 20),
                  _helpSection(
                    Icons.bar_chart,
                    'Depth Stats',
                    'Check your diving statistics, including total depth achieved, weekly progress, and ranking system.',
                    Colors.blueGrey[400]!,
                  ),
                  const SizedBox(height: 20),
                  _helpSection(
                    Icons.emoji_events,
                    'Ranking System',
                    'Climb the ranks from Copper to Champion based on your weekly diving achievements. Rankings reset every Monday.',
                    Colors.amber,
                  ),
                  const SizedBox(height: 20),
                  _helpSection(
                    Icons.monetization_on,
                    'Coins & Treasures',
                    'Earn coins by selling treasures. Use coins to upgrade your submarine, unlock themes, and improve dive rewards.',
                    Colors.amber,
                  ),
                  const SizedBox(height: 20),
                  _helpSection(
                    Icons.local_fire_department,
                    'Streak System',
                    'Maintain your diving streak by completing successful dives. Don\'t let it break!',
                    Colors.orangeAccent,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showPrivacyPolicyDialog();
              },
              child: const Text(
                'Privacy Policy',
                style: TextStyle(color: Colors.cyanAccent),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showTermsOfServiceDialog();
              },
              child: const Text(
                'Terms of Service',
                style: TextStyle(color: Colors.cyanAccent),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Got it!',
                style: TextStyle(color: Colors.cyanAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[900],
          title: const Text(
            'Privacy Policy',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Data Storage:',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Aquanimity stores all your progress, dive history, and treasure inventory locally on your device using encrypted database storage (SQLite on mobile) or browser local storage (on web). No data is ever sent to external servers.',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 16),
                Text(
                  'What We Collect:',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Dive statistics (depth, duration, dates, rank)',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  '• Treasure inventory and item metadata',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  '• User coins and streak information',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  '• Theme and boat style preferences',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                SizedBox(height: 16),
                Text(
                  'No Tracking:',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Aquanimity does not use analytics, crash reporting, or third-party tracking services. Your gameplay is completely private and anonymous.',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 16),
                Text(
                  'Permissions:',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Optional permissions are requested only when needed (e.g., photo library for custom themes, notifications for reminders). You can deny any permission and the app will continue to work.',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 16),
                Text(
                  'Data Deletion:',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You can delete all your data at any time from the Privacy & Data settings menu.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.cyanAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTermsOfServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[900],
          title: const Text(
            'Terms of Service',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Aquanimity is provided as-is for focus and habit-building. Use it responsibly and avoid using it while driving or operating heavy machinery.',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 12),
                Text(
                  'Your progress, dive history, and inventory are stored locally. No account is required for the core experience.',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 12),
                Text(
                  'By using Aquanimity, you agree to keep your activities within the app and respect device notifications.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.cyanAccent),
              ),
            ),
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
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryAccent = Theme.of(context).colorScheme.primary;
    final Color secondaryAccent = Theme.of(context).colorScheme.secondary;
    final Color aquaLogo = _getRainbowColor(0, primaryAccent);
    final Color yellowSplash = _getRainbowColor(1, secondaryAccent);

    return Scaffold(
      body: Stack(
        children: [
          AbyssalBackground(
            backgroundImagePath: widget.backgroundImagePath,
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isWide = constraints.maxWidth > 720;
                      final Widget headerSection = Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OneShotFloat(
                            child: Icon(Icons.waves, color: aquaLogo, size: 50),
                          ),
                          OneShotFloat(
                            delayMs: 200,
                            child: Text(
                              "AQUANIMITY",
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 8,
                                color: aquaLogo,
                              ),
                            ),
                          ),
                          OneShotFloat(
                            delayMs: 400,
                            child: Text(
                              splashText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: yellowSplash,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                shadows: const [
                                  Shadow(blurRadius: 10, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      );

                      final Widget statsPanel = OneShotFloat(
                        delayMs: 600,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 30),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: aquaLogo.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "LOGBOOK TOTAL",
                                style: TextStyle(
                                  color: _getRainbowColor(3, aquaLogo),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "$totalMetersSaved m",
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(color: Colors.white10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.monetization_on,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "$totalCoins",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  const Icon(
                                    Icons.local_fire_department,
                                    color: Colors.orangeAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "$currentStreak",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.orangeAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );

                      final Widget formSection = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Dive Duration (Mins):",
                            style: TextStyle(
                              color: _getRainbowColor(4, Colors.white60),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: isWide ? 170 : 120,
                            child: TextField(
                              controller: _timeController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: aquaLogo,
                              ),
                              decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: aquaLogo),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white24),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          // LAUNCH SUB - Primary Action Button
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20, left: 30, right: 30),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyanAccent[700]!.withAlpha(100),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.cyanAccent[700],
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 28,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () async {
                                    int mins =
                                        int.tryParse(_timeController.text) ?? 5;
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DiveScreen(
                                          durationMinutes: mins == 0 ? -1 : mins,
                                        ),
                                      ),
                                    );
                                    if (mounted) _loadHistory();
                                  },
                                  icon: const Icon(Icons.waves, size: 24),
                                  label: const Text(
                                    'LAUNCH SUB',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _menuButton(
                            "TREASURE VAULT",
                            Colors.purpleAccent[700]!,
                            () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VaultScreen(
                                    totalCoins: totalCoins,
                                    onCoinsChanged: _loadHistory,
                                  ),
                                ),
                              );
                              if (mounted) _loadHistory();
                            },
                            8,
                          ),
                          _menuButton(
                            "DEPTH STATS",
                            Colors.blueGrey[800]!,
                            () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const StatsScreen(),
                                ),
                              );
                              if (mounted) _loadHistory();
                            },
                            11,
                          ),
                          _menuButton(
                            "SETTINGS",
                            Colors.pinkAccent[200]!,
                            () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SettingsScreen(
                                    onThemeChanged: widget.onThemeChanged,
                                  ),
                                ),
                              );
                            },
                            10,
                          ),
                          if (weeklyDepth >= 30000)
                            _menuButton("GAY MODE", Colors.pinkAccent, () {
                              setState(() => _gayMode = !_gayMode);
                            }, 13),
                        ],
                      );

                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          headerSection,
                                          statsPanel,
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    Expanded(
                                      child: formSection,
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    headerSection,
                                    statsPanel,
                                    const SizedBox(height: 20),
                                    formSection,
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(
                Icons.help_outline,
                color: Colors.white70,
                size: 30,
              ),
              onPressed: _showHelpDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton(
    String text,
    Color color,
    VoidCallback pressed,
    int index,
  ) {
    final buttonColor = _gayMode
        ? _rainbowColors[index % _rainbowColors.length]
        : color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 30, right: 30),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: buttonColor),
            foregroundColor: buttonColor,
            padding: const EdgeInsets.symmetric(vertical: 22),
          ),
          onPressed: pressed,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
