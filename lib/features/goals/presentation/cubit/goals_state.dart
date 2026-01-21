import 'package:equatable/equatable.dart';

import '../../domain/entities/goal_progress.dart';
import '../../domain/entities/prayer_goal.dart';

enum GoalsStatus { initial, loading, loaded, error }

class GoalsState extends Equatable {
  final GoalsStatus status;
  final List<PrayerGoal> goals;
  final PrayerGoal? activeGoal;
  final GoalProgress? dailyProgress;
  final String? errorMessage;
  final bool isSaving;
  final bool isDeleting;

  const GoalsState({
    this.status = GoalsStatus.initial,
    this.goals = const [],
    this.activeGoal,
    this.dailyProgress,
    this.errorMessage,
    this.isSaving = false,
    this.isDeleting = false,
  });

  GoalsState copyWith({
    GoalsStatus? status,
    List<PrayerGoal>? goals,
    PrayerGoal? activeGoal,
    GoalProgress? dailyProgress,
    String? errorMessage,
    bool? isSaving,
    bool? isDeleting,
    bool clearActiveGoal = false,
    bool clearDailyProgress = false,
  }) {
    return GoalsState(
      status: status ?? this.status,
      goals: goals ?? this.goals,
      activeGoal: clearActiveGoal ? null : (activeGoal ?? this.activeGoal),
      dailyProgress:
          clearDailyProgress ? null : (dailyProgress ?? this.dailyProgress),
      errorMessage: errorMessage,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  bool get isLoading => status == GoalsStatus.loading;
  bool get hasError => status == GoalsStatus.error;
  bool get isLoaded => status == GoalsStatus.loaded;
  bool get isBusy => isSaving || isDeleting;
  bool get hasActiveGoal => activeGoal != null;
  bool get hasProgress => dailyProgress != null;

  /// Get goal by ID
  PrayerGoal? getGoalById(String id) {
    try {
      return goals.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        status,
        goals,
        activeGoal,
        dailyProgress,
        errorMessage,
        isSaving,
        isDeleting,
      ];
}
