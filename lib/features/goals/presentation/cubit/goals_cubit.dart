import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/user_service.dart';
import '../../domain/entities/prayer_goal.dart';
import '../../domain/repositories/goals_repository.dart';
import 'goals_state.dart';

class GoalsCubit extends Cubit<GoalsState> {
  final GoalsRepository repository;
  final UserService userService;
  static const _uuid = Uuid();

  GoalsCubit({
    required this.repository,
    required this.userService,
  }) : super(const GoalsState());

  String get _userId => userService.currentUserId;

  Future<void> loadGoals() async {
    emit(state.copyWith(status: GoalsStatus.loading));

    final goalsResult = await repository.getGoals(_userId);
    final activeResult = await repository.getActiveGoal(_userId);
    final progressResult = await repository.getDailyProgress(_userId);

    goalsResult.fold(
      (failure) => emit(state.copyWith(
        status: GoalsStatus.error,
        errorMessage: failure.message,
      )),
      (goals) {
        activeResult.fold(
          (failure) => emit(state.copyWith(
            status: GoalsStatus.loaded,
            goals: goals,
            errorMessage: failure.message,
          )),
          (activeGoal) {
            progressResult.fold(
              (failure) => emit(state.copyWith(
                status: GoalsStatus.loaded,
                goals: goals,
                activeGoal: activeGoal,
              )),
              (progress) => emit(state.copyWith(
                status: GoalsStatus.loaded,
                goals: goals,
                activeGoal: activeGoal,
                dailyProgress: progress,
              )),
            );
          },
        );
      },
    );
  }

  Future<void> loadProgress() async {
    final result = await repository.getDailyProgress(_userId);

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (progress) => emit(state.copyWith(dailyProgress: progress)),
    );
  }

  Future<void> setDailyGoal(int targetMinutes) async {
    emit(state.copyWith(isSaving: true));

    final goal = PrayerGoal(
      id: _uuid.v4(),
      userId: _userId,
      type: GoalType.dailyDuration,
      targetMinutes: targetMinutes,
      isActive: true,
      createdAt: DateTime.now(),
    );

    final result = await repository.createGoal(goal);

    result.fold(
      (failure) => emit(state.copyWith(
        isSaving: false,
        errorMessage: failure.message,
      )),
      (createdGoal) async {
        // Update the goals list
        final updatedGoals = [
          createdGoal,
          ...state.goals.map((g) {
            if (g.type == GoalType.dailyDuration && g.isActive) {
              return g.copyWith(isActive: false);
            }
            return g;
          }),
        ];

        emit(state.copyWith(
          isSaving: false,
          goals: updatedGoals,
          activeGoal: createdGoal,
        ));

        // Reload progress with the new goal
        await loadProgress();
      },
    );
  }

  Future<void> updateGoal(PrayerGoal goal) async {
    emit(state.copyWith(isSaving: true));

    final updatedGoal = goal.copyWith(
      updatedAt: DateTime.now(),
    );

    final result = await repository.updateGoal(updatedGoal);

    result.fold(
      (failure) => emit(state.copyWith(
        isSaving: false,
        errorMessage: failure.message,
      )),
      (updated) {
        final updatedGoals = state.goals.map((g) {
          return g.id == updated.id ? updated : g;
        }).toList();

        emit(state.copyWith(
          isSaving: false,
          goals: updatedGoals,
          activeGoal:
              state.activeGoal?.id == updated.id ? updated : state.activeGoal,
        ));
      },
    );
  }

  Future<void> deactivateGoal(String goalId) async {
    final existingGoal = state.getGoalById(goalId);
    if (existingGoal == null) return;

    emit(state.copyWith(isSaving: true));

    final deactivatedGoal = existingGoal.copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );

    final result = await repository.updateGoal(deactivatedGoal);

    result.fold(
      (failure) => emit(state.copyWith(
        isSaving: false,
        errorMessage: failure.message,
      )),
      (updated) {
        final updatedGoals = state.goals.map((g) {
          return g.id == updated.id ? updated : g;
        }).toList();

        emit(state.copyWith(
          isSaving: false,
          goals: updatedGoals,
          clearActiveGoal: state.activeGoal?.id == updated.id,
          clearDailyProgress: state.activeGoal?.id == updated.id,
        ));
      },
    );
  }

  Future<void> deleteGoal(String goalId) async {
    emit(state.copyWith(isDeleting: true));

    final result = await repository.deleteGoal(goalId);

    result.fold(
      (failure) => emit(state.copyWith(
        isDeleting: false,
        errorMessage: failure.message,
      )),
      (_) {
        final updatedGoals = state.goals.where((g) => g.id != goalId).toList();
        final wasActive = state.activeGoal?.id == goalId;

        emit(state.copyWith(
          isDeleting: false,
          goals: updatedGoals,
          clearActiveGoal: wasActive,
          clearDailyProgress: wasActive,
        ));
      },
    );
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
