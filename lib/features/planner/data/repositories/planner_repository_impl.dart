import '../../domain/entities/daily_plan.dart';
import '../../domain/entities/weekly_streak.dart';
import '../../domain/repositories/planner_repository.dart';
import '../datasources/planner_local_datasource.dart';
import '../models/daily_plan_model.dart';

class PlannerRepositoryImpl implements PlannerRepository {
  final PlannerLocalDataSource localDataSource;

  PlannerRepositoryImpl({required this.localDataSource});

  @override
  Future<DailyPlan?> getPlanForDate(String userId, DateTime date) {
    return localDataSource.getPlanForDate(userId, date);
  }

  @override
  Future<List<DailyPlan>> getPlansForDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    return localDataSource.getPlansForDateRange(userId, start, end);
  }

  @override
  Future<DailyPlan> savePlan(DailyPlan plan) {
    final model = DailyPlanModel.fromEntity(plan);
    return localDataSource.savePlan(model);
  }

  @override
  Future<DailyPlan> markPlanCompleted(String planId, String? sessionId) {
    return localDataSource.markPlanCompleted(planId, sessionId);
  }

  @override
  Future<void> deletePlan(String planId) {
    return localDataSource.deletePlan(planId);
  }

  @override
  Future<WeeklyStreak> getStreak(String userId) async {
    final currentStreak = await localDataSource.getStreakDays(userId);
    final longestStreak = await localDataSource.getLongestStreak(userId);
    final lastPrayerDate = await localDataSource.getLastPrayerDate(userId);

    // Get week days for current week
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = await localDataSource.getWeekDaysCompleted(userId, weekStart);

    return WeeklyStreak(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastPrayerDate: lastPrayerDate,
      weekDays: weekDays,
    );
  }
}
