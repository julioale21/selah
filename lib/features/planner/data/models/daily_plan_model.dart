import '../../domain/entities/daily_plan.dart';

class DailyPlanModel extends DailyPlan {
  const DailyPlanModel({
    required super.id,
    required super.userId,
    required super.date,
    required super.topicIds,
    super.isCompleted,
    super.completedAt,
    super.sessionId,
    super.notes,
  });

  factory DailyPlanModel.fromEntity(DailyPlan plan) {
    return DailyPlanModel(
      id: plan.id,
      userId: plan.userId,
      date: plan.date,
      topicIds: plan.topicIds,
      isCompleted: plan.isCompleted,
      completedAt: plan.completedAt,
      sessionId: plan.sessionId,
      notes: plan.notes,
    );
  }

  factory DailyPlanModel.fromMap(Map<String, dynamic> map) {
    return DailyPlanModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      topicIds: (map['topic_ids'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      sessionId: map['session_id'] as String?,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'topic_ids': topicIds.join(','),
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
      'session_id': sessionId,
      'notes': notes,
    };
  }
}
