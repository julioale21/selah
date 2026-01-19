import '../../../../core/database/database_helper.dart';
import '../../domain/entities/prayer_stats.dart';
import '../../domain/entities/streak_info.dart';
import '../../domain/repositories/stats_repository.dart';

abstract class StatsLocalDataSource {
  Future<PrayerStats> getStats(String userId, StatsPeriod period);
  Future<StreakInfo> getStreakInfo(String userId);
  Future<Map<String, int>> getWeeklyActivity(String userId);
  Future<List<TopicStat>> getTopTopics(String userId, {int limit = 5});
}

class StatsLocalDataSourceImpl implements StatsLocalDataSource {
  final DatabaseHelper databaseHelper;

  StatsLocalDataSourceImpl({required this.databaseHelper});

  DateTime _getStartDate(StatsPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case StatsPeriod.week:
        return now.subtract(const Duration(days: 7));
      case StatsPeriod.month:
        return DateTime(now.year, now.month - 1, now.day);
      case StatsPeriod.year:
        return DateTime(now.year - 1, now.month, now.day);
      case StatsPeriod.allTime:
        return DateTime(2000);
    }
  }

  @override
  Future<PrayerStats> getStats(String userId, StatsPeriod period) async {
    final db = await databaseHelper.database;
    final startDate = _getStartDate(period);
    final startDateStr = startDate.toIso8601String();

    // Total sessions and minutes
    final sessionsResult = await db.rawQuery('''
      SELECT
        COUNT(*) as total_sessions,
        COALESCE(SUM(duration_seconds), 0) as total_seconds
      FROM prayer_sessions
      WHERE user_id = ? AND started_at >= ?
    ''', [userId, startDateStr]);

    final totalSessions = sessionsResult.first['total_sessions'] as int? ?? 0;
    final totalSeconds = sessionsResult.first['total_seconds'] as int? ?? 0;
    final totalMinutes = totalSeconds ~/ 60;
    final averageMinutes = totalSessions > 0
        ? totalSeconds / 60 / totalSessions
        : 0.0;

    // Total topics prayed
    final topicsResult = await db.rawQuery('''
      SELECT COUNT(DISTINCT topic_id) as total_topics
      FROM journal_entries
      WHERE user_id = ? AND created_at >= ? AND topic_id IS NOT NULL
    ''', [userId, startDateStr]);
    final totalTopics = topicsResult.first['total_topics'] as int? ?? 0;

    // Total journal entries
    final entriesResult = await db.rawQuery('''
      SELECT COUNT(*) as total_entries
      FROM journal_entries
      WHERE user_id = ? AND created_at >= ?
    ''', [userId, startDateStr]);
    final totalEntries = entriesResult.first['total_entries'] as int? ?? 0;

    // Answered prayers
    final answeredResult = await db.rawQuery('''
      SELECT COUNT(*) as answered
      FROM answered_prayers
      WHERE user_id = ? AND answered_at IS NOT NULL AND answered_at >= ?
    ''', [userId, startDateStr]);
    final answeredPrayers = answeredResult.first['answered'] as int? ?? 0;

    // Minutes by ACTS phase
    final phaseResult = await db.rawQuery('''
      SELECT acts_step, COUNT(*) as count
      FROM journal_entries
      WHERE user_id = ? AND created_at >= ? AND acts_step IS NOT NULL
      GROUP BY acts_step
    ''', [userId, startDateStr]);

    final minutesByPhase = <String, int>{};
    for (final row in phaseResult) {
      final phase = row['acts_step'] as String?;
      final count = row['count'] as int? ?? 0;
      if (phase != null) {
        minutesByPhase[phase] = count;
      }
    }

    // Sessions by day of week
    final dayResult = await db.rawQuery('''
      SELECT strftime('%w', started_at) as day, COUNT(*) as count
      FROM prayer_sessions
      WHERE user_id = ? AND started_at >= ?
      GROUP BY day
    ''', [userId, startDateStr]);

    final sessionsByDay = <String, int>{};
    for (final row in dayResult) {
      final day = row['day'] as String?;
      final count = row['count'] as int? ?? 0;
      if (day != null) {
        sessionsByDay[day] = count;
      }
    }

    // Top topics
    final topTopics = await getTopTopics(userId, limit: 5);

    return PrayerStats(
      totalSessions: totalSessions,
      totalMinutes: totalMinutes,
      totalTopicsPrayed: totalTopics,
      totalJournalEntries: totalEntries,
      answeredPrayers: answeredPrayers,
      averageSessionMinutes: averageMinutes,
      minutesByPhase: minutesByPhase,
      sessionsByDay: sessionsByDay,
      topTopics: topTopics,
    );
  }

  @override
  Future<StreakInfo> getStreakInfo(String userId) async {
    final db = await databaseHelper.database;

    // Get all prayer dates ordered by date desc
    final result = await db.rawQuery('''
      SELECT DISTINCT date(started_at) as prayer_date
      FROM prayer_sessions
      WHERE user_id = ?
      ORDER BY prayer_date DESC
    ''', [userId]);

    if (result.isEmpty) {
      return const StreakInfo();
    }

    final dates = result
        .map((row) => DateTime.parse(row['prayer_date'] as String))
        .toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastPrayerDate = dates.first;
    final prayedToday = lastPrayerDate == today;

    // Calculate current streak
    int currentStreak = 0;
    DateTime checkDate = prayedToday ? today : today.subtract(const Duration(days: 1));

    for (final date in dates) {
      if (date == checkDate) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (date.isBefore(checkDate)) {
        break;
      }
    }

    // If didn't pray today and didn't pray yesterday, streak is 0
    if (!prayedToday) {
      final yesterday = today.subtract(const Duration(days: 1));
      if (lastPrayerDate != yesterday) {
        currentStreak = 0;
      }
    }

    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 1;

    for (int i = 0; i < dates.length - 1; i++) {
      final diff = dates[i].difference(dates[i + 1]).inDays;
      if (diff == 1) {
        tempStreak++;
      } else {
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
        tempStreak = 1;
      }
    }
    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }

    // Recent prayer dates (last 30 days)
    final thirtyDaysAgo = today.subtract(const Duration(days: 30));
    final recentDates = dates.where((d) => d.isAfter(thirtyDaysAgo)).toList();

    return StreakInfo(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastPrayerDate: lastPrayerDate,
      prayedToday: prayedToday,
      recentPrayerDates: recentDates,
    );
  }

  @override
  Future<Map<String, int>> getWeeklyActivity(String userId) async {
    final db = await databaseHelper.database;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final result = await db.rawQuery('''
      SELECT date(started_at) as prayer_date,
             COALESCE(SUM(duration_seconds), 0) as total_seconds
      FROM prayer_sessions
      WHERE user_id = ? AND started_at >= ?
      GROUP BY prayer_date
      ORDER BY prayer_date
    ''', [userId, weekAgo.toIso8601String()]);

    final activity = <String, int>{};
    for (final row in result) {
      final date = row['prayer_date'] as String?;
      final seconds = row['total_seconds'] as int? ?? 0;
      if (date != null) {
        activity[date] = seconds ~/ 60;
      }
    }

    return activity;
  }

  @override
  Future<List<TopicStat>> getTopTopics(String userId, {int limit = 5}) async {
    final db = await databaseHelper.database;

    final result = await db.rawQuery('''
      SELECT
        pt.id as topic_id,
        pt.title as topic_title,
        COUNT(DISTINCT ps.id) as times_prayed,
        COALESCE(SUM(ps.duration_seconds), 0) as total_seconds
      FROM prayer_topics pt
      LEFT JOIN prayer_sessions ps ON ps.topics_prayed LIKE '%' || pt.id || '%'
      WHERE pt.user_id = ?
      GROUP BY pt.id
      ORDER BY times_prayed DESC
      LIMIT ?
    ''', [userId, limit]);

    return result.map((row) {
      return TopicStat(
        topicId: row['topic_id'] as String? ?? '',
        topicTitle: row['topic_title'] as String? ?? '',
        timesPrayed: row['times_prayed'] as int? ?? 0,
        totalMinutes: ((row['total_seconds'] as int? ?? 0) ~/ 60),
      );
    }).toList();
  }
}
