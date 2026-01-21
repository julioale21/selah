import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/user_service.dart';
import '../../../bible/domain/repositories/verse_repository.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../prayer_topics/domain/entities/prayer_topic.dart';
import '../../../prayer_topics/domain/repositories/prayer_topic_repository.dart';
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
  final PrayerTopicRepository topicRepository;
  final CategoryRepository categoryRepository;
  static const _uuid = Uuid();

  PrayerSessionCubit({
    required this.userService,
    required this.verseRepository,
    required this.settingsRepository,
    required this.sessionRepository,
    required this.topicRepository,
    required this.categoryRepository,
  }) : super(const PrayerSessionState());

  String get _userId => userService.currentUserId;

  /// Initialize the session - load topics and start immediately
  Future<void> initializeSession({List<String>? topicIds}) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Ensure verses are seeded/updated
      await verseRepository.seedVersesFromJson();

      // Load topics - either specific ones or all
      final topicsResult = await topicRepository.getTopics(_userId);

      final topics = topicsResult.fold<List<PrayerTopic>>(
        (failure) => <PrayerTopic>[],
        (allTopics) {
          if (topicIds != null && topicIds.isNotEmpty) {
            return allTopics.where((t) => topicIds.contains(t.id)).toList();
          }
          return allTopics;
        },
      );

      // Check if focus mode is the default
      final prefs = await settingsRepository.getPreferences(_userId);
      final startInFocusMode = prefs.defaultFocusMode;

      final session = PrayerSession(
        id: _uuid.v4(),
        userId: _userId,
        startedAt: DateTime.now(),
        topicsPrayed: topics.map((t) => t.id).toList(),
      );

      emit(state.copyWith(
        session: session,
        selectedTopics: topics,
        phase: SessionPhase.adoration,
        isFocusMode: startInFocusMode,
        isLoading: false,
      ));

      // Load verse for the first phase
      await _loadVerseForPhase(SessionPhase.adoration);
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Error al iniciar sesión: $e',
      ));
    }
  }

  Future<void> _loadVerseForPhase(SessionPhase phase) async {
    // In Supplication phase, load verse based on current topic's category
    if (phase == SessionPhase.supplication) {
      await _loadVerseForCurrentTopic();
      return;
    }

    final category = _getCategoryForPhase(phase);
    if (category == null) return;

    final verse = await verseRepository.getRandomVerseByCategory(category);
    emit(state.copyWith(currentVerse: verse, clearVerse: verse == null));
  }

  Future<void> _loadVerseForCurrentTopic() async {
    final topic = state.currentTopic;
    if (topic == null || topic.categoryId == null) {
      // Fall back to generic supplication verse
      final verse = await verseRepository.getRandomVerseByCategory('súplica');
      emit(state.copyWith(currentVerse: verse, clearVerse: verse == null));
      return;
    }

    // Get the category name from the topic's categoryId
    final categoryResult = await categoryRepository.getCategoryById(topic.categoryId!);
    final categoryName = categoryResult.fold(
      (failure) => null,
      (category) => category.name.toLowerCase(),
    );

    if (categoryName != null) {
      // Try to get a verse for this specific category
      var verse = await verseRepository.getRandomVerseByCategory(categoryName);

      // If no verse found for this category, fall back to supplication
      verse ??= await verseRepository.getRandomVerseByCategory('súplica');

      emit(state.copyWith(currentVerse: verse, clearVerse: verse == null));
    } else {
      // Fall back to generic supplication verse
      final verse = await verseRepository.getRandomVerseByCategory('súplica');
      emit(state.copyWith(currentVerse: verse, clearVerse: verse == null));
    }
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
    if (state.isSupplication) {
      await _loadVerseForCurrentTopic();
    } else {
      await _loadVerseForPhase(state.phase);
    }
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

    if (currentIndex > 0) {
      // Don't go before adoration
      final newPhase = phases[currentIndex - 1];
      emit(state.copyWith(phase: newPhase));
      await _loadVerseForPhase(newPhase);
    }
  }

  void goToPhase(SessionPhase phase) async {
    if (phase == SessionPhase.summary) return;
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

  /// Save an entry with the provided content (used from focus mode)
  void saveEntryWithContent(String content) {
    if (content.trim().isEmpty) return;

    final entry = JournalEntry(
      id: _uuid.v4(),
      userId: _userId,
      sessionId: state.session?.id,
      topicId: state.currentTopic?.id,
      content: content.trim(),
      actsStep: state.phase.name,
      createdAt: DateTime.now(),
    );

    final updatedEntries = [...state.entries, entry];
    emit(state.copyWith(entries: updatedEntries));
  }

  void nextTopic() async {
    if (state.currentTopicIndex < state.selectedTopics.length - 1) {
      emit(state.copyWith(currentTopicIndex: state.currentTopicIndex + 1));
      await _loadVerseForCurrentTopic();
    }
  }

  void previousTopic() async {
    if (state.currentTopicIndex > 0) {
      emit(state.copyWith(currentTopicIndex: state.currentTopicIndex - 1));
      await _loadVerseForCurrentTopic();
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

      // Increment prayer count for each topic prayed
      for (final topic in state.selectedTopics) {
        await topicRepository.incrementPrayerCount(topic.id);
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
