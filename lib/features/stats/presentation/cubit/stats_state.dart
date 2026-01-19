import 'package:equatable/equatable.dart';

import '../../domain/entities/prayer_stats.dart';
import '../../domain/entities/streak_info.dart';
import '../../domain/repositories/stats_repository.dart';

enum StatsStatus { initial, loading, loaded, error }

class StatsState extends Equatable {
  final StatsStatus status;
  final StatsPeriod selectedPeriod;
  final PrayerStats stats;
  final StreakInfo streakInfo;
  final Map<String, int> weeklyActivity;
  final String? errorMessage;

  const StatsState({
    this.status = StatsStatus.initial,
    this.selectedPeriod = StatsPeriod.week,
    this.stats = const PrayerStats(),
    this.streakInfo = const StreakInfo(),
    this.weeklyActivity = const {},
    this.errorMessage,
  });

  bool get isLoading => status == StatsStatus.loading;
  bool get hasData => stats.totalSessions > 0;

  String get periodLabel {
    switch (selectedPeriod) {
      case StatsPeriod.week:
        return 'Esta semana';
      case StatsPeriod.month:
        return 'Este mes';
      case StatsPeriod.year:
        return 'Este año';
      case StatsPeriod.allTime:
        return 'Todo el tiempo';
    }
  }

  StatsState copyWith({
    StatsStatus? status,
    StatsPeriod? selectedPeriod,
    PrayerStats? stats,
    StreakInfo? streakInfo,
    Map<String, int>? weeklyActivity,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StatsState(
      status: status ?? this.status,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      stats: stats ?? this.stats,
      streakInfo: streakInfo ?? this.streakInfo,
      weeklyActivity: weeklyActivity ?? this.weeklyActivity,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedPeriod,
        stats,
        streakInfo,
        weeklyActivity,
        errorMessage,
      ];
}
