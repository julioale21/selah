import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/user_service.dart';
import '../../../bible/domain/repositories/verse_repository.dart';
import '../../../prayer_topics/domain/entities/prayer_topic.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/prayer_session.dart';
import '../../domain/repositories/prayer_session_repository.dart';
import 'prayer_session_state.dart';

class PrayerSessionCubit extends Cubit<PrayerSessionState> {
  final UserService userService;
  final VerseRepository verseRepository;
  final SettingsRepository settingsRepository;
  final PrayerSessionRepository sessionRepository;
  static const _uuid = Uuid();

  PrayerSessionCubit({
    required this.userService,
    required this.verseRepository,
    required this.settingsRepository,
    required this.sessionRepository,
  }) : super(const PrayerSessionState());

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

  void startSession() async {
    if (state.selectedTopics.isEmpty) {
      emit(state.copyWith(errorMessage: 'Selecciona al menos un tema'));
      return;
    }

    // Check if focus mode is the default
    final prefs = await settingsRepository.getPreferences(_userId);
    final startInFocusMode = prefs.defaultFocusMode;

    final session = PrayerSession(
      id: _uuid.v4(),
      userId: _userId,
      startedAt: DateTime.now(),
      topicsPrayed: state.selectedTopics.map((t) => t.id).toList(),
    );

    emit(state.copyWith(
      session: session,
      phase: SessionPhase.adoration,
      isFocusMode: startInFocusMode,
    ));

    // Load verse for the first phase
    await _loadVerseForPhase(SessionPhase.adoration);
  }

  Future<void> _loadVerseForPhase(SessionPhase phase) async {
    final category = _getCategoryForPhase(phase);
    if (category == null) return;

    final verse = await verseRepository.getRandomVerseByCategory(category);
    emit(state.copyWith(currentVerse: verse, clearVerse: verse == null));
  }

  String? _getCategoryForPhase(SessionPhase phase) {
    switch (phase) {
      case SessionPhase.adoration:
        return 'adoración';
      case SessionPhase.confession:
        return 'confesión';
      case SessionPhase.thanksgiving:
        return 'gratitud';
      case SessionPhase.supplication:
        return 'súplica';
      default:
        return null;
    }
  }

  Future<void> refreshVerse() async {
    await _loadVerseForPhase(state.phase);
  }

  void nextPhase() async {
    final phases = SessionPhase.values;
    final currentIndex = phases.indexOf(state.phase);

    if (currentIndex < phases.length - 1) {
      final newPhase = phases[currentIndex + 1];
      emit(state.copyWith(phase: newPhase));
      await _loadVerseForPhase(newPhase);
    }
  }

  void previousPhase() async {
    final phases = SessionPhase.values;
    final currentIndex = phases.indexOf(state.phase);

    if (currentIndex > 1) {
      // Don't go before adoration
      final newPhase = phases[currentIndex - 1];
      emit(state.copyWith(phase: newPhase));
      await _loadVerseForPhase(newPhase);
    }
  }

  void goToPhase(SessionPhase phase) async {
    if (phase == SessionPhase.setup) return;
    emit(state.copyWith(phase: phase));
    await _loadVerseForPhase(phase);
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

    try {
      // Save session to database
      await sessionRepository.saveSession(finishedSession);

      // Save journal entries to database
      if (state.entries.isNotEmpty) {
        await sessionRepository.saveJournalEntries(state.entries);
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al guardar sesión: $e'));
    }

    emit(state.copyWith(
      session: finishedSession,
      phase: SessionPhase.summary,
    ));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  void toggleFocusMode() {
    emit(state.copyWith(isFocusMode: !state.isFocusMode));
  }

  void exitFocusMode() {
    emit(state.copyWith(isFocusMode: false));
  }

  void reset() {
    emit(const PrayerSessionState());
  }
}
