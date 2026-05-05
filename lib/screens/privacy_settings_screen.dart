import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database_helper.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  late DatabaseHelper _dbHelper;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
  }

  Future<void> _resetAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blueGrey[900],
        title: const Text(
          'Reset All Data?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'This will permanently delete all your progress, inventory, treasures, and settings. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.cyanAccent),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // Clear SharedPreferences (for web and legacy data)
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Reset database (mobile/desktop)
        await _dbHelper.resetDatabase();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All data has been reset successfully.'),
              backgroundColor: Colors.green,
            ),
          );

          // Return to main menu
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error resetting data: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  void _showDataUsageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blueGrey[900],
        title: const Text(
          'Data Storage & Usage',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'What Data We Store:',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Dive history (dates, depths, ranks)',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '• Inventory (treasures collected)',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '• User statistics (coins, streaks, weekly depth)',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '• Purchased upgrades (themes, boat styles)',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '• Theme preferences & customizations',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                'Storage Location:',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'All data is stored locally on your device. On Android/iOS, data is stored in the app\'s private database directory. On web, data is stored in browser local storage. No data is ever sent to external servers.',
                style: TextStyle(color: Colors.white70),
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
                'Aquanimity does not collect analytics, track user behavior, or use third-party tracking libraries. Your experience is completely private.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got It',
              style: TextStyle(color: Colors.cyanAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blueGrey[900],
        title: const Text(
          'Permissions Used',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Why We Need These:',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '📱 Notifications',
                style: TextStyle(
                  color: Colors.yellowAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Used to send streak reminders and dive alerts. You can disable notifications in your device settings at any time.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 12),
              Text(
                '📸 Camera/Photo Library',
                style: TextStyle(
                  color: Colors.yellowAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Used only when you choose to customize your theme with a background image. Permission is requested only when you tap the customization button.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 12),
              Text(
                '💾 Storage (Android 5-10)',
                style: TextStyle(
                  color: Colors.yellowAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Older Android versions require this permission to store custom theme images. Newer versions use sandboxed app storage.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 12),
              Text(
                '🔄 Device Info',
                style: TextStyle(
                  color: Colors.yellowAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Used to optimize the UI for your device type (phone vs tablet). No personal information is collected.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                '✓ No permissions are required for the core gameplay experience.',
                style: TextStyle(color: Colors.greenAccent, fontSize: 13),
              ),
              SizedBox(height: 8),
              Text(
                '✓ You can deny any permission and the app will continue to work.',
                style: TextStyle(color: Colors.greenAccent, fontSize: 13),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'PRIVACY & DATA',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 40),
            _buildSettingsCard(
              icon: Icons.storage,
              title: 'Data Storage & Usage',
              description: 'See what data is stored and where',
              onTap: _showDataUsageDialog,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            _buildSettingsCard(
              icon: Icons.lock,
              title: 'Permissions',
              description: 'View why permissions are requested',
              onTap: _showPermissionsDialog,
              color: Colors.greenAccent,
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.redAccent.withAlpha(100),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Danger Zone',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Resetting your data will permanently delete all your progress, inventory, and settings.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _resetAllData,
                      icon: const Icon(Icons.delete_forever),
                      label: const Text(
                        'RESET ALL DATA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withAlpha(60),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }
}
