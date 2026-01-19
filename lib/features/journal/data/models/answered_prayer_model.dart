import '../../domain/entities/answered_prayer.dart';

class AnsweredPrayerModel extends AnsweredPrayer {
  const AnsweredPrayerModel({
    required super.id,
    required super.userId,
    super.topicId,
    required super.prayerText,
    super.answerText,
    required super.prayedAt,
    super.answeredAt,
    super.isAnswered,
  });

  factory AnsweredPrayerModel.fromEntity(AnsweredPrayer prayer) {
    return AnsweredPrayerModel(
      id: prayer.id,
      userId: prayer.userId,
      topicId: prayer.topicId,
      prayerText: prayer.prayerText,
      answerText: prayer.answerText,
      prayedAt: prayer.prayedAt,
      answeredAt: prayer.answeredAt,
      isAnswered: prayer.isAnswered,
    );
  }

  factory AnsweredPrayerModel.fromMap(Map<String, dynamic> map) {
    return AnsweredPrayerModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      topicId: map['topic_id'] as String?,
      prayerText: map['prayer_text'] as String,
      answerText: map['answer_text'] as String?,
      prayedAt: DateTime.parse(map['prayed_at'] as String),
      answeredAt: map['answered_at'] != null
          ? DateTime.parse(map['answered_at'] as String)
          : null,
      isAnswered: (map['is_answered'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'topic_id': topicId,
      'prayer_text': prayerText,
      'answer_text': answerText,
      'prayed_at': prayedAt.toIso8601String(),
      'answered_at': answeredAt?.toIso8601String(),
      'is_answered': isAnswered ? 1 : 0,
    };
  }
}
