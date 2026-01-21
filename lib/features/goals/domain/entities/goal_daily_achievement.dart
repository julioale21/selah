import 'package:equatable/equatable.dart';

/// Represents whether a daily goal was achieved on a specific date
class GoalDailyAchievement extends Equatable {
  final DateTime date;
  final int minutesPrayed;
  final int targetMinutes;
  final bool achieved;
  final bool hadGoal; // Whether a goal was active on this day

  const GoalDailyAchievement({
    required this.date,
    required this.minutesPrayed,
    required this.targetMinutes,
    required this.achieved,
    this.hadGoal = true,
  });

  double get percentage {
    if (targetMinutes == 0) return 0.0;
    return (minutesPrayed / targetMinutes).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [date, minutesPrayed, targetMinutes, achieved, hadGoal];
}
