import 'package:flutter/material.dart';
import '../widgets/shared_widgets.dart';
import '../data/database_helper.dart';

// --- CUSTOM EMBLEM PAINTER ---
class RankEmblem extends StatelessWidget {
  final Color color;
  final String tier; 
  final double size;

  const RankEmblem({super.key, required this.color, required this.tier, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.3,
      child: CustomPaint(
        painter: BannerPainter(color: color, tier: tier),
      ),
    );
  }
}

class BannerPainter extends CustomPainter {
  final Color color;
  final String tier;
  BannerPainter({required this.color, required this.tier});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Path path = Path();
    path.moveTo(size.width * 0.1, 0);
    path.lineTo(size.width * 0.9, 0);
    path.lineTo(size.width * 0.9, size.height * 0.75);
    path.lineTo(size.width * 0.5, size.height); 
    path.lineTo(size.width * 0.1, size.height * 0.75);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    TextPainter tp = TextPainter(
      text: TextSpan(
        text: tier,
        style: TextStyle(
          color: Colors.white,
          fontSize: tier.length > 1 ? size.width * 0.35 : size.width * 0.45,
          fontWeight: FontWeight.w900,
          fontFamily: 'monospace',
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset((size.width - tp.width) / 2, (size.height * 0.4) - (tp.height / 2)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- RANK DATA MODEL ---
class RankTier {
  final String category;
  final String subTier;
  final Color color;
  final int minMeters;
  const RankTier(this.category, this.subTier, this.color, this.minMeters);
}

class RankSystem {
  static const List<RankTier> levels = [
    RankTier("CHAMPION", "N1", Color(0xFFE50000), 30000),
    RankTier("DIAMOND", "★", Color(0xFFB48EFE), 22000),
    RankTier("EMERALD", "★", Color(0xFF2ECC71), 16000),
    RankTier("PLATINUM", "★", Color(0xFF2EBDD3), 11000),
    RankTier("PLATINUM", "II", Color(0xFF2EBDD3), 9500),
    RankTier("PLATINUM", "III", Color(0xFF2EBDD3), 8500),
    RankTier("GOLD", "★", Color(0xFFFFC107), 7500),
    RankTier("GOLD", "II", Color(0xFFFFC107), 6700),
    RankTier("GOLD", "III", Color(0xFFFFC107), 6000),
    RankTier("GOLD", "IV", Color(0xFFFFC107), 5400),
    RankTier("SILVER", "★", Color(0xFFB0BEC5), 4800),
    RankTier("SILVER", "II", Color(0xFFB0BEC5), 4200),
    RankTier("SILVER", "III", Color(0xFFB0BEC5), 3600),
    RankTier("SILVER", "IV", Color(0xFFB0BEC5), 3000),
    RankTier("BRONZE", "★", Color(0xFFCD7F32), 2500),
    RankTier("BRONZE", "II", Color(0xFFCD7F32), 2000),
    RankTier("BRONZE", "III", Color(0xFFCD7F32), 1500),
    RankTier("BRONZE", "IV", Color(0xFFCD7F32), 1100),
    RankTier("COPPER", "★", Color(0xFFEF5350), 800),
    RankTier("COPPER", "II", Color(0xFFEF5350), 500),
    RankTier("COPPER", "III", Color(0xFFEF5350), 250),
    RankTier("COPPER", "IV", Color(0xFFEF5350), 0),
  ];

  static RankTier getRank(int meters) => levels.firstWhere((r) => meters >= r.minMeters, orElse: () => levels.last);
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int success = 0, forfeit = 0, totalDepth = 0, currentStreak = 0, weeklyMeters = 0;
  List<String> rankHistory = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dbHelper = DatabaseHelper();
    final userStats = await dbHelper.getUserStats();
    final diveHistory = await dbHelper.getDiveHistory(includeArchived: true);
    
    // Convert dive history back to the string format expected by the UI
    List<String> historyStrings = diveHistory.map((entry) {
      String date = entry['date'];
      int depth = entry['depth'];
      String rank = entry['rank'];
      return "$date | ${depth}m | $rank";
    }).toList();
    
    setState(() {
      success = userStats['successful_dives'] ?? 0;
      forfeit = userStats['forfeit_dives'] ?? 0;
      totalDepth = userStats['total_depth'] ?? 0;
      currentStreak = userStats['current_streak'] ?? 0;
      weeklyMeters = userStats['weekly_depth'] ?? 0;
      rankHistory = historyStrings;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentRank = RankSystem.getRank(weeklyMeters);
    final RankTier? bestRank = _resolveBestRank(currentRank);
    final String bestRankLabel = bestRank != null ? "${bestRank.category} ${bestRank.subTier}" : "N/A";
    final Color bestRankColor = bestRank?.color ?? Colors.indigoAccent;

    return Scaffold(
      body: AbyssalBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildRankHeader(currentRank),
              const SizedBox(height: 25),
              _buildRankProgressBar(weeklyMeters, currentRank),
              const SizedBox(height: 15),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildStatCard("TOTAL DEPTH", "$totalDepth m", Colors.cyanAccent)),
                          Expanded(child: _buildStatCard("BEST RANK", bestRankLabel, bestRankColor)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard("SUCCESSFUL", "$success", Colors.greenAccent)),
                          Expanded(child: _buildStatCard("BREACHES", "$forfeit", Colors.redAccent)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard("STREAK", "$currentStreak DAYS", Colors.orangeAccent)),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildHistoryList(),
                    ],
                  ),
                ),
              ),
              _buildBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankHeader(RankTier rank) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: rank.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rank.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          RankEmblem(color: rank.color, tier: rank.subTier, size: 40),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("WEEKLY STATUS", style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.white54)),
              Text("${rank.category} ${rank.subTier}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: rank.color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankProgressBar(int meters, RankTier current) {
    int currentIndex = RankSystem.levels.indexOf(current);
    RankTier nextRank = currentIndex > 0 ? RankSystem.levels[currentIndex - 1] : current;
    double progress = currentIndex > 0 ? ((meters - current.minMeters) / (nextRank.minMeters - current.minMeters)).clamp(0.0, 1.0) : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${current.category} ${current.subTier}", style: TextStyle(color: current.color, fontSize: 11, fontWeight: FontWeight.bold)),
              Text("${nextRank.category} ${nextRank.subTier}", style: const TextStyle(color: Colors.white24, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: progress, backgroundColor: Colors.white.withValues(alpha: 0.05), color: current.color, minHeight: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      height: 95, 
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          FittedBox(child: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'monospace'))),
        ],
      ),
    );
  }

  RankTier? _rankTierFromLabel(String label) {
    final normalized = label.trim();
    for (final rank in RankSystem.levels) {
      if ("${rank.category} ${rank.subTier}" == normalized) {
        return rank;
      }
    }
    return null;
  }

  RankTier? _resolveBestRank(RankTier currentRank) {
    RankTier? best = weeklyMeters > 0 ? currentRank : null;

    for (final entry in rankHistory) {
      final parts = entry.split('|').map((part) => part.trim()).toList();
      if (parts.length < 3) continue;

      final String rankLabel = parts[2];
      if (rankLabel.toUpperCase() == 'ARCHIVED' || rankLabel.isEmpty) continue;

      final RankTier? historyRank = _rankTierFromLabel(rankLabel);
      if (historyRank == null) continue;

      if (best == null || RankSystem.levels.indexOf(historyRank) < RankSystem.levels.indexOf(best)) {
        best = historyRank;
      }
    }

    return best;
  }

  Widget _buildHistoryList() {
    return Column(
      children: [
        const Align(alignment: Alignment.centerLeft, child: Text("PAST OPERATIONS", style: TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold))),
        const Divider(color: Colors.white10),
        if (rankHistory.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Text("NO DATA ARCHIVED", style: TextStyle(color: Colors.white10)))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rankHistory.length,
            itemBuilder: (context, index) {
              final String entry = rankHistory[rankHistory.length - 1 - index];
              final parts = entry.split('|');
              
              // Safe parsing for old data
              String date = parts[0];
              String depth = parts.length > 1 ? parts[1] : "--";
              String rankLabel = parts.length > 2 ? parts[2] : "LEGACY ARCHIVE";

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(rankLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white70)),
                  subtitle: Text(date, style: const TextStyle(fontSize: 10, color: Colors.white38)),
                  trailing: Text(depth, style: const TextStyle(fontFamily: 'monospace', color: Colors.white70)),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextButton.icon(
        onPressed: () => Navigator.pop(context), 
        icon: const Icon(Icons.arrow_back, color: Colors.white60, size: 18), 
        label: const Text("BACK TO SHIP", style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold))
      ),
    );
  }
}