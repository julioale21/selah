import 'package:equatable/equatable.dart';

class AnsweredPrayer extends Equatable {
  final String id;
  final String userId;
  final String? topicId;
  final String prayerText;
  final String? answerText;
  final DateTime prayedAt;
  final DateTime? answeredAt;
  final bool isAnswered;

  const AnsweredPrayer({
    required this.id,
    required this.userId,
    this.topicId,
    required this.prayerText,
    this.answerText,
    required this.prayedAt,
    this.answeredAt,
    this.isAnswered = false,
  });

  AnsweredPrayer copyWith({
    String? id,
    String? userId,
    String? topicId,
    String? prayerText,
    String? answerText,
    DateTime? prayedAt,
    DateTime? answeredAt,
    bool? isAnswered,
  }) {
    return AnsweredPrayer(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      topicId: topicId ?? this.topicId,
      prayerText: prayerText ?? this.prayerText,
      answerText: answerText ?? this.answerText,
      prayedAt: prayedAt ?? this.prayedAt,
      answeredAt: answeredAt ?? this.answeredAt,
      isAnswered: isAnswered ?? this.isAnswered,
    );
  }

  Duration get waitingTime {
    final endDate = answeredAt ?? DateTime.now();
    return endDate.difference(prayedAt);
  }

  String get waitingTimeDisplay {
    final days = waitingTime.inDays;
    if (days == 0) return 'Hoy';
    if (days == 1) return '1 día';
    if (days < 30) return '$days días';
    if (days < 365) {
      final months = days ~/ 30;
      return months == 1 ? '1 mes' : '$months meses';
    }
    final years = days ~/ 365;
    return years == 1 ? '1 año' : '$years años';
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        topicId,
        prayerText,
        answerText,
        prayedAt,
        answeredAt,
        isAnswered,
      ];
}
