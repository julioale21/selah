import '../../../../core/database/database_helper.dart';
import '../../../prayer_session/domain/entities/journal_entry.dart';
import '../models/answered_prayer_model.dart';
import '../models/journal_entry_model.dart';

abstract class JournalLocalDataSource {
  // Journal Entries
  Future<List<JournalEntryModel>> getJournalEntries(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    String? topicId,
    JournalEntryType? type,
  });

  Future<JournalEntryModel> addJournalEntry(JournalEntryModel entry);

  Future<JournalEntryModel> updateJournalEntry(JournalEntryModel entry);

  Future<void> deleteJournalEntry(String id);

  Future<List<JournalEntryModel>> searchJournalEntries(
      String userId, String query);

  // Answered Prayers
  Future<List<AnsweredPrayerModel>> getAnsweredPrayers(
    String userId, {
    String? topicId,
    bool? isAnswered,
  });

  Future<AnsweredPrayerModel> addPrayerRequest(AnsweredPrayerModel prayer);

  Future<AnsweredPrayerModel> markAsAnswered(String id, String answerText);

  Future<void> deletePrayerRequest(String id);

  Future<int> getAnsweredCount(String userId);

  Future<int> getPendingCount(String userId);
}

class JournalLocalDataSourceImpl implements JournalLocalDataSource {
  final DatabaseHelper databaseHelper;

  JournalLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<JournalEntryModel>> getJournalEntries(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    String? topicId,
    JournalEntryType? type,
  }) async {
    final conditions = <String>['user_id = ?'];
    final args = <Object?>[userId];

    if (startDate != null) {
      conditions.add('created_at >= ?');
      args.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      conditions.add('created_at <= ?');
      args.add(endDate.toIso8601String());
    }

    if (topicId != null) {
      conditions.add('topic_id = ?');
      args.add(topicId);
    }

    if (type != null) {
      conditions.add('type = ?');
      args.add(type.name);
    }

    final results = await databaseHelper.query(
      'journal_entries',
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'created_at DESC',
    );

    return results.map((map) => JournalEntryModel.fromMap(map)).toList();
  }

  @override
  Future<JournalEntryModel> addJournalEntry(JournalEntryModel entry) async {
    await databaseHelper.insert('journal_entries', entry.toMap());
    return entry;
  }

  @override
  Future<JournalEntryModel> updateJournalEntry(JournalEntryModel entry) async {
    final updatedEntry = JournalEntryModel(
      id: entry.id,
      userId: entry.userId,
      sessionId: entry.sessionId,
      topicId: entry.topicId,
      content: entry.content,
      actsStep: entry.actsStep,
      type: entry.type,
      tags: entry.tags,
      createdAt: entry.createdAt,
      updatedAt: DateTime.now(),
    );

    await databaseHelper.update(
      'journal_entries',
      updatedEntry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );

    return updatedEntry;
  }

  @override
  Future<void> deleteJournalEntry(String id) async {
    await databaseHelper.delete(
      'journal_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<JournalEntryModel>> searchJournalEntries(
      String userId, String query) async {
    final lowerQuery = '%${query.toLowerCase()}%';
    final results = await databaseHelper.rawQuery('''
      SELECT * FROM journal_entries
      WHERE user_id = ?
        AND (LOWER(content) LIKE ? OR LOWER(tags) LIKE ?)
      ORDER BY created_at DESC
    ''', [userId, lowerQuery, lowerQuery]);

    return results.map((map) => JournalEntryModel.fromMap(map)).toList();
  }

  // Answered Prayers

  @override
  Future<List<AnsweredPrayerModel>> getAnsweredPrayers(
    String userId, {
    String? topicId,
    bool? isAnswered,
  }) async {
    final conditions = <String>['user_id = ?'];
    final args = <Object?>[userId];

    if (topicId != null) {
      conditions.add('topic_id = ?');
      args.add(topicId);
    }

    if (isAnswered != null) {
      conditions.add('is_answered = ?');
      args.add(isAnswered ? 1 : 0);
    }

    final results = await databaseHelper.query(
      'answered_prayers',
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'prayed_at DESC',
    );

    return results.map((map) => AnsweredPrayerModel.fromMap(map)).toList();
  }

  @override
  Future<AnsweredPrayerModel> addPrayerRequest(
      AnsweredPrayerModel prayer) async {
    await databaseHelper.insert('answered_prayers', prayer.toMap());
    return prayer;
  }

  @override
  Future<AnsweredPrayerModel> markAsAnswered(
      String id, String answerText) async {
    final now = DateTime.now();

    await databaseHelper.update(
      'answered_prayers',
      {
        'is_answered': 1,
        'answer_text': answerText,
        'answered_at': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    final results = await databaseHelper.query(
      'answered_prayers',
      where: 'id = ?',
      whereArgs: [id],
    );

    return AnsweredPrayerModel.fromMap(results.first);
  }

  @override
  Future<void> deletePrayerRequest(String id) async {
    await databaseHelper.delete(
      'answered_prayers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> getAnsweredCount(String userId) async {
    return await databaseHelper.count(
      'answered_prayers',
      where: 'user_id = ? AND is_answered = 1',
      whereArgs: [userId],
    );
  }

  @override
  Future<int> getPendingCount(String userId) async {
    return await databaseHelper.count(
      'answered_prayers',
      where: 'user_id = ? AND is_answered = 0',
      whereArgs: [userId],
    );
  }
}
