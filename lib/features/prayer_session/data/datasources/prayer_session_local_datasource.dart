import '../../../../core/database/database_helper.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/prayer_session.dart';

abstract class PrayerSessionLocalDataSource {
  Future<void> saveSession(PrayerSession session);
  Future<void> saveJournalEntries(List<JournalEntry> entries);
  Future<Map<String, dynamic>?> getSession(String sessionId);
  Future<List<Map<String, dynamic>>> getRecentSessions(String userId, {int limit = 10});
}

class PrayerSessionLocalDataSourceImpl implements PrayerSessionLocalDataSource {
  final DatabaseHelper databaseHelper;

  PrayerSessionLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<void> saveSession(PrayerSession session) async {
    final db = await databaseHelper.database;
    await db.insert(
      'prayer_sessions',
      {
        'id': session.id,
        'user_id': session.userId,
        'started_at': session.startedAt.toIso8601String(),
        'ended_at': session.endedAt?.toIso8601String(),
        'duration_seconds': session.durationSeconds,
        'topics_prayed': session.topicsPrayed.join(','),
        'notes': session.notes,
        'mood_before': session.moodBefore,
        'mood_after': session.moodAfter,
      },
    );
  }

  @override
  Future<void> saveJournalEntries(List<JournalEntry> entries) async {
    final db = await databaseHelper.database;
    final batch = db.batch();

    for (final entry in entries) {
      batch.insert('journal_entries', {
        'id': entry.id,
        'user_id': entry.userId,
        'session_id': entry.sessionId,
        'topic_id': entry.topicId,
        'content': entry.content,
        'acts_step': entry.actsStep,
        'type': entry.type.name,
        'tags': entry.tags.join(','),
        'created_at': entry.createdAt.toIso8601String(),
        'updated_at': entry.updatedAt?.toIso8601String(),
      });
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<Map<String, dynamic>?> getSession(String sessionId) async {
    final db = await databaseHelper.database;
    final results = await db.query(
      'prayer_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    return results.isEmpty ? null : results.first;
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentSessions(
    String userId, {
    int limit = 10,
  }) async {
    final db = await databaseHelper.database;
    return await db.query(
      'prayer_sessions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'started_at DESC',
      limit: limit,
    );
  }
}
