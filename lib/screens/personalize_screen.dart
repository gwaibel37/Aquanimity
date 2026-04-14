import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../models/loot_box.dart';
import '../data/database_helper.dart';
import '../data/upgrade_data.dart';
import '../widgets/shared_widgets.dart';

class PersonalizeScreen extends StatefulWidget {
  final ValueChanged<String> onThemeChanged;
  const PersonalizeScreen({super.key, required this.onThemeChanged});

  @override
  State<PersonalizeScreen> createState() => _PersonalizeScreenState();
}

class _PersonalizeScreenState extends State<PersonalizeScreen> {
  late DatabaseHelper _dbHelper;
  late Future<List<Map<String, dynamic>>> _purchasedUpgrades;
  String selectedTheme = 'default';
  String selectedBoatStyle = 'default';

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _purchasedUpgrades = _dbHelper.getPurchasedUpgrades();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final stats = await _dbHelper.getUserStats();
    setState(() {
      selectedTheme = stats['selected_theme'] as String? ?? 'default';
      selectedBoatStyle = (stats['selected_boat_style'] as String?) ?? 'Classic Sub';
      if (selectedBoatStyle == 'default') selectedBoatStyle = 'Classic Sub';
    });
  }

  Color _getRarityColor(LootBoxRarity rarity) {
    switch (rarity) {
      case LootBoxRarity.common:
        return Colors.grey[600]!;
      case LootBoxRarity.uncommon:
        return Colors.greenAccent;
      case LootBoxRarity.rare:
        return Colors.blueAccent;
      case LootBoxRarity.legendary:
        return Colors.amber;
    }
  }

  Future<void> _pickCustomThemeImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (!mounted) return;
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          backgroundColor: Colors.blueGrey,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.cyanAccent),
              SizedBox(height: 16),
              Text(
                'Extracting colors from image...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );

      try {
        // Load and decode the image
        final imageBytes = await File(image.path).readAsBytes();
        final decodedImage = img.decodeImage(imageBytes);

        if (decodedImage == null) {
          throw Exception('Failed to decode image');
        }

        // Simple color extraction - get average color and some sample colors
        int totalR = 0, totalG = 0, totalB = 0;
        int pixelCount = 0;

        // Sample pixels from the image
        for (int y = 0; y < decodedImage.height; y += 10) {
          for (int x = 0; x < decodedImage.width; x += 10) {
            final pixel = decodedImage.getPixel(x, y);
            totalR += pixel.r.toInt();
            totalG += pixel.g.toInt();
            totalB += pixel.b.toInt();
            pixelCount++;
          }
        }

        if (pixelCount == 0) {
          throw Exception('No pixels found in image');
        }

        // Calculate average color
        final avgR = (totalR / pixelCount).round();
        final avgG = (totalG / pixelCount).round();
        final avgB = (totalB / pixelCount).round();
        final averageColor = Color.fromARGB(255, avgR, avgG, avgB);

        // Create theme colors based on the average
        Color primary = averageColor;
        Color accent = Color.fromARGB(
          255,
          (avgR + 100) % 255,
          (avgG + 50) % 255,
          (avgB + 150) % 255,
        );
        Color background = Color.fromARGB(
          255,
          (avgR * 0.3).round(),
          (avgG * 0.3).round(),
          (avgB * 0.3).round(),
        );
        Color surface = Color.fromARGB(
          255,
          (avgR * 0.5).round(),
          (avgG * 0.5).round(),
          (avgB * 0.5).round(),
        );

        // Save the image to app storage using a fresh filename so Flutter reloads it
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String imagePath = '${appDir.path}/custom_theme_background_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await File(image.path).copy(imagePath);

        // Save custom theme colors and image path to database
        await _dbHelper.updateUserStats({
          'custom_theme_primary': primary.toARGB32(),
          'custom_theme_accent': accent.toARGB32(),
          'custom_theme_background': background.toARGB32(),
          'custom_theme_surface': surface.toARGB32(),
          'custom_background_image': imagePath,
        });

        // Update selected theme if not already set to Custom Theme
        if (selectedTheme != 'Custom Theme') {
          setState(() {
            selectedTheme = 'Custom Theme';
          });
          await _dbHelper.updateUserStats({'selected_theme': 'Custom Theme'});
          widget.onThemeChanged('Custom Theme');
        } else {
          // Force theme refresh
          widget.onThemeChanged('Custom Theme');
        }

        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Custom theme applied!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to process image: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AbyssalBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'PERSONALIZE',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildCategorySection(
                        'THEMES',
                        UpgradeCategory.theme,
                        Icons.palette,
                      ),
                      const SizedBox(height: 40),
                      _buildCategorySection(
                        'BOAT STYLES',
                        UpgradeCategory.boatStyle,
                        Icons.directions_boat,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    String title,
    UpgradeCategory category,
    IconData icon,
  ) {
    final upgrades = UpgradeData.getUpgradesByCategory(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _purchasedUpgrades,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final purchasedIds = snapshot.data!
                .map((u) => u['upgrade_id'] as int)
                .toSet();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upgrades.length,
              itemBuilder: (context, index) {
                final upgrade = upgrades[index];
                final isPurchased = upgrade.id == 5 || purchasedIds.contains(upgrade.id);

                return _buildUpgradeCard(
                  upgrade,
                  isPurchased,
                  category,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpgradeCard(
    Upgrade upgrade,
    bool isPurchased,
    UpgradeCategory category,
  ) {
    final color = _getRarityColor(upgrade.minRarity);
    final isSelected = (category == UpgradeCategory.theme &&
            selectedTheme == upgrade.name) ||
        (category == UpgradeCategory.boatStyle &&
            selectedBoatStyle == upgrade.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: isSelected ? Colors.cyanAccent : color,
          width: isSelected ? 3 : 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        upgrade.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        upgrade.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPurchased) ...[
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected)
                        upgrade.name == 'Custom Theme'
                            ? ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: color,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                icon: const Icon(Icons.image, size: 16),
                                label: const Text(
                                  'Upload Image',
                                  style: TextStyle(fontSize: 12),
                                ),
                                onPressed: () => _pickCustomThemeImage(),
                              )
                            : const Icon(
                                Icons.check_circle,
                                color: Colors.cyanAccent,
                                size: 32,
                              )
                      else
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text(
                            'Select',
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () async {
                            setState(() {
                              if (category == UpgradeCategory.theme) {
                                selectedTheme = upgrade.name;
                              } else {
                                selectedBoatStyle = upgrade.name;
                              }
                            });
                            await _dbHelper.updateUserStats({
                              if (category == UpgradeCategory.theme) 'selected_theme': upgrade.name,
                              if (category == UpgradeCategory.boatStyle) 'selected_boat_style': upgrade.name,
                            });
                            if (category == UpgradeCategory.theme) {
                              widget.onThemeChanged(upgrade.name);
                            }
                          },
                        ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Locked',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
