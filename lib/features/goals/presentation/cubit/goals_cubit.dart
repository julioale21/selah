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
    final activeGoalsResult = await repository.getAllActiveGoals(_userId);
    final progressResult = await repository.getAllProgress(_userId);

    goalsResult.fold(
      (failure) => emit(state.copyWith(
        status: GoalsStatus.error,
        errorMessage: failure.message,
      )),
      (goals) {
        activeGoalsResult.fold(
          (failure) => emit(state.copyWith(
            status: GoalsStatus.loaded,
            goals: goals,
            errorMessage: failure.message,
          )),
          (activeGoals) {
            progressResult.fold(
              (failure) => emit(state.copyWith(
                status: GoalsStatus.loaded,
                goals: goals,
                activeGoals: activeGoals,
              )),
              (allProgress) => emit(state.copyWith(
                status: GoalsStatus.loaded,
                goals: goals,
                activeGoals: activeGoals,
                allProgress: allProgress,
              )),
            );
          },
        );
      },
    );
  }

  Future<void> loadProgress() async {
    final result = await repository.getAllProgress(_userId);

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (allProgress) => emit(state.copyWith(allProgress: allProgress)),
    );
  }

  Future<void> setGoal({
    required GoalType type,
    required int targetMinutes,
  }) async {
    emit(state.copyWith(isSaving: true));

    final goal = PrayerGoal(
      id: _uuid.v4(),
      userId: _userId,
      type: type,
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
        // Update the goals list - deactivate other goals of the same type
        final updatedGoals = [
          createdGoal,
          ...state.goals.map((g) {
            if (g.type == type && g.isActive) {
              return g.copyWith(isActive: false);
            }
            return g;
          }),
        ];

        // Update active goals list
        final updatedActiveGoals = [
          createdGoal,
          ...state.activeGoals.where((g) => g.type != type),
        ];
        // Sort by type order: daily, weekly, monthly, annual
        updatedActiveGoals.sort((a, b) => a.type.index.compareTo(b.type.index));

        emit(state.copyWith(
          isSaving: false,
          goals: updatedGoals,
          activeGoals: updatedActiveGoals,
        ));

        // Reload all progress
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

        final updatedActiveGoals = state.activeGoals.map((g) {
          return g.id == updated.id ? updated : g;
        }).toList();

        emit(state.copyWith(
          isSaving: false,
          goals: updatedGoals,
          activeGoals: updatedActiveGoals,
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

        final updatedActiveGoals = state.activeGoals.where((g) => g.id != goalId).toList();
        final updatedProgress = state.allProgress.where((p) => p.goal.id != goalId).toList();

        emit(state.copyWith(
          isSaving: false,
          goals: updatedGoals,
          activeGoals: updatedActiveGoals,
          allProgress: updatedProgress,
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
        final updatedActiveGoals = state.activeGoals.where((g) => g.id != goalId).toList();
        final updatedProgress = state.allProgress.where((p) => p.goal.id != goalId).toList();

        emit(state.copyWith(
          isDeleting: false,
          goals: updatedGoals,
          activeGoals: updatedActiveGoals,
          allProgress: updatedProgress,
        ));
      },
    );
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
