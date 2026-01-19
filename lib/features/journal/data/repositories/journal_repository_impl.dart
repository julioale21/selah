import '../../../prayer_session/domain/entities/journal_entry.dart';
import '../../domain/entities/answered_prayer.dart';
import '../../domain/repositories/journal_repository.dart';
import '../datasources/journal_local_datasource.dart';
import '../models/answered_prayer_model.dart';
import '../models/journal_entry_model.dart';

class JournalRepositoryImpl implements JournalRepository {
  final JournalLocalDataSource localDataSource;

  JournalRepositoryImpl({required this.localDataSource});

  @override
  Future<List<JournalEntry>> getJournalEntries(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    String? topicId,
    JournalEntryType? type,
  }) async {
    return await localDataSource.getJournalEntries(
      userId,
      startDate: startDate,
      endDate: endDate,
      topicId: topicId,
      type: type,
    );
  }

  @override
  Future<JournalEntry> addJournalEntry(JournalEntry entry) async {
    final model = JournalEntryModel.fromEntity(entry);
    return await localDataSource.addJournalEntry(model);
  }

  @override
  Future<JournalEntry> updateJournalEntry(JournalEntry entry) async {
    final model = JournalEntryModel.fromEntity(entry);
    return await localDataSource.updateJournalEntry(model);
  }

  @override
  Future<void> deleteJournalEntry(String id) async {
    await localDataSource.deleteJournalEntry(id);
  }

  @override
  Future<List<JournalEntry>> searchJournalEntries(
      String userId, String query) async {
    return await localDataSource.searchJournalEntries(userId, query);
  }

  @override
  Future<List<AnsweredPrayer>> getAnsweredPrayers(
    String userId, {
    String? topicId,
    bool? isAnswered,
  }) async {
    return await localDataSource.getAnsweredPrayers(
      userId,
      topicId: topicId,
      isAnswered: isAnswered,
    );
  }

  @override
  Future<AnsweredPrayer> addPrayerRequest(AnsweredPrayer prayer) async {
    final model = AnsweredPrayerModel.fromEntity(prayer);
    return await localDataSource.addPrayerRequest(model);
  }

  @override
  Future<AnsweredPrayer> markAsAnswered(String id, String answerText) async {
    return await localDataSource.markAsAnswered(id, answerText);
  }

  @override
  Future<void> deletePrayerRequest(String id) async {
    await localDataSource.deletePrayerRequest(id);
  }

  @override
  Future<int> getAnsweredCount(String userId) async {
    return await localDataSource.getAnsweredCount(userId);
  }

  @override
  Future<int> getPendingCount(String userId) async {
    return await localDataSource.getPendingCount(userId);
  }
}
