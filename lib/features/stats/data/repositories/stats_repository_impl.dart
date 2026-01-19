import '../../domain/entities/prayer_stats.dart';
import '../../domain/entities/streak_info.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_local_datasource.dart';

class StatsRepositoryImpl implements StatsRepository {
  final StatsLocalDataSource localDataSource;

  StatsRepositoryImpl({required this.localDataSource});

  @override
  Future<PrayerStats> getStats(String userId, StatsPeriod period) async {
    return await localDataSource.getStats(userId, period);
  }

  @override
  Future<StreakInfo> getStreakInfo(String userId) async {
    return await localDataSource.getStreakInfo(userId);
  }

  @override
  Future<Map<String, int>> getWeeklyActivity(String userId) async {
    return await localDataSource.getWeeklyActivity(userId);
  }

  @override
  Future<List<TopicStat>> getTopTopics(String userId, {int limit = 5}) async {
    return await localDataSource.getTopTopics(userId, limit: limit);
  }
}
