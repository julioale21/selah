import '../../domain/entities/verse.dart';
import '../../domain/repositories/verse_repository.dart';
import '../datasources/verse_local_datasource.dart';

class VerseRepositoryImpl implements VerseRepository {
  final VerseLocalDataSource localDataSource;

  VerseRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Verse>> getAllVerses(String userId) async {
    final verses = await localDataSource.getAllVerses();
    final favoriteIds = await localDataSource.getFavoriteVerseIds(userId);

    return verses.map((v) => v.copyWith(
      isFavorite: favoriteIds.contains(v.id),
    )).toList();
  }

  @override
  Future<List<Verse>> getVersesByCategory(String userId, String category) async {
    final verses = await localDataSource.getVersesByCategory(category);
    final favoriteIds = await localDataSource.getFavoriteVerseIds(userId);

    return verses.map((v) => v.copyWith(
      isFavorite: favoriteIds.contains(v.id),
    )).toList();
  }

  @override
  Future<List<Verse>> searchVerses(String userId, String query) async {
    final verses = await localDataSource.searchVerses(query);
    final favoriteIds = await localDataSource.getFavoriteVerseIds(userId);

    return verses.map((v) => v.copyWith(
      isFavorite: favoriteIds.contains(v.id),
    )).toList();
  }

  @override
  Future<Verse?> getVerseById(String id) async {
    return await localDataSource.getVerseById(id);
  }

  @override
  Future<List<Verse>> getFavoriteVerses(String userId) async {
    final favoriteIds = await localDataSource.getFavoriteVerseIds(userId);
    final verses = <Verse>[];

    for (final id in favoriteIds) {
      final verse = await localDataSource.getVerseById(id);
      if (verse != null) {
        verses.add(verse.copyWith(isFavorite: true));
      }
    }

    return verses;
  }

  @override
  Future<Verse> toggleFavorite(String userId, String verseId) async {
    final isFavorite = await localDataSource.isFavorite(userId, verseId);

    if (isFavorite) {
      await localDataSource.removeFavorite(userId, verseId);
    } else {
      await localDataSource.addFavorite(userId, verseId);
    }

    final verse = await localDataSource.getVerseById(verseId);
    return verse!.copyWith(isFavorite: !isFavorite);
  }

  @override
  Future<Verse> getDailyVerse(String userId) async {
    final verse = await localDataSource.getDailyVerse(userId);
    final isFavorite = await localDataSource.isFavorite(userId, verse.id);
    return verse.copyWith(isFavorite: isFavorite);
  }

  @override
  Future<Verse?> getRandomVerseByCategory(String category) async {
    return await localDataSource.getRandomVerseByCategory(category);
  }

  @override
  Future<void> seedVersesFromJson() async {
    final count = await localDataSource.getVersesCount();
    if (count == 0) {
      await localDataSource.seedVersesFromJson();
    }
  }
}
