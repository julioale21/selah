import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../models/user_preferences_model.dart';

abstract class SettingsLocalDataSource {
  Future<UserPreferencesModel> getPreferences(String userId);
  Future<void> savePreferences(String userId, UserPreferencesModel preferences);
  Future<String> exportData(String userId);
  Future<void> importData(String jsonData);
  Future<void> clearAllData(String userId);
  Future<int> getDatabaseSize();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final DatabaseHelper databaseHelper;

  SettingsLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<UserPreferencesModel> getPreferences(String userId) async {
    final results = await databaseHelper.query(
      'settings',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (results.isEmpty) {
      return const UserPreferencesModel();
    }

    // Convert list of settings to a single map
    final prefsMap = <String, dynamic>{};
    for (final row in results) {
      final key = row['key'] as String;
      final value = row['value'] as String;

      // Try to parse as int first
      final intValue = int.tryParse(value);
      if (intValue != null) {
        prefsMap[key] = intValue;
      } else {
        prefsMap[key] = value;
      }
    }

    return UserPreferencesModel.fromMap(prefsMap);
  }

  @override
  Future<void> savePreferences(
      String userId, UserPreferencesModel preferences) async {
    final prefsMap = preferences.toMap();

    for (final entry in prefsMap.entries) {
      if (entry.value != null) {
        await databaseHelper.insert('settings', {
          'user_id': userId,
          'key': entry.key,
          'value': entry.value.toString(),
        });
      } else {
        // Remove null values
        await databaseHelper.delete(
          'settings',
          where: 'user_id = ? AND key = ?',
          whereArgs: [userId, entry.key],
        );
      }
    }
  }

  @override
  Future<String> exportData(String userId) async {
    final db = await databaseHelper.database;

    final categories = await db.query('categories', where: 'user_id = ?', whereArgs: [userId]);
    final topics = await db.query('prayer_topics', where: 'user_id = ?', whereArgs: [userId]);
    final sessions = await db.query('prayer_sessions', where: 'user_id = ?', whereArgs: [userId]);
    final journalEntries = await db.query('journal_entries', where: 'user_id = ?', whereArgs: [userId]);
    final answeredPrayers = await db.query('answered_prayers', where: 'user_id = ?', whereArgs: [userId]);
    final dailyPlans = await db.query('daily_plans', where: 'user_id = ?', whereArgs: [userId]);
    final settings = await db.query('settings', where: 'user_id = ?', whereArgs: [userId]);
    final prayerGoals = await db.query('prayer_goals', where: 'user_id = ?', whereArgs: [userId]);
    final goalCelebrations = await db.query('goal_celebrations', where: 'user_id = ?', whereArgs: [userId]);

    final exportData = {
      'version': '1.2',
      'app': 'Selah',
      'exported_at': DateTime.now().toIso8601String(),
      'data': {
        'categories': categories,
        'prayer_topics': topics,
        'prayer_sessions': sessions,
        'journal_entries': journalEntries,
        'answered_prayers': answeredPrayers,
        'daily_plans': dailyPlans,
        'settings': settings,
        'prayer_goals': prayerGoals,
        'goal_celebrations': goalCelebrations,
      },
    };

    return json.encode(exportData);
  }

  @override
  Future<void> importData(String jsonData) async {
    final importData = json.decode(jsonData) as Map<String, dynamic>;
    final data = importData['data'] as Map<String, dynamic>;
    final db = await databaseHelper.database;

    await db.transaction((txn) async {
      // Import categories
      if (data['categories'] != null) {
        for (final item in (data['categories'] as List)) {
          await txn.insert(
            'categories',
            item as Map<String, dynamic>,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Import topics
      if (data['prayer_topics'] != null) {
        for (final item in (data['prayer_topics'] as List)) {
          await txn.insert(
            'prayer_topics',
            item as Map<String, dynamic>,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Import sessions
      if (data['prayer_sessions'] != null) {
        for (final item in (data['prayer_sessions'] as List)) {
          await txn.insert(
            'prayer_sessions',
            item as Map<String, dynamic>,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Import journal entries
      if (data['journal_entries'] != null) {
        for (final item in (data['journal_entries'] as List)) {
          await txn.insert(
            'journal_entries',
            item as Map<String, dynamic>,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Import answered prayers
      if (data['answered_prayers'] != null) {
        for (final item in (data['answered_prayers'] as List)) {
          await txn.insert(
            'answered_prayers',
            item as Map<String, dynamic>,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Import daily plans
      if (data['daily_plans'] != null) {
        for (final item in (data['daily_plans'] as List)) {
          await txn.insert(
            'daily_plans',
            item as Map<String, dynamic>,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Import settings
      if (data['settings'] != null) {
        for (final item in (data['settings'] as List)) {
          await txn.insert(
            'settings',
            item as Map<String, dynamic>,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Import prayer goals
      if (data['prayer_goals'] != null) {
        for (final item in (data['prayer_goals'] as List)) {
          await txn.insert(
            'prayer_goals',
            item as Map<String, dynamic>,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // Import goal celebrations
      if (data['goal_celebrations'] != null) {
        for (final item in (data['goal_celebrations'] as List)) {
          await txn.insert(
            'goal_celebrations',
            item as Map<String, dynamic>,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  @override
  Future<void> clearAllData(String userId) async {
    await databaseHelper.deleteUserData(userId);
  }

  @override
  Future<int> getDatabaseSize() async {
    final db = await databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size()',
    );
    return result.first['size'] as int? ?? 0;
  }
}
