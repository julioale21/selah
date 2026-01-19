import '../../../../core/database/database_helper.dart';
import '../models/daily_plan_model.dart';

abstract class PlannerLocalDataSource {
  Future<DailyPlanModel?> getPlanForDate(String userId, DateTime date);
  Future<List<DailyPlanModel>> getPlansForDateRange(String userId, DateTime start, DateTime end);
  Future<DailyPlanModel> savePlan(DailyPlanModel plan);
  Future<DailyPlanModel> markPlanCompleted(String planId, String? sessionId);
  Future<void> deletePlan(String planId);
  Future<int> getStreakDays(String userId);
  Future<int> getLongestStreak(String userId);
  Future<DateTime?> getLastPrayerDate(String userId);
  Future<Map<int, bool>> getWeekDaysCompleted(String userId, DateTime weekStart);
}

class PlannerLocalDataSourceImpl implements PlannerLocalDataSource {
  final DatabaseHelper databaseHelper;

  PlannerLocalDataSourceImpl({required this.databaseHelper});

  String _formatDate(DateTime date) => date.toIso8601String().split('T')[0];

  @override
  Future<DailyPlanModel?> getPlanForDate(String userId, DateTime date) async {
    final dateStr = _formatDate(date);
    final results = await databaseHelper.query(
      'daily_plans',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, dateStr],
    );

    if (results.isEmpty) return null;
    return DailyPlanModel.fromMap(results.first);
  }

  @override
  Future<List<DailyPlanModel>> getPlansForDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final startStr = _formatDate(start);
    final endStr = _formatDate(end);

    final results = await databaseHelper.query(
      'daily_plans',
      where: 'user_id = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, startStr, endStr],
      orderBy: 'date ASC',
    );

    return results.map((map) => DailyPlanModel.fromMap(map)).toList();
  }

  @override
  Future<DailyPlanModel> savePlan(DailyPlanModel plan) async {
    await databaseHelper.insert('daily_plans', plan.toMap());
    return plan;
  }

  @override
  Future<DailyPlanModel> markPlanCompleted(String planId, String? sessionId) async {
    final now = DateTime.now().toIso8601String();
    await databaseHelper.update(
      'daily_plans',
      {
        'is_completed': 1,
        'completed_at': now,
        'session_id': sessionId,
      },
      where: 'id = ?',
      whereArgs: [planId],
    );

    final results = await databaseHelper.query(
      'daily_plans',
      where: 'id = ?',
      whereArgs: [planId],
    );

    return DailyPlanModel.fromMap(results.first);
  }

  @override
  Future<void> deletePlan(String planId) async {
    await databaseHelper.delete(
      'daily_plans',
      where: 'id = ?',
      whereArgs: [planId],
    );
  }

  @override
  Future<int> getStreakDays(String userId) async {
    // Calculate current streak by counting consecutive completed days ending today or yesterday
    final today = DateTime.now();
    int streak = 0;
    DateTime checkDate = today;

    // First check if today is completed, if not, start from yesterday
    final todayPlan = await getPlanForDate(userId, today);
    if (todayPlan == null || !todayPlan.isCompleted) {
      checkDate = today.subtract(const Duration(days: 1));
    }

    // Count consecutive completed days
    while (true) {
      final plan = await getPlanForDate(userId, checkDate);
      if (plan != null && plan.isCompleted) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  @override
  Future<int> getLongestStreak(String userId) async {
    // Get all completed plans ordered by date
    final results = await databaseHelper.rawQuery('''
      SELECT date FROM daily_plans
      WHERE user_id = ? AND is_completed = 1
      ORDER BY date ASC
    ''', [userId]);

    if (results.isEmpty) return 0;

    int longestStreak = 1;
    int currentStreak = 1;
    DateTime? previousDate;

    for (final row in results) {
      final date = DateTime.parse(row['date'] as String);

      if (previousDate != null) {
        final difference = date.difference(previousDate).inDays;
        if (difference == 1) {
          currentStreak++;
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
          }
        } else {
          currentStreak = 1;
        }
      }

      previousDate = date;
    }

    return longestStreak;
  }

  @override
  Future<DateTime?> getLastPrayerDate(String userId) async {
    final results = await databaseHelper.rawQuery('''
      SELECT date FROM daily_plans
      WHERE user_id = ? AND is_completed = 1
      ORDER BY date DESC
      LIMIT 1
    ''', [userId]);

    if (results.isEmpty) return null;
    return DateTime.parse(results.first['date'] as String);
  }

  @override
  Future<Map<int, bool>> getWeekDaysCompleted(String userId, DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final plans = await getPlansForDateRange(userId, weekStart, weekEnd);

    final Map<int, bool> weekDays = {};
    for (final plan in plans) {
      weekDays[plan.date.weekday] = plan.isCompleted;
    }

    return weekDays;
  }
}
