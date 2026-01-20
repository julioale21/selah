import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../models/verse_model.dart';

abstract class VerseLocalDataSource {
  Future<List<VerseModel>> getAllVerses();
  Future<List<VerseModel>> getVersesByCategory(String category);
  Future<List<VerseModel>> searchVerses(String query);
  Future<VerseModel?> getVerseById(String id);
  Future<List<String>> getFavoriteVerseIds(String userId);
  Future<void> addFavorite(String userId, String verseId);
  Future<void> removeFavorite(String userId, String verseId);
  Future<bool> isFavorite(String userId, String verseId);
  Future<VerseModel> getDailyVerse(String userId);
  Future<VerseModel?> getRandomVerseByCategory(String category);
  Future<void> seedVersesFromJson();
  Future<int> getVersesCount();
}

class VerseLocalDataSourceImpl implements VerseLocalDataSource {
  final DatabaseHelper databaseHelper;
  final SharedPreferences sharedPreferences;

  static const String _lastVerseDateKey = 'last_daily_verse_date';
  static const String _lastVerseIdKey = 'last_daily_verse_id';

  VerseLocalDataSourceImpl({
    required this.databaseHelper,
    required this.sharedPreferences,
  });

  @override
  Future<List<VerseModel>> getAllVerses() async {
    final results = await databaseHelper.query(
      'verses',
      orderBy: 'book, chapter, verse_start',
    );
    return results.map((map) => VerseModel.fromMap(map)).toList();
  }

  @override
  Future<List<VerseModel>> getVersesByCategory(String category) async {
    final results = await databaseHelper.query(
      'verses',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'book, chapter, verse_start',
    );
    return results.map((map) => VerseModel.fromMap(map)).toList();
  }

  @override
  Future<List<VerseModel>> searchVerses(String query) async {
    final lowerQuery = '%${query.toLowerCase()}%';
    final results = await databaseHelper.rawQuery('''
      SELECT * FROM verses
      WHERE LOWER(text_es) LIKE ?
         OR LOWER(reference) LIKE ?
         OR LOWER(book) LIKE ?
         OR LOWER(tags) LIKE ?
      ORDER BY book, chapter, verse_start
    ''', [lowerQuery, lowerQuery, lowerQuery, lowerQuery]);
    return results.map((map) => VerseModel.fromMap(map)).toList();
  }

  @override
  Future<VerseModel?> getVerseById(String id) async {
    final results = await databaseHelper.query(
      'verses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return VerseModel.fromMap(results.first);
  }

  @override
  Future<List<String>> getFavoriteVerseIds(String userId) async {
    final results = await databaseHelper.query(
      'favorite_verses',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return results.map((map) => map['verse_id'] as String).toList();
  }

  @override
  Future<void> addFavorite(String userId, String verseId) async {
    await databaseHelper.insert('favorite_verses', {
      'id': '${userId}_$verseId',
      'user_id': userId,
      'verse_id': verseId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> removeFavorite(String userId, String verseId) async {
    await databaseHelper.delete(
      'favorite_verses',
      where: 'user_id = ? AND verse_id = ?',
      whereArgs: [userId, verseId],
    );
  }

  @override
  Future<bool> isFavorite(String userId, String verseId) async {
    final count = await databaseHelper.count(
      'favorite_verses',
      where: 'user_id = ? AND verse_id = ?',
      whereArgs: [userId, verseId],
    );
    return count > 0;
  }

  @override
  Future<VerseModel> getDailyVerse(String userId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = sharedPreferences.getString('${_lastVerseDateKey}_$userId');
    final lastVerseId = sharedPreferences.getString('${_lastVerseIdKey}_$userId');

    // If same day and we have a saved verse, return it
    if (lastDate == today && lastVerseId != null) {
      final verse = await getVerseById(lastVerseId);
      if (verse != null) return verse;
    }

    // Select a new daily verse
    final verse = await _selectNewDailyVerse(userId);

    // Save selection
    await sharedPreferences.setString('${_lastVerseDateKey}_$userId', today);
    await sharedPreferences.setString('${_lastVerseIdKey}_$userId', verse.id);

    // Record in history
    await _recordDailyVerse(userId, verse.id, today);

    return verse;
  }

  Future<VerseModel> _selectNewDailyVerse(String userId) async {
    // Get verses not shown recently (last 30 days)
    final thirtyDaysAgo = DateTime.now()
        .subtract(const Duration(days: 30))
        .toIso8601String()
        .split('T')[0];

    final recentVerseIds = await databaseHelper.query(
      'daily_verses',
      where: 'user_id = ? AND shown_date > ?',
      whereArgs: [userId, thirtyDaysAgo],
    );

    final excludeIds = recentVerseIds.map((r) => r['verse_id'] as String).toList();

    // Select random verse not shown recently
    List<Map<String, dynamic>> verses;
    if (excludeIds.isNotEmpty) {
      final placeholders = List.filled(excludeIds.length, '?').join(',');
      verses = await databaseHelper.rawQuery(
        'SELECT * FROM verses WHERE id NOT IN ($placeholders) ORDER BY RANDOM() LIMIT 1',
        excludeIds,
      );
    } else {
      verses = await databaseHelper.rawQuery(
        'SELECT * FROM verses ORDER BY RANDOM() LIMIT 1',
      );
    }

    if (verses.isEmpty) {
      // If all shown, select any
      verses = await databaseHelper.rawQuery(
        'SELECT * FROM verses ORDER BY RANDOM() LIMIT 1',
      );
    }

    return VerseModel.fromMap(verses.first);
  }

  Future<void> _recordDailyVerse(String userId, String verseId, String date) async {
    await databaseHelper.insert('daily_verses', {
      'id': '${userId}_${verseId}_$date',
      'user_id': userId,
      'verse_id': verseId,
      'shown_date': date,
    });
  }

  @override
  Future<void> seedVersesFromJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/verses.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final versesJson = jsonData['verses'] as List<dynamic>;

      final db = await databaseHelper.database;
      for (final v in versesJson) {
        final verse = VerseModel.fromJson(v as Map<String, dynamic>);
        // Use INSERT OR REPLACE to update existing verses or insert new ones
        await db.insert(
          'verses',
          verse.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      throw Exception('Error loading verses from assets: $e');
    }
  }

  @override
  Future<VerseModel?> getRandomVerseByCategory(String category) async {
    final results = await databaseHelper.rawQuery(
      'SELECT * FROM verses WHERE category = ? ORDER BY RANDOM() LIMIT 1',
      [category],
    );
    if (results.isEmpty) return null;
    return VerseModel.fromMap(results.first);
  }

  @override
  Future<int> getVersesCount() async {
    return await databaseHelper.count('verses');
  }
}
