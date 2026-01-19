import 'package:equatable/equatable.dart';

import '../../../bible/domain/entities/verse.dart';
import '../../../prayer_topics/domain/entities/prayer_topic.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/prayer_session.dart';

enum SessionPhase { setup, adoration, confession, thanksgiving, supplication, summary }

class PrayerSessionState extends Equatable {
  final SessionPhase phase;
  final PrayerSession? session;
  final List<PrayerTopic> selectedTopics;
  final int currentTopicIndex;
  final List<JournalEntry> entries;
  final String? currentNote;
  final bool isLoading;
  final String? errorMessage;
  final Verse? currentVerse;

  const PrayerSessionState({
    this.phase = SessionPhase.setup,
    this.session,
    this.selectedTopics = const [],
    this.currentTopicIndex = 0,
    this.entries = const [],
    this.currentNote,
    this.isLoading = false,
    this.errorMessage,
    this.currentVerse,
  });

  PrayerTopic? get currentTopic {
    if (selectedTopics.isEmpty || currentTopicIndex >= selectedTopics.length) {
      return null;
    }
    return selectedTopics[currentTopicIndex];
  }

  String get phaseTitle {
    switch (phase) {
      case SessionPhase.setup:
        return 'Preparación';
      case SessionPhase.adoration:
        return 'Adoración';
      case SessionPhase.confession:
        return 'Confesión';
      case SessionPhase.thanksgiving:
        return 'Gratitud';
      case SessionPhase.supplication:
        return 'Súplica';
      case SessionPhase.summary:
        return 'Resumen';
    }
  }

  String get phaseDescription {
    switch (phase) {
      case SessionPhase.setup:
        return 'Selecciona los temas por los que deseas orar';
      case SessionPhase.adoration:
        return 'Alaba a Dios por quién es Él';
      case SessionPhase.confession:
        return 'Confiesa tus pecados y pide perdón';
      case SessionPhase.thanksgiving:
        return 'Agradece a Dios por sus bendiciones';
      case SessionPhase.supplication:
        return 'Presenta tus peticiones ante Dios';
      case SessionPhase.summary:
        return 'Revisa tu sesión de oración';
    }
  }

  double get progress {
    switch (phase) {
      case SessionPhase.setup:
        return 0.0;
      case SessionPhase.adoration:
        return 0.25;
      case SessionPhase.confession:
        return 0.50;
      case SessionPhase.thanksgiving:
        return 0.75;
      case SessionPhase.supplication:
        return 0.90;
      case SessionPhase.summary:
        return 1.0;
    }
  }

  bool get isSetup => phase == SessionPhase.setup;
  bool get isSummary => phase == SessionPhase.summary;
  bool get isAdoration => phase == SessionPhase.adoration;

  PrayerSessionState copyWith({
    SessionPhase? phase,
    PrayerSession? session,
    List<PrayerTopic>? selectedTopics,
    int? currentTopicIndex,
    List<JournalEntry>? entries,
    String? currentNote,
    bool clearNote = false,
    bool? isLoading,
    String? errorMessage,
    Verse? currentVerse,
    bool clearVerse = false,
  }) {
    return PrayerSessionState(
      phase: phase ?? this.phase,
      session: session ?? this.session,
      selectedTopics: selectedTopics ?? this.selectedTopics,
      currentTopicIndex: currentTopicIndex ?? this.currentTopicIndex,
      entries: entries ?? this.entries,
      currentNote: clearNote ? null : (currentNote ?? this.currentNote),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentVerse: clearVerse ? null : (currentVerse ?? this.currentVerse),
    );
  }

  @override
  List<Object?> get props => [
        phase,
        session,
        selectedTopics,
        currentTopicIndex,
        entries,
        currentNote,
        isLoading,
        errorMessage,
        currentVerse,
      ];
}
