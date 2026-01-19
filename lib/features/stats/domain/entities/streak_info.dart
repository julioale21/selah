import 'package:equatable/equatable.dart';

class StreakInfo extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastPrayerDate;
  final bool prayedToday;
  final List<DateTime> recentPrayerDates;

  const StreakInfo({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastPrayerDate,
    this.prayedToday = false,
    this.recentPrayerDates = const [],
  });

  String get streakMessage {
    if (currentStreak == 0) {
      return 'Comienza tu racha hoy';
    } else if (currentStreak == 1) {
      return '1 día orando';
    } else {
      return '$currentStreak días consecutivos';
    }
  }

  bool get isAtRisk {
    if (lastPrayerDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastPrayer = DateTime(
      lastPrayerDate!.year,
      lastPrayerDate!.month,
      lastPrayerDate!.day,
    );
    return today.difference(lastPrayer).inDays == 1 && !prayedToday;
  }

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        lastPrayerDate,
        prayedToday,
        recentPrayerDates,
      ];
}
