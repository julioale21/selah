import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/user_service.dart';
import '../../domain/repositories/verse_repository.dart';
import 'verses_state.dart';

class VersesCubit extends Cubit<VersesState> {
  final VerseRepository repository;
  final UserService userService;

  VersesCubit({
    required this.repository,
    required this.userService,
  }) : super(const VersesState());

  String get _userId => userService.currentUserId;

  Future<void> loadVerses() async {
    emit(state.copyWith(isLoading: true));

    try {
      // Seed verses if needed
      await repository.seedVersesFromJson();

      final verses = await repository.getAllVerses(_userId);

      emit(state.copyWith(
        isLoading: false,
        verses: verses,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar versículos: $e',
      ));
    }
  }

  Future<void> loadDailyVerse() async {
    try {
      // Seed verses if needed
      await repository.seedVersesFromJson();

      final verse = await repository.getDailyVerse(_userId);
      emit(state.copyWith(dailyVerse: verse));
    } catch (e) {
      // Silently fail for daily verse
    }
  }

  Future<void> loadFavorites() async {
    try {
      final favorites = await repository.getFavoriteVerses(_userId);
      emit(state.copyWith(favorites: favorites));
    } catch (e) {
      // Silently fail
    }
  }

  void filterByCategory(String? category) {
    if (category == null) {
      emit(state.copyWith(clearCategory: true));
    } else {
      emit(state.copyWith(selectedCategory: category));
    }
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void clearSearch() {
    emit(state.copyWith(searchQuery: ''));
  }

  Future<void> toggleFavorite(String verseId) async {
    try {
      final updatedVerse = await repository.toggleFavorite(_userId, verseId);

      // Update in verses list
      final updatedVerses = state.verses.map((v) {
        return v.id == verseId ? updatedVerse : v;
      }).toList();

      // Update favorites
      final updatedFavorites = updatedVerse.isFavorite
          ? [...state.favorites, updatedVerse]
          : state.favorites.where((v) => v.id != verseId).toList();

      // Update daily verse if same
      final updatedDaily = state.dailyVerse?.id == verseId
          ? updatedVerse
          : state.dailyVerse;

      emit(state.copyWith(
        verses: updatedVerses,
        favorites: updatedFavorites,
        dailyVerse: updatedDaily,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al actualizar favorito'));
    }
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
