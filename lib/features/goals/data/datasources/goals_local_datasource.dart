import '../../../../core/database/database_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/goal_daily_achievement.dart';
import '../../domain/entities/prayer_goal.dart';
import '../models/prayer_goal_model.dart';

abstract class GoalsLocalDataSource {
  Future<List<PrayerGoalModel>> getGoals(String userId);
  Future<PrayerGoalModel?> getActiveGoal(String userId);
  Future<List<PrayerGoalModel>> getAllActiveGoals(String userId);
  Future<PrayerGoalModel?> getActiveGoalByType(String userId, GoalType type);
  Future<PrayerGoalModel> getGoalById(String id);
  Future<PrayerGoalModel> createGoal(PrayerGoalModel goal);
  Future<PrayerGoalModel> updateGoal(PrayerGoalModel goal);
  Future<void> deleteGoal(String id);
  Future<int> getPrayerMinutesForDate(String userId, DateTime date);
  Future<int> getPrayerMinutesForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<int> getSessionCountForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<bool> isCelebrationShown(String userId, String goalId, GoalType type, String periodKey);
  Future<void> markCelebrationShown(String id, String userId, String goalId, GoalType type, String periodKey);
  Future<List<GoalDailyAchievement>> getDailyGoalAchievements(
    String userId,
    int targetMinutes,
    DateTime goalCreatedAt,
    int daysBack,
  );
}

class GoalsLocalDataSourceImpl implements GoalsLocalDataSource {
  final DatabaseHelper databaseHelper;

  GoalsLocalDataSourceImpl({required this.databaseHelper});

  static const String _tableName = 'prayer_goals';
  static const String _sessionsTable = 'prayer_sessions';
  static const String _celebrationsTable = 'goal_celebrations';

  @override
  Future<List<PrayerGoalModel>> getGoals(String userId) async {
    try {
      final results = await databaseHelper.query(
        _tableName,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
      return results.map((map) => PrayerGoalModel.fromMap(map)).toList();
    } catch (e) {
      throw CacheException(message: 'Error al obtener metas: $e');
    }
  }

  @override
  Future<PrayerGoalModel?> getActiveGoal(String userId) async {
    try {
      final results = await databaseHelper.query(
        _tableName,
        where: 'user_id = ? AND is_active = ?',
        whereArgs: [userId, 1],
        limit: 1,
      );

      if (results.isEmpty) {
        return null;
      }

      return PrayerGoalModel.fromMap(results.first);
    } catch (e) {
      throw CacheException(message: 'Error al obtener meta activa: $e');
    }
  }

  @override
  Future<List<PrayerGoalModel>> getAllActiveGoals(String userId) async {
    try {
      final results = await databaseHelper.query(
        _tableName,
        where: 'user_id = ? AND is_active = ?',
        whereArgs: [userId, 1],
        orderBy: 'created_at DESC',
      );
      return results.map((map) => PrayerGoalModel.fromMap(map)).toList();
    } catch (e) {
      throw CacheException(message: 'Error al obtener metas activas: $e');
    }
  }

  @override
  Future<PrayerGoalModel?> getActiveGoalByType(String userId, GoalType type) async {
    try {
      final results = await databaseHelper.query(
        _tableName,
        where: 'user_id = ? AND is_active = ? AND goal_type = ?',
        whereArgs: [userId, 1, _goalTypeToString(type)],
        limit: 1,
      );

      if (results.isEmpty) {
        return null;
      }

      return PrayerGoalModel.fromMap(results.first);
    } catch (e) {
      throw CacheException(message: 'Error al obtener meta por tipo: $e');
    }
  }

  @override
  Future<PrayerGoalModel> getGoalById(String id) async {
    try {
      final results = await databaseHelper.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isEmpty) {
        throw CacheException(message: 'Meta no encontrada');
      }

      return PrayerGoalModel.fromMap(results.first);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Error al obtener meta: $e');
    }
  }

  @override
  Future<PrayerGoalModel> createGoal(PrayerGoalModel goal) async {
    try {
      final db = await databaseHelper.database;

      await db.transaction((txn) async {
        // Deactivate all other goals of the same type for this user
        await txn.update(
          _tableName,
          {
            'is_active': 0,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'user_id = ? AND goal_type = ? AND is_active = ?',
          whereArgs: [
            goal.userId,
            _goalTypeToString(goal.type),
            1,
          ],
        );

        // Insert the new goal
        await txn.insert(_tableName, goal.toMap());
      });

      return goal;
    } catch (e) {
      throw CacheException(message: 'Error al crear meta: $e');
    }
  }

  @override
  Future<PrayerGoalModel> updateGoal(PrayerGoalModel goal) async {
    try {
      final updatedGoal = goal.copyWith(
        updatedAt: DateTime.now(),
      );

      await databaseHelper.update(
        _tableName,
        updatedGoal.toMap(),
        where: 'id = ?',
        whereArgs: [goal.id],
      );

      return updatedGoal;
    } catch (e) {
      throw CacheException(message: 'Error al actualizar meta: $e');
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    try {
      await databaseHelper.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException(message: 'Error al eliminar meta: $e');
    }
  }

  @override
  Future<int> getPrayerMinutesForDate(String userId, DateTime date) async {
    try {
      final dateStr = _formatDate(date);
      final results = await databaseHelper.rawQuery(
        '''
        SELECT COALESCE(SUM(duration_seconds), 0) as total_seconds
        FROM $_sessionsTable
        WHERE user_id = ? AND date(started_at) = ?
        ''',
        [userId, dateStr],
      );

      if (results.isEmpty) return 0;

      final totalSeconds = results.first['total_seconds'] as int? ?? 0;
      return (totalSeconds / 60).floor();
    } catch (e) {
      throw CacheException(message: 'Error al obtener minutos de oración: $e');
    }
  }

  @override
  Future<int> getPrayerMinutesForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startStr = _formatDate(startDate);
      final endStr = _formatDate(endDate);

      final results = await databaseHelper.rawQuery(
        '''
        SELECT COALESCE(SUM(duration_seconds), 0) as total_seconds
        FROM $_sessionsTable
        WHERE user_id = ? AND date(started_at) >= ? AND date(started_at) <= ?
        ''',
        [userId, startStr, endStr],
      );

      if (results.isEmpty) return 0;

      final totalSeconds = results.first['total_seconds'] as int? ?? 0;
      return (totalSeconds / 60).floor();
    } catch (e) {
      throw CacheException(
          message: 'Error al obtener minutos de oración del rango: $e');
    }
  }

