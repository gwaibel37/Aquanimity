import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/treasure.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static SharedPreferences? _prefs;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  // Platform-specific initialization
  Future<void> _ensureInitialized() async {
    if (kIsWeb) {
      _prefs ??= await SharedPreferences.getInstance();
    } else {
      _database ??= await _initDatabase();
    }
  }

  Future<Database> get database async {
    await _ensureInitialized();
    if (kIsWeb) {
      throw UnsupportedError('Database not available on web platform');
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'aquaminity.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // User stats table
    await db.execute('''
      CREATE TABLE user_stats (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        total_depth INTEGER DEFAULT 0,
        total_coins INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 0,
        weekly_depth INTEGER DEFAULT 0,
        last_weekly_reset TEXT,
        last_dive_date TEXT,
        successful_dives INTEGER DEFAULT 0,
        forfeit_dives INTEGER DEFAULT 0
      )
    ''');

    // Dive history table
    await db.execute('''
      CREATE TABLE dive_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        depth INTEGER NOT NULL,
        rank TEXT NOT NULL,
        is_archived INTEGER DEFAULT 0
      )
    ''');

    // Inventory table
    await db.execute('''
      CREATE TABLE inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        rarity TEXT NOT NULL,
        description TEXT NOT NULL,
        acquired_date TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Insert default user stats
    await db.insert('user_stats', {'id': 1});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here if needed
  }

  // Migration method to move data from SharedPreferences to database
  Future<void> migrateFromSharedPreferences() async {
    // Web platform doesn't need migration - it uses SharedPreferences directly
    if (kIsWeb) return;
    
    final prefs = await SharedPreferences.getInstance();
    final db = await database;

    // Migrate user stats
    int totalDepth = prefs.getInt('total_depth') ?? 0;
    int totalCoins = prefs.getInt('total_coins') ?? 0;
    int currentStreak = prefs.getInt('current_streak') ?? 0;
    int weeklyDepth = prefs.getInt('weekly_depth') ?? 0;
    String lastReset = prefs.getString('last_weekly_reset') ?? '';
    String lastDiveDate = prefs.getString('last_dive_date') ?? '';
    int successfulDives = prefs.getInt('successful_dives') ?? 0;
    int forfeitDives = prefs.getInt('forfeit_dives') ?? 0;

    await db.update(
      'user_stats',
      {
        'total_depth': totalDepth,
        'total_coins': totalCoins,
        'current_streak': currentStreak,
        'weekly_depth': weeklyDepth,
        'last_weekly_reset': lastReset,
        'last_dive_date': lastDiveDate,
        'successful_dives': successfulDives,
        'forfeit_dives': forfeitDives,
      },
      where: 'id = ?',
      whereArgs: [1],
    );

    // Migrate dive history
    List<String> history = prefs.getStringList('rank_history') ?? [];
    for (String entry in history) {
      // Parse the history entry format: "MM/DD | DEPTH m | RANK"
      List<String> parts = entry.split(' | ');
      if (parts.length >= 3) {
        String date = parts[0];
        int depth = int.tryParse(parts[1].replaceAll(' m', '')) ?? 0;
        String rank = parts[2];
        bool isArchived = rank == 'ARCHIVED';

        if (!isArchived) {
          await db.insert('dive_history', {
            'date': date,
            'depth': depth,
            'rank': rank,
            'is_archived': 0,
          });
        } else {
          // Handle archived entries - you might want to store them differently
          await db.insert('dive_history', {
            'date': date,
            'depth': depth,
            'rank': 'ARCHIVED',
            'is_archived': 1,
          });
        }
      }
    }

    // Migrate inventory
    List<String> inventory = prefs.getStringList('treasure_inventory') ?? [];
    for (String itemJson in inventory) {
      try {
        Map<String, dynamic> item = Map<String, dynamic>.from(itemJson as Map);
        await db.insert('inventory', {
          'name': item['name'] ?? '',
          'rarity': item['rarity'] ?? '',
          'description': item['description'] ?? '',
        });
      } catch (e) {
        // Handle JSON parsing errors
        // print('Error migrating inventory item: $e');
      }
    }
  }

  // User Stats Methods
  Future<Map<String, dynamic>> getUserStats() async {
    await _ensureInitialized();
    if (kIsWeb) {
      return {
        'total_depth': _prefs!.getInt('total_depth') ?? 0,
        'total_coins': _prefs!.getInt('total_coins') ?? 0,
        'current_streak': _prefs!.getInt('current_streak') ?? 0,
        'weekly_depth': _prefs!.getInt('weekly_depth') ?? 0,
        'last_weekly_reset': _prefs!.getString('last_weekly_reset') ?? '',
        'last_dive_date': _prefs!.getString('last_dive_date') ?? '',
        'successful_dives': _prefs!.getInt('successful_dives') ?? 0,
        'forfeit_dives': _prefs!.getInt('forfeit_dives') ?? 0,
      };
    } else {
      final db = await database;
      List<Map<String, dynamic>> results = await db.query('user_stats', where: 'id = ?', whereArgs: [1]);
      return results.isNotEmpty ? results.first : {};
    }
  }

  Future<void> updateUserStats(Map<String, dynamic> stats) async {
    await _ensureInitialized();
    if (kIsWeb) {
      for (var entry in stats.entries) {
        if (entry.value is int) {
          await _prefs!.setInt(entry.key, entry.value as int);
        } else if (entry.value is String) {
          await _prefs!.setString(entry.key, entry.value as String);
        } else if (entry.value is bool) {
          await _prefs!.setBool(entry.key, entry.value as bool);
        }
      }
    } else {
      final db = await database;
      await db.update('user_stats', stats, where: 'id = ?', whereArgs: [1]);
    }
  }

  // Dive History Methods
  Future<List<Map<String, dynamic>>> getDiveHistory({bool includeArchived = false}) async {
    await _ensureInitialized();
    if (kIsWeb) {
      List<String> historyStrings = _prefs!.getStringList('rank_history') ?? [];
      List<Map<String, dynamic>> history = historyStrings.map((str) {
        List<String> parts = str.split(' | ');
        return {
          'date': parts.isNotEmpty ? parts[0] : '',
          'depth': parts.length > 1 ? int.tryParse(parts[1].replaceAll(' m', '')) ?? 0 : 0,
          'rank': parts.length > 2 ? parts[2] : '',
          'is_archived': parts.length > 2 && parts[2] == 'ARCHIVED' ? 1 : 0,
        };
      }).toList();
      if (!includeArchived) {
        history.removeWhere((item) => item['is_archived'] == 1);
      }
      return history;
    } else {
      final db = await database;
      String whereClause = includeArchived ? '' : 'is_archived = 0';
      List<Map<String, dynamic>> results = whereClause.isEmpty
          ? await db.query('dive_history', orderBy: 'date DESC')
          : await db.query('dive_history', where: whereClause, orderBy: 'date DESC');
      return results;
    }
  }

  Future<void> addDiveEntry(String date, int depth, String rank) async {
    await _ensureInitialized();
    if (kIsWeb) {
      List<String> history = _prefs!.getStringList('rank_history') ?? [];
      history.add('$date | ${depth}m | $rank');
      await _prefs!.setStringList('rank_history', history);
    } else {
      final db = await database;
      await db.insert('dive_history', {
        'date': date,
        'depth': depth,
        'rank': rank,
        'is_archived': 0,
      });
    }
  }

  // Inventory Methods
  Future<List<Map<String, dynamic>>> getInventory() async {
    await _ensureInitialized();
    if (kIsWeb) {
      List<String> inventoryStrings = _prefs!.getStringList('treasure_inventory') ?? [];
      List<Map<String, dynamic>> inventory = [];
      for (int i = 0; i < inventoryStrings.length; i++) {
        try {
          Map<String, dynamic> item = (jsonDecode(inventoryStrings[i]) as Map<dynamic, dynamic>).cast<String, dynamic>();
          item['id'] = i;
          inventory.add(item);
        } catch (e) {
          // Skip invalid items
        }
      }
      return inventory.reversed.toList();
    } else {
      final db = await database;
      return await db.query('inventory', orderBy: 'acquired_date DESC');
    }
  }

  Future<void> addTreasure(Treasure treasure) async {
    await _ensureInitialized();
    if (kIsWeb) {
      List<String> inventory = _prefs!.getStringList('treasure_inventory') ?? [];
      Map<String, dynamic> item = {
        'name': treasure.name,
        'rarity': treasure.rarity.name,
        'description': treasure.description,
        'acquired_date': DateTime.now().toIso8601String(),
      };
      inventory.add(jsonEncode(item));
      await _prefs!.setStringList('treasure_inventory', inventory);
    } else {
      final db = await database;
      await db.insert('inventory', {
        'name': treasure.name,
        'rarity': treasure.rarity.name,
        'description': treasure.description,
      });
    }
  }

  Future<void> removeTreasure(int index) async {
    await _ensureInitialized();
    if (kIsWeb) {
      List<String> inventory = _prefs!.getStringList('treasure_inventory') ?? [];
      // Index is position in reversed list, so reverse it back
      int actualIndex = inventory.length - 1 - index;
      if (actualIndex >= 0 && actualIndex < inventory.length) {
        inventory.removeAt(actualIndex);
        await _prefs!.setStringList('treasure_inventory', inventory);
      }
    } else {
      final db = await database;
      await db.delete('inventory', where: 'id = ?', whereArgs: [index]);
    }
  }

  // Utility method to check if migration is needed
  Future<bool> needsMigration() async {
    if (kIsWeb) {
      return false; // Web uses SharedPreferences directly, no migration needed
    }
    await _ensureInitialized();
    final db = await database;
    List<Map<String, dynamic>> stats = await db.query('user_stats');
    return stats.isEmpty || (stats.first['total_depth'] == 0 &&
                             stats.first['total_coins'] == 0 &&
                             stats.first['current_streak'] == 0);
  }
}