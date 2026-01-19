import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/prayer_session.dart';
import '../../domain/repositories/prayer_session_repository.dart';
import '../datasources/prayer_session_local_datasource.dart';

class PrayerSessionRepositoryImpl implements PrayerSessionRepository {
  final PrayerSessionLocalDataSource localDataSource;

  PrayerSessionRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveSession(PrayerSession session) async {
    await localDataSource.saveSession(session);
  }

  @override
  Future<void> saveJournalEntries(List<JournalEntry> entries) async {
    if (entries.isNotEmpty) {
      await localDataSource.saveJournalEntries(entries);
    }
  }

  @override
  Future<PrayerSession?> getSession(String sessionId) async {
    final data = await localDataSource.getSession(sessionId);
    if (data == null) return null;

    return PrayerSession(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      startedAt: DateTime.parse(data['started_at'] as String),
      endedAt: data['ended_at'] != null
          ? DateTime.parse(data['ended_at'] as String)
          : null,
      durationSeconds: data['duration_seconds'] as int? ?? 0,
      topicsPrayed: (data['topics_prayed'] as String?)?.split(',') ?? [],
      notes: data['notes'] as String?,
      moodBefore: data['mood_before'] as int?,
      moodAfter: data['mood_after'] as int?,
    );
  }

  @override
  Future<List<PrayerSession>> getRecentSessions(
    String userId, {
    int limit = 10,
  }) async {
    final results = await localDataSource.getRecentSessions(userId, limit: limit);
    return results.map((data) {
      return PrayerSession(
        id: data['id'] as String,
        userId: data['user_id'] as String,
        startedAt: DateTime.parse(data['started_at'] as String),
        endedAt: data['ended_at'] != null
            ? DateTime.parse(data['ended_at'] as String)
            : null,
        durationSeconds: data['duration_seconds'] as int? ?? 0,
        topicsPrayed: (data['topics_prayed'] as String?)?.split(',') ?? [],
        notes: data['notes'] as String?,
        moodBefore: data['mood_before'] as int?,
        moodAfter: data['mood_after'] as int?,
      );
    }).toList();
  }
}
