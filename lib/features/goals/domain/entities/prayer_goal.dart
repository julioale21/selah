import 'package:equatable/equatable.dart';

enum GoalType {
  dailyDuration,
  weeklyDuration,
  sessionsPerWeek,
}

class PrayerGoal extends Equatable {
  final String id;
  final String userId;
  final GoalType type;
  final int targetMinutes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PrayerGoal({
    required this.id,
    required this.userId,
    required this.type,
    required this.targetMinutes,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Returns the goal type as a display string in Spanish
  String get typeDisplayName {
    switch (type) {
      case GoalType.dailyDuration:
        return 'Meta diaria';
      case GoalType.weeklyDuration:
        return 'Meta semanal';
      case GoalType.sessionsPerWeek:
        return 'Sesiones por semana';
    }
  }

  /// Returns the target as a formatted string
  String get targetDisplayString {
    if (type == GoalType.sessionsPerWeek) {
      return '$targetMinutes sesiones';
    }
    if (targetMinutes >= 60) {
      final hours = targetMinutes ~/ 60;
      final minutes = targetMinutes % 60;
      if (minutes == 0) {
        return '$hours ${hours == 1 ? 'hora' : 'horas'}';
      }
      return '$hours h $minutes min';
    }
    return '$targetMinutes min';
  }

  PrayerGoal copyWith({
    String? id,
    String? userId,
    GoalType? type,
    int? targetMinutes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PrayerGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        targetMinutes,
        isActive,
        createdAt,
        updatedAt,
      ];

  /// Predefined goal options for quick selection (in minutes)
  static const List<int> suggestedDailyMinutes = [15, 20, 30, 45, 60];

  /// Predefined weekly goal options (in minutes)
  static const List<int> suggestedWeeklyMinutes = [60, 90, 120, 180, 300];
}
