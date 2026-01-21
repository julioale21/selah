import '../../../../core/database/database_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/prayer_goal.dart';
import '../models/prayer_goal_model.dart';

abstract class GoalsLocalDataSource {
  Future<List<PrayerGoalModel>> getGoals(String userId);
  Future<PrayerGoalModel?> getActiveGoal(String userId);
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
}

class GoalsLocalDataSourceImpl implements GoalsLocalDataSource {
  final DatabaseHelper databaseHelper;

  GoalsLocalDataSourceImpl({required this.databaseHelper});

  static const String _tableName = 'prayer_goals';
  static const String _sessionsTable = 'prayer_sessions';

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
      case GoalType.sessionsPerWeek:
        return 'sessions_per_week';
    }
  }
}
