import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/user_service.dart';
import '../../../prayer_topics/domain/entities/prayer_topic.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/prayer_session.dart';
import 'prayer_session_state.dart';

class PrayerSessionCubit extends Cubit<PrayerSessionState> {
  final UserService userService;
  static const _uuid = Uuid();

  PrayerSessionCubit({required this.userService})
      : super(const PrayerSessionState());

  String get _userId => userService.currentUserId;

  void selectTopics(List<PrayerTopic> topics) {
    emit(state.copyWith(selectedTopics: topics));
  }

  void toggleTopic(PrayerTopic topic) {
    final current = List<PrayerTopic>.from(state.selectedTopics);
    final index = current.indexWhere((t) => t.id == topic.id);
    if (index >= 0) {
      current.removeAt(index);
    } else {
      current.add(topic);
    }
    emit(state.copyWith(selectedTopics: current));
  }

  bool isTopicSelected(String topicId) {
    return state.selectedTopics.any((t) => t.id == topicId);
  }

  void startSession() {
    if (state.selectedTopics.isEmpty) {
      emit(state.copyWith(errorMessage: 'Selecciona al menos un tema'));
      return;
    }

    final session = PrayerSession(
      id: _uuid.v4(),
      userId: _userId,
      startedAt: DateTime.now(),
      topicsPrayed: state.selectedTopics.map((t) => t.id).toList(),
    );

    emit(state.copyWith(
      session: session,
      phase: SessionPhase.adoration,
    ));
  }

  void nextPhase() {
    final phases = SessionPhase.values;
    final currentIndex = phases.indexOf(state.phase);

    if (currentIndex < phases.length - 1) {
      emit(state.copyWith(phase: phases[currentIndex + 1]));
    }
  }

  void previousPhase() {
    final phases = SessionPhase.values;
    final currentIndex = phases.indexOf(state.phase);

    if (currentIndex > 1) {
      // Don't go before adoration
      emit(state.copyWith(phase: phases[currentIndex - 1]));
    }
  }

  void goToPhase(SessionPhase phase) {
    if (phase == SessionPhase.setup) return;
    emit(state.copyWith(phase: phase));
  }

  void updateNote(String note) {
    emit(state.copyWith(currentNote: note));
  }

  void saveEntry() {
    if (state.currentNote == null || state.currentNote!.trim().isEmpty) return;

    final entry = JournalEntry(
      id: _uuid.v4(),
      userId: _userId,
      sessionId: state.session?.id,
      topicId: state.currentTopic?.id,
      content: state.currentNote!.trim(),
      actsStep: state.phase.name,
      createdAt: DateTime.now(),
    );

    final updatedEntries = [...state.entries, entry];
    emit(state.copyWith(
      entries: updatedEntries,
      clearNote: true,
    ));
  }

  void nextTopic() {
    if (state.currentTopicIndex < state.selectedTopics.length - 1) {
      emit(state.copyWith(currentTopicIndex: state.currentTopicIndex + 1));
    }
  }

  void previousTopic() {
    if (state.currentTopicIndex > 0) {
      emit(state.copyWith(currentTopicIndex: state.currentTopicIndex - 1));
    }
  }

  Future<void> finishSession(int elapsedSeconds) async {
    if (state.session == null) return;

    final finishedSession = state.session!.copyWith(
      endedAt: DateTime.now(),
      durationSeconds: elapsedSeconds,
    );

    // TODO: Save session and entries to repository

    emit(state.copyWith(
      session: finishedSession,
      phase: SessionPhase.summary,
    ));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  void reset() {
    emit(const PrayerSessionState());
  }
}
