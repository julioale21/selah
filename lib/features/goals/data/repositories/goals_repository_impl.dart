import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/goal_progress.dart';
import '../../domain/entities/prayer_goal.dart';
import '../../domain/repositories/goals_repository.dart';
import '../datasources/goals_local_datasource.dart';
import '../models/prayer_goal_model.dart';

class GoalsRepositoryImpl implements GoalsRepository {
  final GoalsLocalDataSource localDataSource;
  static const _uuid = Uuid();

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
  Future<Either<Failure, List<PrayerGoal>>> getAllActiveGoals(String userId) async {
    try {
      final goals = await localDataSource.getAllActiveGoals(userId);
      return Right(goals);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PrayerGoal?>> getActiveGoalByType(String userId, GoalType type) async {
    try {
      final goal = await localDataSource.getActiveGoalByType(userId, type);
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
      final activeGoal = await localDataSource.getActiveGoalByType(userId, GoalType.dailyDuration);

      if (activeGoal == null) {
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
  Future<Either<Failure, GoalProgress?>> getWeeklyProgress(String userId) async {
    try {
      final activeGoal = await localDataSource.getActiveGoalByType(userId, GoalType.weeklyDuration);

      if (activeGoal == null) {
        return const Right(null);
      }

      // Get the start and end of the current week (Monday to Sunday)
      final now = DateTime.now();
      final weekday = now.weekday;
      final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      final weekMinutes = await localDataSource.getPrayerMinutesForDateRange(
        userId,
        startOfWeek,
        endOfWeek,
      );

      return Right(GoalProgress(
        goal: activeGoal,
        currentMinutes: weekMinutes,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, GoalProgress?>> getMonthlyProgress(String userId) async {
    try {
      final activeGoal = await localDataSource.getActiveGoalByType(userId, GoalType.monthlyDuration);

      if (activeGoal == null) {
        return const Right(null);
      }

      // Get the start and end of the current month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0); // Last day of month

      final monthMinutes = await localDataSource.getPrayerMinutesForDateRange(
        userId,
        startOfMonth,
        endOfMonth,
      );

      return Right(GoalProgress(
        goal: activeGoal,
        currentMinutes: monthMinutes,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, GoalProgress?>> getAnnualProgress(String userId) async {
    try {
      final activeGoal = await localDataSource.getActiveGoalByType(userId, GoalType.annualDuration);

      if (activeGoal == null) {
        return const Right(null);
      }

      // Get the start and end of the current year
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);
      final endOfYear = DateTime(now.year, 12, 31);

      final yearMinutes = await localDataSource.getPrayerMinutesForDateRange(
        userId,
        startOfYear,
        endOfYear,
      );

      return Right(GoalProgress(
        goal: activeGoal,
        currentMinutes: yearMinutes,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<GoalProgress>>> getAllProgress(String userId) async {
    try {
      final activeGoals = await localDataSource.getAllActiveGoals(userId);
      final progressList = <GoalProgress>[];

      for (final goal in activeGoals) {
        final currentMinutes = await _getMinutesForGoalType(userId, goal.type);
        progressList.add(GoalProgress(
          goal: goal,
          currentMinutes: currentMinutes,
        ));
      }

      // Sort by goal type order: daily, weekly, monthly, annual
      progressList.sort((a, b) => a.goal.type.index.compareTo(b.goal.type.index));

      return Right(progressList);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  Future<int> _getMinutesForGoalType(String userId, GoalType type) async {
    final now = DateTime.now();

    switch (type) {
      case GoalType.dailyDuration:
        return await localDataSource.getPrayerMinutesForDate(userId, now);

      case GoalType.weeklyDuration:
        final weekday = now.weekday;
        final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return await localDataSource.getPrayerMinutesForDateRange(userId, startOfWeek, endOfWeek);

      case GoalType.monthlyDuration:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        return await localDataSource.getPrayerMinutesForDateRange(userId, startOfMonth, endOfMonth);

      case GoalType.annualDuration:
        final startOfYear = DateTime(now.year, 1, 1);
        final endOfYear = DateTime(now.year, 12, 31);
        return await localDataSource.getPrayerMinutesForDateRange(userId, startOfYear, endOfYear);
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

  @override
  Future<Either<Failure, bool>> isCelebrationShown(
    String userId,
    String goalId,
    GoalType type,
  ) async {
    try {
      final periodKey = GoalsLocalDataSourceImpl.calculatePeriodKey(type, DateTime.now());
      final isShown = await localDataSource.isCelebrationShown(
        userId,
        goalId,
        type,
        periodKey,
      );
      return Right(isShown);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> markCelebrationShown(
    String userId,
    String goalId,
    GoalType type,
  ) async {
    try {
      final periodKey = GoalsLocalDataSourceImpl.calculatePeriodKey(type, DateTime.now());
      await localDataSource.markCelebrationShown(
        _uuid.v4(),
        userId,
        goalId,
        type,
        periodKey,
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
