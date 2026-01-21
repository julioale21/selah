import 'package:equatable/equatable.dart';

enum GoalType {
  dailyDuration,
  weeklyDuration,
  monthlyDuration,
  annualDuration,
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
      case GoalType.monthlyDuration:
        return 'Meta mensual';
      case GoalType.annualDuration:
        return 'Meta anual';
    }
  }

  /// Returns a short label for the goal type
  String get typeShortLabel {
    switch (type) {
      case GoalType.dailyDuration:
        return 'Hoy';
      case GoalType.weeklyDuration:
        return 'Semana';
      case GoalType.monthlyDuration:
        return 'Mes';
      case GoalType.annualDuration:
        return 'Año';
    }
  }

  /// Returns the target as a formatted string
  String get targetDisplayString {
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

  /// Predefined monthly goal options (in minutes) - 4h, 8h, 15h, 30h, 60h, 120h
  static const List<int> suggestedMonthlyMinutes = [240, 480, 900, 1800, 3600, 7200];

  /// Predefined annual goal options (in minutes) - 50h, 100h, 200h, 365h, 730h, 1460h
  static const List<int> suggestedAnnualMinutes = [3000, 6000, 12000, 21900, 43800, 87600];

  /// Get suggested minutes for a goal type
  static List<int> getSuggestedMinutes(GoalType type) {
    switch (type) {
      case GoalType.dailyDuration:
        return suggestedDailyMinutes;
      case GoalType.weeklyDuration:
        return suggestedWeeklyMinutes;
      case GoalType.monthlyDuration:
        return suggestedMonthlyMinutes;
      case GoalType.annualDuration:
        return suggestedAnnualMinutes;
    }
  }

  /// Get default custom minutes for a goal type
  static int getDefaultCustomMinutes(GoalType type) {
    switch (type) {
      case GoalType.dailyDuration:
        return 30;
      case GoalType.weeklyDuration:
        return 120;
      case GoalType.monthlyDuration:
        return 480;
      case GoalType.annualDuration:
        return 6000;
    }
  }

  /// Get min/max minutes for slider based on goal type
  static (int min, int max) getMinMaxMinutes(GoalType type) {
    switch (type) {
      case GoalType.dailyDuration:
        return (5, 300); // 5 min to 5 hours
      case GoalType.weeklyDuration:
        return (30, 2100); // 30 min to 35 hours (5h/day)
      case GoalType.monthlyDuration:
        return (60, 9000); // 1 hour to 150 hours (5h/day)
      case GoalType.annualDuration:
        return (600, 109800); // 10 hours to 1830 hours (5h/day)
    }
  }
}
