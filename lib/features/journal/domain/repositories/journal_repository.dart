import '../../../prayer_session/domain/entities/journal_entry.dart';
import '../entities/answered_prayer.dart';

abstract class JournalRepository {
  // Journal Entries
  Future<List<JournalEntry>> getJournalEntries(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    String? topicId,
    JournalEntryType? type,
  });

  Future<JournalEntry> addJournalEntry(JournalEntry entry);

  Future<JournalEntry> updateJournalEntry(JournalEntry entry);

  Future<void> deleteJournalEntry(String id);

  Future<List<JournalEntry>> searchJournalEntries(String userId, String query);

  // Answered Prayers
  Future<List<AnsweredPrayer>> getAnsweredPrayers(
    String userId, {
    String? topicId,
    bool? isAnswered,
  });

  Future<AnsweredPrayer> addPrayerRequest(AnsweredPrayer prayer);

  Future<AnsweredPrayer> markAsAnswered(String id, String answerText);

  Future<void> deletePrayerRequest(String id);

  Future<int> getAnsweredCount(String userId);

  Future<int> getPendingCount(String userId);
}
