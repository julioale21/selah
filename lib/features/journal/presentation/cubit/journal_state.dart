import 'package:equatable/equatable.dart';

import '../../../prayer_session/domain/entities/journal_entry.dart';
import '../../domain/entities/answered_prayer.dart';

class JournalState extends Equatable {
  final List<JournalEntry> entries;
  final List<AnsweredPrayer> answeredPrayers;
  final List<AnsweredPrayer> pendingPrayers;
  final DateTime? selectedDate;
  final JournalEntryType? filterType;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  const JournalState({
    this.entries = const [],
    this.answeredPrayers = const [],
    this.pendingPrayers = const [],
    this.selectedDate,
    this.filterType,
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  List<JournalEntry> get filteredEntries {
    var result = entries;

    if (selectedDate != null) {
      result = result
          .where((e) =>
              e.createdAt.year == selectedDate!.year &&
              e.createdAt.month == selectedDate!.month &&
              e.createdAt.day == selectedDate!.day)
          .toList();
    }

    if (filterType != null) {
      result = result.where((e) => e.type == filterType).toList();
    }

    if (searchQuery.isNotEmpty) {
      result = result
          .where((e) =>
              e.content.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return result;
  }

  // Agrupar entradas por fecha
  Map<DateTime, List<JournalEntry>> get entriesByDate {
    final grouped = <DateTime, List<JournalEntry>>{};
    for (final entry in filteredEntries) {
      final date = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      grouped.putIfAbsent(date, () => []).add(entry);
    }
    // Ordenar por fecha descendente
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    return {for (final key in sortedKeys) key: grouped[key]!};
  }

  int get totalEntriesCount => entries.length;
  int get answeredCount => answeredPrayers.length;
  int get pendingCount => pendingPrayers.length;

  JournalState copyWith({
    List<JournalEntry>? entries,
    List<AnsweredPrayer>? answeredPrayers,
    List<AnsweredPrayer>? pendingPrayers,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    JournalEntryType? filterType,
    bool clearFilterType = false,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
  }) {
    return JournalState(
      entries: entries ?? this.entries,
      answeredPrayers: answeredPrayers ?? this.answeredPrayers,
      pendingPrayers: pendingPrayers ?? this.pendingPrayers,
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      filterType: clearFilterType ? null : (filterType ?? this.filterType),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        entries,
        answeredPrayers,
        pendingPrayers,
        selectedDate,
        filterType,
        searchQuery,
        isLoading,
        errorMessage,
      ];
}
