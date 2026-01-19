import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/user_service.dart';
import '../../../prayer_session/domain/entities/journal_entry.dart';
import '../../domain/entities/answered_prayer.dart';
import '../../domain/repositories/journal_repository.dart';
import 'journal_state.dart';

class JournalCubit extends Cubit<JournalState> {
  final JournalRepository repository;
  final UserService userService;
  static const _uuid = Uuid();

  JournalCubit({
    required this.repository,
    required this.userService,
  }) : super(const JournalState());

  String get _userId => userService.currentUserId;

  Future<void> loadJournalEntries() async {
    emit(state.copyWith(isLoading: true));

    try {
      final entries = await repository.getJournalEntries(_userId);
      emit(state.copyWith(isLoading: false, entries: entries));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar entradas: $e',
      ));
    }
  }

  Future<void> loadAnsweredPrayers() async {
    try {
      final answered =
          await repository.getAnsweredPrayers(_userId, isAnswered: true);
      final pending =
          await repository.getAnsweredPrayers(_userId, isAnswered: false);

      emit(state.copyWith(
        answeredPrayers: answered,
        pendingPrayers: pending,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Error al cargar oraciones: $e',
      ));
    }
  }

  Future<void> loadAll() async {
    emit(state.copyWith(isLoading: true));
    await Future.wait([
      loadJournalEntries(),
      loadAnsweredPrayers(),
    ]);
    emit(state.copyWith(isLoading: false));
  }

  Future<void> addEntry({
    required String content,
    required JournalEntryType type,
    String? topicId,
    String? sessionId,
    String? actsStep,
    List<String> tags = const [],
  }) async {
    final entry = JournalEntry(
      id: _uuid.v4(),
      userId: _userId,
      sessionId: sessionId,
      topicId: topicId,
      content: content,
      actsStep: actsStep,
      type: type,
      tags: tags,
      createdAt: DateTime.now(),
    );

    try {
      final newEntry = await repository.addJournalEntry(entry);
      final updated = [newEntry, ...state.entries];
      emit(state.copyWith(entries: updated));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al guardar entrada: $e'));
    }
  }

  Future<void> updateEntry(JournalEntry entry) async {
    try {
      final updatedEntry = await repository.updateJournalEntry(entry);
      final updated =
          state.entries.map((e) => e.id == updatedEntry.id ? updatedEntry : e).toList();
      emit(state.copyWith(entries: updated));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al actualizar entrada: $e'));
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await repository.deleteJournalEntry(id);
      final updated = state.entries.where((e) => e.id != id).toList();
      emit(state.copyWith(entries: updated));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al eliminar entrada: $e'));
    }
  }

  Future<void> addPrayerRequest({
    required String prayerText,
    String? topicId,
  }) async {
    final prayer = AnsweredPrayer(
      id: _uuid.v4(),
      userId: _userId,
      topicId: topicId,
      prayerText: prayerText,
      prayedAt: DateTime.now(),
    );

    try {
      final newPrayer = await repository.addPrayerRequest(prayer);
      final updated = [newPrayer, ...state.pendingPrayers];
      emit(state.copyWith(pendingPrayers: updated));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al guardar petición: $e'));
    }
  }

  Future<void> markPrayerAsAnswered(String id, String answerText) async {
    try {
      final answeredPrayer = await repository.markAsAnswered(id, answerText);
      final updatedPending =
          state.pendingPrayers.where((p) => p.id != id).toList();
      final updatedAnswered = [answeredPrayer, ...state.answeredPrayers];
      emit(state.copyWith(
        pendingPrayers: updatedPending,
        answeredPrayers: updatedAnswered,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al marcar como respondida: $e'));
    }
  }

  Future<void> deletePrayerRequest(String id) async {
    try {
      await repository.deletePrayerRequest(id);
      final updatedPending =
          state.pendingPrayers.where((p) => p.id != id).toList();
      final updatedAnswered =
          state.answeredPrayers.where((p) => p.id != id).toList();
      emit(state.copyWith(
        pendingPrayers: updatedPending,
        answeredPrayers: updatedAnswered,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al eliminar petición: $e'));
    }
  }

  void filterByDate(DateTime? date) {
    if (date == null) {
      emit(state.copyWith(clearSelectedDate: true));
    } else {
      emit(state.copyWith(selectedDate: date));
    }
  }

  void filterByType(JournalEntryType? type) {
    if (type == null) {
      emit(state.copyWith(clearFilterType: true));
    } else {
      emit(state.copyWith(filterType: type));
    }
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void clearFilters() {
    emit(state.copyWith(
      clearSelectedDate: true,
      clearFilterType: true,
      searchQuery: '',
    ));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
