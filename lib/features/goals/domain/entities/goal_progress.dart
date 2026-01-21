import 'package:equatable/equatable.dart';

import 'prayer_goal.dart';

class GoalProgress extends Equatable {
  final PrayerGoal goal;
  final int currentMinutes;

  const GoalProgress({
    required this.goal,
    required this.currentMinutes,
  });

  /// Percentage of goal completion (0.0 to 1.0+)
  double get percentage {
    if (goal.targetMinutes == 0) return 0.0;
    return currentMinutes / goal.targetMinutes;
  }

  /// Percentage clamped to 0.0-1.0 for progress indicators
  double get clampedPercentage => percentage.clamp(0.0, 1.0);

  /// Percentage as integer (0-100+)
  int get percentageInt => (percentage * 100).round();

  /// Whether the goal has been completed
  bool get isCompleted => currentMinutes >= goal.targetMinutes;

  /// Remaining minutes to reach the goal
  int get remainingMinutes {
    final remaining = goal.targetMinutes - currentMinutes;
    return remaining > 0 ? remaining : 0;
  }

  /// Returns a motivational message based on progress
  String get motivationalMessage {
    if (isCompleted) {
      return 'Meta cumplida';
    }
    if (percentage >= 0.75) {
      return 'Ya casi llegas';
    }
    if (percentage >= 0.5) {
      return 'Vas por buen camino';
    }
    if (percentage >= 0.25) {
      return 'Sigue adelante';
    }
    if (currentMinutes > 0) {
      return 'Buen comienzo';
    }
    return 'Comienza tu tiempo de oración';
  }

  /// Formatted current progress string (e.g., "15/30 min" or "2h 30m / 10h")
  String get progressString {
    // For monthly and annual goals, show in hours format
    if (goal.type == GoalType.monthlyDuration ||
        goal.type == GoalType.annualDuration) {
      return '${_formatAsHours(currentMinutes)} / ${_formatAsHours(goal.targetMinutes)}';
    }

    // For daily and weekly, show in minutes or hours if large
    if (currentMinutes >= 60 || goal.targetMinutes >= 60) {
      return '${_formatMinutes(currentMinutes)} / ${_formatMinutes(goal.targetMinutes)}';
    }

    return '$currentMinutes/${goal.targetMinutes} min';
  }

  /// Format minutes as hours (e.g., 150 -> "2h 30m", 120 -> "2h")
  String _formatAsHours(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) {
      return '${mins}m';
    }
    if (mins == 0) {
      return '${hours}h';
    }
    return '${hours}h ${mins}m';
  }

  /// Format minutes smartly (e.g., 90 -> "1h 30m", 45 -> "45 min")
  String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '${hours}h';
      }
      return '${hours}h ${mins}m';
    }
    return '$minutes min';
  }

  @override
  List<Object?> get props => [goal, currentMinutes];
}
