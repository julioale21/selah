import '../entities/prayer_stats.dart';
import '../entities/streak_info.dart';

enum StatsPeriod { week, month, year, allTime }

abstract class StatsRepository {
  Future<PrayerStats> getStats(String userId, StatsPeriod period);
  Future<StreakInfo> getStreakInfo(String userId);
  Future<Map<String, int>> getWeeklyActivity(String userId);
  Future<List<TopicStat>> getTopTopics(String userId, {int limit = 5});
}
