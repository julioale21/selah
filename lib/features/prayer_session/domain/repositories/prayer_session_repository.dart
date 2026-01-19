import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/prayer_session.dart';

abstract class PrayerSessionRepository {
  Future<void> saveSession(PrayerSession session);
  Future<void> saveJournalEntries(List<JournalEntry> entries);
  Future<PrayerSession?> getSession(String sessionId);
  Future<List<PrayerSession>> getRecentSessions(String userId, {int limit = 10});
}
