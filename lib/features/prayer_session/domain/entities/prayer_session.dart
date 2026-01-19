import 'package:equatable/equatable.dart';

class PrayerSession extends Equatable {
  final String id;
  final String userId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final List<String> topicsPrayed;
  final String? notes;
  final int? moodBefore;
  final int? moodAfter;

  const PrayerSession({
    required this.id,
    required this.userId,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds = 0,
    this.topicsPrayed = const [],
    this.notes,
    this.moodBefore,
    this.moodAfter,
  });

  bool get isActive => endedAt == null;

  Duration get duration => Duration(seconds: durationSeconds);

  PrayerSession copyWith({
    String? id,
    String? userId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    List<String>? topicsPrayed,
    String? notes,
    int? moodBefore,
    int? moodAfter,
  }) {
    return PrayerSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      topicsPrayed: topicsPrayed ?? this.topicsPrayed,
      notes: notes ?? this.notes,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        startedAt,
        endedAt,
        durationSeconds,
        topicsPrayed,
        notes,
        moodBefore,
        moodAfter,
      ];
}
