import 'package:equatable/equatable.dart';

import '../../../prayer_topics/domain/entities/prayer_topic.dart';
import '../../domain/entities/daily_plan.dart';
import '../../domain/entities/weekly_streak.dart';

class PlannerState extends Equatable {
  final DateTime selectedDate;
  final DateTime weekStart;
  final List<DailyPlan> weekPlans;
  final DailyPlan? todayPlan;
  final WeeklyStreak streak;
  final List<PrayerTopic> suggestedTopics;
  final List<PrayerTopic> allTopics;
  final bool isLoading;
  final String? errorMessage;

  const PlannerState({
    required this.selectedDate,
    required this.weekStart,
    this.weekPlans = const [],
    this.todayPlan,
    this.streak = const WeeklyStreak(),
    this.suggestedTopics = const [],
    this.allTopics = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  factory PlannerState.initial() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return PlannerState(
      selectedDate: now,
      weekStart: DateTime(weekStart.year, weekStart.month, weekStart.day),
    );
  }

  DailyPlan? getPlanForDate(DateTime date) {
    return weekPlans.where((p) =>
      p.date.year == date.year &&
      p.date.month == date.month &&
      p.date.day == date.day
    ).firstOrNull;
  }

  bool isDateCompleted(DateTime date) {
    final plan = getPlanForDate(date);
    return plan?.isCompleted ?? false;
  }

  bool get isToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
           selectedDate.month == now.month &&
           selectedDate.day == now.day;
  }

  PlannerState copyWith({
    DateTime? selectedDate,
    DateTime? weekStart,
    List<DailyPlan>? weekPlans,
    DailyPlan? todayPlan,
    bool clearTodayPlan = false,
    WeeklyStreak? streak,
    List<PrayerTopic>? suggestedTopics,
    List<PrayerTopic>? allTopics,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PlannerState(
      selectedDate: selectedDate ?? this.selectedDate,
      weekStart: weekStart ?? this.weekStart,
      weekPlans: weekPlans ?? this.weekPlans,
      todayPlan: clearTodayPlan ? null : (todayPlan ?? this.todayPlan),
      streak: streak ?? this.streak,
      suggestedTopics: suggestedTopics ?? this.suggestedTopics,
      allTopics: allTopics ?? this.allTopics,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        selectedDate,
        weekStart,
        weekPlans,
        todayPlan,
        streak,
        suggestedTopics,
        allTopics,
        isLoading,
        errorMessage,
      ];
}
