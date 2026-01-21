import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/user_service.dart';
import '../../../goals/domain/entities/goal_daily_achievement.dart';
import '../../../goals/domain/repositories/goals_repository.dart';
import '../../domain/repositories/stats_repository.dart';
import 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final StatsRepository repository;
  final GoalsRepository goalsRepository;
  final UserService userService;

  StatsCubit({
    required this.repository,
    required this.goalsRepository,
    required this.userService,
  }) : super(const StatsState());

  String get _userId => userService.currentUserId;

  Future<void> loadStats() async {
    emit(state.copyWith(status: StatsStatus.loading));

    try {
      final stats = await repository.getStats(_userId, state.selectedPeriod);
      final streak = await repository.getStreakInfo(_userId);
      final weekly = await repository.getWeeklyActivity(_userId);

      // Load goal achievements for the last 30 days
      List<GoalDailyAchievement> goalAchievements = [];
      final achievementsResult = await goalsRepository.getDailyGoalAchievements(_userId, 30);
      achievementsResult.fold(
        (failure) => {}, // Ignore failures, just show empty
        (achievements) => goalAchievements = achievements,
      );

      emit(state.copyWith(
        status: StatsStatus.loaded,
        stats: stats,
        streakInfo: streak,
        weeklyActivity: weekly,
        goalAchievements: goalAchievements,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StatsStatus.error,
        errorMessage: 'Error al cargar estadísticas: $e',
      ));
    }
  }

  Future<void> changePeriod(StatsPeriod period) async {
    emit(state.copyWith(selectedPeriod: period));
    await loadStats();
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
