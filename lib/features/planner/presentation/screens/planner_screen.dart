import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../../../core/router/selah_routes.dart';
import '../cubit/planner_cubit.dart';
import '../cubit/planner_state.dart';
import '../widgets/daily_plan_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/week_calendar.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PlannerCubit>().loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Hoy',
            onPressed: () {
              context.read<PlannerCubit>().goToToday();
            },
          ),
        ],
      ),
      body: BlocConsumer<PlannerCubit, PlannerState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
            context.read<PlannerCubit>().clearError();
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => context.read<PlannerCubit>().loadData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(SelahSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Streak card
                  StreakCard(streak: state.streak),
                  const SizedBox(height: SelahSpacing.lg),

                  // Week calendar
                  WeekCalendar(
                    selectedDate: state.selectedDate,
                    plans: state.weekPlans,
                    onDateSelected: (date) {
                      context.read<PlannerCubit>().selectDate(date);
                    },
                    onPageChanged: (focusedDay) {
                      context.read<PlannerCubit>().loadPlansForMonth(focusedDay);
                    },
                  ),
                  const SizedBox(height: SelahSpacing.lg),

                  // Date header
                  Text(
                    _formatDate(state.selectedDate),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: SelahSpacing.md),

                  // Plan for selected date
                  DailyPlanCard(
                    plan: state.getPlanForDate(state.selectedDate),
                    suggestedTopics: state.suggestedTopics,
                    allTopics: state.allTopics,
                    onCreatePlan: (topicIds) {
                      context.read<PlannerCubit>().createPlanForDate(
                            state.selectedDate,
                            topicIds,
                          );
                    },
                    onEditPlan: state.getPlanForDate(state.selectedDate) != null
                        ? (topicIds) {
                            final plan = state.getPlanForDate(state.selectedDate)!;
                            context.read<PlannerCubit>().updatePlanTopics(
                                  plan.id,
                                  topicIds,
                                );
                          }
                        : null,
                    onStartPrayer: () {
                      // Navigate to prayer session with the plan's topics
                      final plan = state.getPlanForDate(state.selectedDate);
                      if (plan != null) {
                        context.go(SelahRoutes.session, extra: plan.topicIds);
                      } else {
                        context.go(SelahRoutes.session);
                      }
                    },
                    onDeletePlan: state.getPlanForDate(state.selectedDate) != null
                        ? () => _showDeleteConfirmation(
                              context,
                              state.getPlanForDate(state.selectedDate)!.id,
                            )
                        : null,
                  ),

                  // Show empty state if no topics
                  if (state.allTopics.isEmpty) ...[
                    const SizedBox(height: SelahSpacing.xxl),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.topic_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: SelahSpacing.md),
                          Text(
                            'No tienes temas de oración',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: SelahSpacing.md),
                          OutlinedButton.icon(
                            onPressed: () => context.push(SelahRoutes.topics),
                            icon: const Icon(Icons.add),
                            label: const Text('Crear Temas'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final prefix = isToday ? 'Hoy, ' : '';

    return '$prefix${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }

  void _showDeleteConfirmation(BuildContext context, String planId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar plan'),
        content: const Text('¿Estás seguro de que deseas eliminar este plan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PlannerCubit>().deletePlan(planId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
