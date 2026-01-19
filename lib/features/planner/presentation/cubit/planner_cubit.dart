import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/user_service.dart';
import '../../../prayer_topics/domain/entities/prayer_topic.dart';
import '../../../prayer_topics/domain/usecases/get_topics.dart';
import '../../domain/entities/daily_plan.dart';
import '../../domain/repositories/planner_repository.dart';
import 'planner_state.dart';

class PlannerCubit extends Cubit<PlannerState> {
  final PlannerRepository plannerRepository;
  final GetTopics getTopics;
  final UserService userService;
  static const _uuid = Uuid();

  PlannerCubit({
    required this.plannerRepository,
    required this.getTopics,
    required this.userService,
  }) : super(PlannerState.initial());

  String get _userId => userService.currentUserId;

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true));

    try {
      // Load topics
      final topicsResult = await getTopics(GetTopicsParams(userId: _userId));
      final topics = topicsResult.fold(
        (failure) => <PrayerTopic>[],
        (topicsList) => topicsList,
      );

      // Load plans for current month (with buffer for week view)
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month - 1, 1);
      final monthEnd = DateTime(now.year, now.month + 2, 0);
      final plans = await plannerRepository.getPlansForDateRange(
        _userId,
        monthStart,
        monthEnd,
      );

      // Load streak
      final streak = await plannerRepository.getStreak(_userId);

      // Load today's plan
      final todayPlan = await plannerRepository.getPlanForDate(_userId, now);

      // Generate suggestions
      final suggestions = _generateSuggestions(topics);

      emit(state.copyWith(
        allTopics: topics,
        weekPlans: plans,
        streak: streak,
        todayPlan: todayPlan,
        suggestedTopics: suggestions,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar datos: $e',
      ));
    }
  }

  Future<void> loadPlansForMonth(DateTime focusedDay) async {
    final monthStart = DateTime(focusedDay.year, focusedDay.month - 1, 1);
    final monthEnd = DateTime(focusedDay.year, focusedDay.month + 2, 0);
    final plans = await plannerRepository.getPlansForDateRange(
      _userId,
      monthStart,
      monthEnd,
    );
    emit(state.copyWith(weekPlans: plans));
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  void previousWeek() {
    final newWeekStart = state.weekStart.subtract(const Duration(days: 7));
    emit(state.copyWith(
      weekStart: DateTime(newWeekStart.year, newWeekStart.month, newWeekStart.day),
    ));
    _loadWeekPlans();
  }

  void nextWeek() {
    final newWeekStart = state.weekStart.add(const Duration(days: 7));
    emit(state.copyWith(
      weekStart: DateTime(newWeekStart.year, newWeekStart.month, newWeekStart.day),
    ));
    _loadWeekPlans();
  }

  void goToToday() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    emit(state.copyWith(
      selectedDate: now,
      weekStart: DateTime(weekStart.year, weekStart.month, weekStart.day),
    ));
    _loadWeekPlans();
  }

  Future<void> _loadWeekPlans() async {
    final weekEnd = state.weekStart.add(const Duration(days: 6));
    final plans = await plannerRepository.getPlansForDateRange(
      _userId,
      state.weekStart,
      weekEnd,
    );
    emit(state.copyWith(weekPlans: plans));
  }

  Future<void> createPlanForDate(DateTime date, List<String> topicIds) async {
    if (topicIds.isEmpty) {
      emit(state.copyWith(errorMessage: 'Selecciona al menos un tema'));
      return;
    }

    try {
      final plan = DailyPlan(
        id: _uuid.v4(),
        userId: _userId,
        date: DateTime(date.year, date.month, date.day),
        topicIds: topicIds,
      );

      await plannerRepository.savePlan(plan);

      // Reload week plans
      await _loadWeekPlans();

      // Update today's plan if the created plan is for today
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        emit(state.copyWith(todayPlan: plan));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al crear plan: $e'));
    }
  }

  Future<void> markPlanCompleted(String planId, {String? sessionId}) async {
    try {
      final updatedPlan = await plannerRepository.markPlanCompleted(planId, sessionId);

      // Reload data to update streak
      final streak = await plannerRepository.getStreak(_userId);
      await _loadWeekPlans();

      // Update today's plan if it's the one that was completed
      if (state.todayPlan?.id == planId) {
        emit(state.copyWith(todayPlan: updatedPlan, streak: streak));
      } else {
        emit(state.copyWith(streak: streak));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al marcar plan: $e'));
    }
  }

  Future<void> deletePlan(String planId) async {
    try {
      await plannerRepository.deletePlan(planId);
      await _loadWeekPlans();

      if (state.todayPlan?.id == planId) {
        emit(state.copyWith(clearTodayPlan: true));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error al eliminar plan: $e'));
    }
  }

  List<PrayerTopic> _generateSuggestions(List<PrayerTopic> allTopics) {
    if (allTopics.isEmpty) return [];

    final today = DateTime.now().weekday;
    final suggestions = <PrayerTopic>[];

    // Group by category
    final byCategory = <String?, List<PrayerTopic>>{};
    for (final topic in allTopics.where((t) => t.isActive)) {
      byCategory.putIfAbsent(topic.categoryId, () => []).add(topic);
    }

    // Select one from each category based on the day, prioritizing less prayed
    final categories = byCategory.keys.toList();
    for (var i = 0; i < 3 && i < categories.length; i++) {
      final categoryIndex = (today + i) % categories.length;
      final category = categories[categoryIndex];
      final topicsInCategory = byCategory[category]!;
      if (topicsInCategory.isNotEmpty) {
        // Sort by prayer count (ascending) to suggest less prayed topics
        topicsInCategory.sort((a, b) => a.prayerCount.compareTo(b.prayerCount));
        suggestions.add(topicsInCategory.first);
      }
    }

    return suggestions;
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
