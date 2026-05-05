import 'package:flutter/material.dart';
import '../widgets/shared_widgets.dart';
import 'personalize_screen.dart';
import 'privacy_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  final ValueChanged<String> onThemeChanged;

  const SettingsScreen({super.key, required this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AbyssalBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              // Tab bar
              Container(
                color: Colors.black.withAlpha(50),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.cyanAccent,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: Colors.cyanAccent,
                  tabs: const [
                    Tab(text: 'PERSONALIZE'),
                    Tab(text: 'PRIVACY'),
                  ],
                ),
              ),
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    PersonalizeScreen(onThemeChanged: widget.onThemeChanged),
                    const PrivacySettingsScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
