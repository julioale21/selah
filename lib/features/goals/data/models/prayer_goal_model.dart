import '../../domain/entities/prayer_goal.dart';

class PrayerGoalModel extends PrayerGoal {
  const PrayerGoalModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.targetMinutes,
    super.isActive,
    required super.createdAt,
    super.updatedAt,
  });

  factory PrayerGoalModel.fromMap(Map<String, dynamic> map) {
    return PrayerGoalModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: _goalTypeFromString(map['goal_type'] as String),
      targetMinutes: map['target_minutes'] as int,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  factory PrayerGoalModel.fromEntity(PrayerGoal goal) {
    return PrayerGoalModel(
      id: goal.id,
      userId: goal.userId,
      type: goal.type,
      targetMinutes: goal.targetMinutes,
      isActive: goal.isActive,
      createdAt: goal.createdAt,
      updatedAt: goal.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'goal_type': _goalTypeToString(type),
      'target_minutes': targetMinutes,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  PrayerGoalModel copyWith({
    String? id,
    String? userId,
    GoalType? type,
    int? targetMinutes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PrayerGoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static GoalType _goalTypeFromString(String value) {
    switch (value) {
      case 'daily_duration':
        return GoalType.dailyDuration;
      case 'weekly_duration':
        return GoalType.weeklyDuration;
      case 'monthly_duration':
        return GoalType.monthlyDuration;
      case 'annual_duration':
        return GoalType.annualDuration;
      default:
        return GoalType.dailyDuration;
    }
  }

  static String _goalTypeToString(GoalType type) {
    switch (type) {
      case GoalType.dailyDuration:
        return 'daily_duration';
      case GoalType.weeklyDuration:
        return 'weekly_duration';
      case GoalType.monthlyDuration:
        return 'monthly_duration';
      case GoalType.annualDuration:
        return 'annual_duration';
    }
  }
}
