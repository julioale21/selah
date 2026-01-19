import 'package:equatable/equatable.dart';

import '../../domain/entities/verse.dart';

class VersesState extends Equatable {
  final List<Verse> verses;
  final List<Verse> favorites;
  final Verse? dailyVerse;
  final String? selectedCategory;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  const VersesState({
    this.verses = const [],
    this.favorites = const [],
    this.dailyVerse,
    this.selectedCategory,
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  List<Verse> get filteredVerses {
    var result = verses;

    if (selectedCategory != null) {
      result = result.where((v) => v.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((v) =>
          v.textEs.toLowerCase().contains(query) ||
          v.reference.toLowerCase().contains(query) ||
          v.book.toLowerCase().contains(query) ||
          v.tags.any((t) => t.toLowerCase().contains(query))).toList();
    }

    return result;
  }

  List<String> get categories {
    final cats = verses.map((v) => v.category).toSet().toList();
    cats.sort();
    return cats;
  }

  VersesState copyWith({
    List<Verse>? verses,
    List<Verse>? favorites,
    Verse? dailyVerse,
    String? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
  }) {
    return VersesState(
      verses: verses ?? this.verses,
      favorites: favorites ?? this.favorites,
      dailyVerse: dailyVerse ?? this.dailyVerse,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        verses,
        favorites,
        dailyVerse,
        selectedCategory,
        searchQuery,
        isLoading,
        errorMessage,
      ];
}
