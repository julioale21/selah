import 'package:equatable/equatable.dart';

import '../../domain/entities/goal_progress.dart';
import '../../domain/entities/prayer_goal.dart';

enum GoalsStatus { initial, loading, loaded, error }

class GoalsState extends Equatable {
  final GoalsStatus status;
  final List<PrayerGoal> goals;
  final List<PrayerGoal> activeGoals;
  final List<GoalProgress> allProgress;
  final String? errorMessage;
  final bool isSaving;
  final bool isDeleting;

  const GoalsState({
    this.status = GoalsStatus.initial,
    this.goals = const [],
    this.activeGoals = const [],
    this.allProgress = const [],
    this.errorMessage,
    this.isSaving = false,
    this.isDeleting = false,
  });

  GoalsState copyWith({
    GoalsStatus? status,
    List<PrayerGoal>? goals,
    List<PrayerGoal>? activeGoals,
    List<GoalProgress>? allProgress,
    String? errorMessage,
    bool? isSaving,
    bool? isDeleting,
    bool clearActiveGoals = false,
    bool clearAllProgress = false,
  }) {
    return GoalsState(
      status: status ?? this.status,
      goals: goals ?? this.goals,
      activeGoals: clearActiveGoals ? const [] : (activeGoals ?? this.activeGoals),
      allProgress: clearAllProgress ? const [] : (allProgress ?? this.allProgress),
      errorMessage: errorMessage,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  bool get isLoading => status == GoalsStatus.loading;
  bool get hasError => status == GoalsStatus.error;
  bool get isLoaded => status == GoalsStatus.loaded;
  bool get isBusy => isSaving || isDeleting;
  bool get hasActiveGoals => activeGoals.isNotEmpty;
  bool get hasProgress => allProgress.isNotEmpty;

  /// Get the first active goal (for backwards compatibility)
  PrayerGoal? get activeGoal => activeGoals.isNotEmpty ? activeGoals.first : null;

  /// Get daily progress (for backwards compatibility)
  GoalProgress? get dailyProgress => getProgressByType(GoalType.dailyDuration);

  /// Get goal by ID
  PrayerGoal? getGoalById(String id) {
    try {
      return goals.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get active goal by type
  PrayerGoal? getActiveGoalByType(GoalType type) {
    try {
      return activeGoals.firstWhere((g) => g.type == type);
    } catch (_) {
      return null;
    }
  }

  /// Get progress by goal type
  GoalProgress? getProgressByType(GoalType type) {
    try {
      return allProgress.firstWhere((p) => p.goal.type == type);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        status,
        goals,
        activeGoals,
        allProgress,
        errorMessage,
        isSaving,
        isDeleting,
      ];
}