  @override
  Future<int> getSessionCountForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startStr = _formatDate(startDate);
      final endStr = _formatDate(endDate);

      final results = await databaseHelper.rawQuery(
        '''
        SELECT COUNT(*) as count
        FROM $_sessionsTable
        WHERE user_id = ? AND date(started_at) >= ? AND date(started_at) <= ?
        ''',
        [userId, startStr, endStr],
      );

      if (results.isEmpty) return 0;

      return results.first['count'] as int? ?? 0;
    } catch (e) {
      throw CacheException(message: 'Error al obtener conteo de sesiones: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _goalTypeToString(GoalType type) {
    switch (type) {
      case GoalType.dailyDuration:
        return 'daily_duration';
      case GoalType.weeklyDuration:
        return 'weekly_duration';
      case GoalType.monthlyDuration:
        return 'monthly_duration';
      case GoalType.annualDuration:
        return 'annual_duration';
    }
  }

  @override
  Future<bool> isCelebrationShown(
    String userId,
    String goalId,
    GoalType type,
    String periodKey,
  ) async {
    try {
      final results = await databaseHelper.query(
        _celebrationsTable,
        where: 'user_id = ? AND goal_id = ? AND goal_type = ? AND period_key = ?',
        whereArgs: [userId, goalId, _goalTypeToString(type), periodKey],
        limit: 1,
      );
      return results.isNotEmpty;
    } catch (e) {
      throw CacheException(message: 'Error al verificar celebración: $e');
    }
  }

  @override
  Future<void> markCelebrationShown(
    String id,
    String userId,
    String goalId,
    GoalType type,
    String periodKey,
  ) async {
    try {
      await databaseHelper.insert(_celebrationsTable, {
        'id': id,
        'user_id': userId,
        'goal_id': goalId,
        'goal_type': _goalTypeToString(type),
        'period_key': periodKey,
        'shown_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw CacheException(message: 'Error al marcar celebración: $e');
    }
  }

  /// Helper to calculate period key for a goal type
  static String calculatePeriodKey(GoalType type, DateTime date) {
    switch (type) {
      case GoalType.dailyDuration:
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case GoalType.weeklyDuration:
        // ISO week number
        final weekNumber = _getISOWeekNumber(date);
        return '${date.year}-W${weekNumber.toString().padLeft(2, '0')}';
      case GoalType.monthlyDuration:
        return '${date.year}-${date.month.toString().padLeft(2, '0')}';
      case GoalType.annualDuration:
        return '${date.year}';
    }
  }

  static int _getISOWeekNumber(DateTime date) {
    // ISO week: week 1 is the week containing Jan 4
    final jan4 = DateTime(date.year, 1, 4);
    final daysSinceJan4 = date.difference(jan4).inDays;
    final weekday = date.weekday; // 1 = Monday, 7 = Sunday
    return ((daysSinceJan4 + jan4.weekday - weekday) / 7).floor() + 1;
  }

  @override
  Future<List<GoalDailyAchievement>> getDailyGoalAchievements(
    String userId,
    int targetMinutes,
    DateTime goalCreatedAt,
    int daysBack,
  ) async {
    try {
      final now = DateTime.now();
      final achievements = <GoalDailyAchievement>[];

      // Normalize goalCreatedAt to start of day
      final goalStartDate = DateTime(goalCreatedAt.year, goalCreatedAt.month, goalCreatedAt.day);

      for (int i = daysBack - 1; i >= 0; i--) {
        final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        final dateStr = _formatDate(date);

        // Check if goal was active on this day
        final hadGoal = !date.isBefore(goalStartDate);

        final results = await databaseHelper.rawQuery(
          '''
          SELECT COALESCE(SUM(duration_seconds), 0) as total_seconds
          FROM $_sessionsTable
          WHERE user_id = ? AND date(started_at) = ?
          ''',
          [userId, dateStr],
        );

        final totalSeconds = results.isNotEmpty
            ? (results.first['total_seconds'] as int? ?? 0)
            : 0;
        final minutesPrayed = (totalSeconds / 60).floor();

        achievements.add(GoalDailyAchievement(
          date: date,
          minutesPrayed: minutesPrayed,
          targetMinutes: hadGoal ? targetMinutes : 0,
          achieved: hadGoal && minutesPrayed >= targetMinutes,
          hadGoal: hadGoal,
        ));
      }

      return achievements;
    } catch (e) {
      throw CacheException(message: 'Error al obtener logros diarios: $e');
    }
  }
}
