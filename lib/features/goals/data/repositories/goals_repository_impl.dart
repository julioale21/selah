import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/goal_progress.dart';
import '../../domain/entities/prayer_goal.dart';
import '../../domain/repositories/goals_repository.dart';
import '../datasources/goals_local_datasource.dart';
import '../models/prayer_goal_model.dart';

class GoalsRepositoryImpl implements GoalsRepository {
  final GoalsLocalDataSource localDataSource;

  GoalsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<PrayerGoal>>> getGoals(String userId) async {
    try {
      final goals = await localDataSource.getGoals(userId);
      return Right(goals);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PrayerGoal?>> getActiveGoal(String userId) async {
    try {
      final goal = await localDataSource.getActiveGoal(userId);
      return Right(goal);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PrayerGoal>> getGoalById(String id) async {
    try {
      final goal = await localDataSource.getGoalById(id);
      return Right(goal);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PrayerGoal>> createGoal(PrayerGoal goal) async {
    try {
      final model = PrayerGoalModel.fromEntity(goal);
      final created = await localDataSource.createGoal(model);
      return Right(created);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PrayerGoal>> updateGoal(PrayerGoal goal) async {
    try {
      final model = PrayerGoalModel.fromEntity(goal);
      final updated = await localDataSource.updateGoal(model);
      return Right(updated);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGoal(String id) async {
    try {
      await localDataSource.deleteGoal(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, GoalProgress?>> getDailyProgress(String userId) async {
    try {
      final activeGoal = await localDataSource.getActiveGoal(userId);

      if (activeGoal == null || activeGoal.type != GoalType.dailyDuration) {
        return const Right(null);
      }

      final todayMinutes = await localDataSource.getPrayerMinutesForDate(
        userId,
        DateTime.now(),
      );

      return Right(GoalProgress(
        goal: activeGoal,
        currentMinutes: todayMinutes,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, GoalProgress?>> getWeeklyProgress(
      String userId) async {
    try {
      final activeGoal = await localDataSource.getActiveGoal(userId);

      if (activeGoal == null) {
        return const Right(null);
      }

      // Get the start and end of the current week (Monday to Sunday)
      final now = DateTime.now();
      final weekday = now.weekday;
      final startOfWeek = now.subtract(Duration(days: weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      int currentValue;

      if (activeGoal.type == GoalType.sessionsPerWeek) {
        currentValue = await localDataSource.getSessionCountForDateRange(
          userId,
          startOfWeek,
          endOfWeek,
        );
      } else {
        currentValue = await localDataSource.getPrayerMinutesForDateRange(
          userId,
          startOfWeek,
          endOfWeek,
        );
      }

      return Right(GoalProgress(
        goal: activeGoal,
        currentMinutes: currentValue,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, int>> getPrayerMinutesForDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final minutes = await localDataSource.getPrayerMinutesForDate(
        userId,
        date,
      );
      return Right(minutes);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, int>> getPrayerMinutesForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final minutes = await localDataSource.getPrayerMinutesForDateRange(
        userId,
        startDate,
        endDate,
      );
      return Right(minutes);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, int>> getSessionCountForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final count = await localDataSource.getSessionCountForDateRange(
        userId,
        startDate,
        endDate,
      );
      return Right(count);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
