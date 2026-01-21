import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/goal_daily_achievement.dart';
import '../entities/goal_progress.dart';
import '../entities/prayer_goal.dart';

abstract class GoalsRepository {
  /// Get all goals for a user
  Future<Either<Failure, List<PrayerGoal>>> getGoals(String userId);

  /// Get the active goal for a user (first found)
  Future<Either<Failure, PrayerGoal?>> getActiveGoal(String userId);

  /// Get all active goals for a user (one per type)
  Future<Either<Failure, List<PrayerGoal>>> getAllActiveGoals(String userId);

  /// Get active goal by type
  Future<Either<Failure, PrayerGoal?>> getActiveGoalByType(String userId, GoalType type);

  /// Get a single goal by ID
  Future<Either<Failure, PrayerGoal>> getGoalById(String id);

  /// Create a new goal (deactivates previous active goals of the same type)
  Future<Either<Failure, PrayerGoal>> createGoal(PrayerGoal goal);

  /// Update an existing goal
  Future<Either<Failure, PrayerGoal>> updateGoal(PrayerGoal goal);

  /// Delete a goal
  Future<Either<Failure, void>> deleteGoal(String id);

  /// Get today's progress for the active daily goal
  Future<Either<Failure, GoalProgress?>> getDailyProgress(String userId);

  /// Get this week's progress for the active weekly goal
  Future<Either<Failure, GoalProgress?>> getWeeklyProgress(String userId);

  /// Get this month's progress for the active monthly goal
  Future<Either<Failure, GoalProgress?>> getMonthlyProgress(String userId);

  /// Get this year's progress for the active annual goal
  Future<Either<Failure, GoalProgress?>> getAnnualProgress(String userId);

  /// Get progress for all active goals
  Future<Either<Failure, List<GoalProgress>>> getAllProgress(String userId);

  /// Get total prayer minutes for a specific date
  Future<Either<Failure, int>> getPrayerMinutesForDate(
    String userId,
    DateTime date,
  );

  /// Get total prayer minutes for date range (week)
  Future<Either<Failure, int>> getPrayerMinutesForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get session count for date range
  Future<Either<Failure, int>> getSessionCountForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Check if celebration was shown for a goal in the current period
  Future<Either<Failure, bool>> isCelebrationShown(
    String userId,
    String goalId,
    GoalType type,
  );

  /// Mark celebration as shown for a goal in the current period
  Future<Either<Failure, void>> markCelebrationShown(
    String userId,
    String goalId,
    GoalType type,
  );

  /// Get daily goal achievements for the last N days
  Future<Either<Failure, List<GoalDailyAchievement>>> getDailyGoalAchievements(
    String userId,
    int daysBack,
  );
}
