import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/goal_progress.dart';
import '../entities/prayer_goal.dart';

abstract class GoalsRepository {
  /// Get all goals for a user
  Future<Either<Failure, List<PrayerGoal>>> getGoals(String userId);

  /// Get the active goal for a user (only one should be active at a time)
  Future<Either<Failure, PrayerGoal?>> getActiveGoal(String userId);

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
}
