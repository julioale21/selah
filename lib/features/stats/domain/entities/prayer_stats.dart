import 'package:equatable/equatable.dart';

class PrayerStats extends Equatable {
  final int totalSessions;
  final int totalMinutes;
  final int totalTopicsPrayed;
  final int totalJournalEntries;
  final int answeredPrayers;
  final double averageSessionMinutes;
  final Map<String, int> minutesByPhase;
  final Map<String, int> sessionsByDay;
  final List<TopicStat> topTopics;

  const PrayerStats({
    this.totalSessions = 0,
    this.totalMinutes = 0,
    this.totalTopicsPrayed = 0,
    this.totalJournalEntries = 0,
    this.answeredPrayers = 0,
    this.averageSessionMinutes = 0,
    this.minutesByPhase = const {},
    this.sessionsByDay = const {},
    this.topTopics = const [],
  });

  String get totalTimeFormatted {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  String get averageTimeFormatted {
    final mins = averageSessionMinutes.round();
    return '${mins}m';
  }

  @override
  List<Object?> get props => [
        totalSessions,
        totalMinutes,
        totalTopicsPrayed,
        totalJournalEntries,
        answeredPrayers,
        averageSessionMinutes,
        minutesByPhase,
        sessionsByDay,
        topTopics,
      ];
}

class TopicStat extends Equatable {
  final String topicId;
  final String topicTitle;
  final int timesPrayed;
  final int totalMinutes;

  const TopicStat({
    required this.topicId,
    required this.topicTitle,
    required this.timesPrayed,
    required this.totalMinutes,
  });

  @override
  List<Object?> get props => [topicId, topicTitle, timesPrayed, totalMinutes];
}
