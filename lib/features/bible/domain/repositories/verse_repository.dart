import '../entities/verse.dart';

abstract class VerseRepository {
  Future<List<Verse>> getAllVerses(String userId);
  Future<List<Verse>> getVersesByCategory(String userId, String category);
  Future<List<Verse>> searchVerses(String userId, String query);
  Future<Verse?> getVerseById(String id);
  Future<List<Verse>> getFavoriteVerses(String userId);
  Future<Verse> toggleFavorite(String userId, String verseId);
  Future<Verse> getDailyVerse(String userId);
  Future<Verse?> getRandomVerseByCategory(String category);
  Future<void> seedVersesFromJson();
}
