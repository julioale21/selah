import 'package:equatable/equatable.dart';

class WeeklyStreak extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastPrayerDate;
  final Map<int, bool> weekDays; // 1-7 (Monday-Sunday)

  const WeeklyStreak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastPrayerDate,
    this.weekDays = const {},
  });

  bool get hasStreak => currentStreak > 0;

  bool isDayCompleted(int weekday) => weekDays[weekday] ?? false;

  WeeklyStreak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastPrayerDate,
    Map<int, bool>? weekDays,
  }) {
    return WeeklyStreak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastPrayerDate: lastPrayerDate ?? this.lastPrayerDate,
      weekDays: weekDays ?? this.weekDays,
    );
  }

  @override
  List<Object?> get props => [currentStreak, longestStreak, lastPrayerDate, weekDays];
}
