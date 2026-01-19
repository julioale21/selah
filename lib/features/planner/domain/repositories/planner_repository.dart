import '../entities/daily_plan.dart';
import '../entities/weekly_streak.dart';

abstract class PlannerRepository {
  Future<DailyPlan?> getPlanForDate(String userId, DateTime date);
  Future<List<DailyPlan>> getPlansForDateRange(String userId, DateTime start, DateTime end);
  Future<DailyPlan> savePlan(DailyPlan plan);
  Future<DailyPlan> markPlanCompleted(String planId, String? sessionId);
  Future<void> deletePlan(String planId);
  Future<WeeklyStreak> getStreak(String userId);
}
