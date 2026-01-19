import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../domain/entities/prayer_stats.dart';
import '../../domain/entities/streak_info.dart';
import '../../domain/repositories/stats_repository.dart';
import '../cubit/stats_cubit.dart';
import '../cubit/stats_state.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StatsCubit>().loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StatsCubit, StatsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
          context.read<StatsCubit>().clearError();
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF0D1117)
              : const Color(0xFFF5F5F7),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => context.read<StatsCubit>().loadStats(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Hero header with streak
                      _StreakHeader(
                        streakInfo: state.streakInfo,
                        isDark: isDark,
                      ),

                      // Period selector
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SelahSpacing.screenPadding,
                          ),
                          child: _PeriodSelector(
                            selectedPeriod: state.selectedPeriod,
                            onChanged: (period) =>
                                context.read<StatsCubit>().changePeriod(period),
                            isDark: isDark,
                          ),
                        ),
                      ),

                      // Stats grid
                      SliverPadding(
                        padding: const EdgeInsets.all(SelahSpacing.screenPadding),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            children: [
                              _StatsGrid(stats: state.stats, isDark: isDark),
                              const SizedBox(height: SelahSpacing.lg),

                              // Weekly activity
                              _WeeklyActivityCard(
                                activity: state.weeklyActivity,
                                isDark: isDark,
                              ),
                              const SizedBox(height: SelahSpacing.lg),

                              // ACTS distribution
                              if (state.stats.minutesByPhase.isNotEmpty) ...[
                                _ACTSDistributionCard(
                                  minutesByPhase: state.stats.minutesByPhase,
                                  isDark: isDark,
                                ),
                                const SizedBox(height: SelahSpacing.lg),
                              ],

                              // Top topics
                              if (state.stats.topTopics.isNotEmpty)
                                _TopTopicsCard(
                                  topics: state.stats.topTopics,
                                  isDark: isDark,
                                ),

                              const SizedBox(height: SelahSpacing.xl),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _StreakHeader extends StatelessWidget {
  final StreakInfo streakInfo;
  final bool isDark;

  const _StreakHeader({
    required this.streakInfo,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final streakColor = streakInfo.currentStreak > 0
        ? SelahColors.thanksgiving
        : Colors.grey;

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: isDark
          ? const Color(0xFF161B22)
          : Colors.white,
      title: const Text('Estadísticas'),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1A1F2E),
                      const Color(0xFF0D1117),
                    ]
                  : [
                      Colors.white,
                      const Color(0xFFF5F5F7),
                    ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
              child: Row(
                children: [
                  // Streak circle
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: streakInfo.currentStreak > 0
                            ? [
                                SelahColors.thanksgiving.withValues(alpha: 0.8),
                                SelahColors.adoration.withValues(alpha: 0.6),
                              ]
                            : [
                                Colors.grey.withValues(alpha: 0.3),
                                Colors.grey.withValues(alpha: 0.1),
                              ],
                      ),
                      boxShadow: streakInfo.currentStreak > 0
                          ? [
                              BoxShadow(
                                color: SelahColors.thanksgiving.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${streakInfo.currentStreak}',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: streakInfo.currentStreak > 0
                                ? Colors.white
                                : (isDark ? Colors.white54 : Colors.black38),
                          ),
                        ),
                        Text(
                          'días',
                          style: TextStyle(
                            fontSize: 12,
                            color: streakInfo.currentStreak > 0
                                ? Colors.white70
                                : (isDark ? Colors.white38 : Colors.black26),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Streak info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: streakColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Racha de oración',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          streakInfo.streakMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _MiniStat(
                              icon: Icons.emoji_events_outlined,
                              label: 'Mejor',
                              value: '${streakInfo.longestStreak}',
                              isDark: isDark,
                            ),
                            const SizedBox(width: 16),
                            if (streakInfo.prayedToday)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: SelahColors.success.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: SelahColors.success,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Hoy',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: SelahColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
      ],
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final StatsPeriod selectedPeriod;
  final ValueChanged<StatsPeriod> onChanged;
  final bool isDark;

  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: StatsPeriod.values.map((period) {
          final isSelected = period == selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  _getPeriodLabel(period),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white54 : Colors.black45),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getPeriodLabel(StatsPeriod period) {
    switch (period) {
      case StatsPeriod.week:
        return 'Semana';
      case StatsPeriod.month:
        return 'Mes';
      case StatsPeriod.year:
        return 'Año';
      case StatsPeriod.allTime:
        return 'Todo';
    }
  }
}

class _StatsGrid extends StatelessWidget {
  final PrayerStats stats;
  final bool isDark;

  const _StatsGrid({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.timer_outlined,
            value: stats.totalTimeFormatted,
            label: 'Tiempo total',
            color: SelahColors.adoration,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.self_improvement,
            value: '${stats.totalSessions}',
            label: 'Sesiones',
            color: SelahColors.confession,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyActivityCard extends StatelessWidget {
  final Map<String, int> activity;
  final bool isDark;

  const _WeeklyActivityCard({
    required this.activity,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DateTime(date.year, date.month, date.day);
    });

    final maxMinutes = activity.values.fold<int>(
        1, (max, val) => val > max ? val : max);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 18,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              const SizedBox(width: 8),
              Text(
                'Actividad semanal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((date) {
                final dateStr = date.toIso8601String().split('T')[0];
                final minutes = activity[dateStr] ?? 0;
                final heightRatio = maxMinutes > 0 ? minutes / maxMinutes : 0.0;
                final isToday = date.day == now.day &&
                    date.month == now.month &&
                    date.year == now.year;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (minutes > 0)
                          Text(
                            '${minutes}m',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        const SizedBox(height: 6),
                        Flexible(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: minutes > 0
                                ? (60 * heightRatio).clamp(8.0, 60.0)
                                : 8,
                            decoration: BoxDecoration(
                              gradient: minutes > 0
                                  ? LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        SelahColors.primary,
                                        SelahColors.primary.withValues(alpha: 0.6),
                                      ],
                                    )
                                  : null,
                              color: minutes > 0
                                  ? null
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.08)),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: minutes > 0
                                  ? [
                                      BoxShadow(
                                        color: SelahColors.primary.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getDayLabel(date),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday
                                ? SelahColors.primary
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayLabel(DateTime date) {
    const days = ['D', 'L', 'M', 'X', 'J', 'V', 'S'];
    return days[date.weekday % 7];
  }
}

class _ACTSDistributionCard extends StatelessWidget {
  final Map<String, int> minutesByPhase;
  final bool isDark;

  const _ACTSDistributionCard({
    required this.minutesByPhase,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final total = minutesByPhase.values.fold<int>(0, (sum, val) => sum + val);

    final phases = [
      ('adoration', 'A', 'Adoración', SelahColors.adoration),
      ('confession', 'C', 'Confesión', SelahColors.confession),
      ('thanksgiving', 'T', 'Gratitud', SelahColors.thanksgiving),
      ('supplication', 'S', 'Súplica', SelahColors.supplication),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 18,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              const SizedBox(width: 8),
              Text(
                'Distribución ACTS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: phases.map((phase) {
                  final count = minutesByPhase[phase.$1] ?? 0;
                  final ratio = total > 0 ? count / total : 0.25;
                  return Expanded(
                    flex: (ratio * 100).round().clamp(1, 100),
                    child: Container(color: phase.$4),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Legend grid
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _ACTSLegendItem(
                      letter: phases[0].$2,
                      label: phases[0].$3,
                      color: phases[0].$4,
                      count: minutesByPhase[phases[0].$1] ?? 0,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    _ACTSLegendItem(
                      letter: phases[1].$2,
                      label: phases[1].$3,
                      color: phases[1].$4,
                      count: minutesByPhase[phases[1].$1] ?? 0,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _ACTSLegendItem(
                      letter: phases[2].$2,
                      label: phases[2].$3,
                      color: phases[2].$4,
                      count: minutesByPhase[phases[2].$1] ?? 0,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    _ACTSLegendItem(
                      letter: phases[3].$2,
                      label: phases[3].$3,
                      color: phases[3].$4,
                      count: minutesByPhase[phases[3].$1] ?? 0,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ACTSLegendItem extends StatelessWidget {
  final String letter;
  final String label;
  final Color color;
  final int count;
  final bool isDark;

  const _ACTSLegendItem({
    required this.letter,
    required this.label,
    required this.color,
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopTopicsCard extends StatelessWidget {
  final List<TopicStat> topics;
  final bool isDark;

  const _TopTopicsCard({
    required this.topics,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 18,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              const SizedBox(width: 8),
              Text(
                'Temas más orados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...topics.asMap().entries.map((entry) {
            final index = entry.key;
            final topic = entry.value;
            final colors = [
              SelahColors.adoration,
              SelahColors.confession,
              SelahColors.thanksgiving,
              SelahColors.supplication,
              SelahColors.primary,
            ];
            final color = colors[index % colors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withValues(alpha: 0.8),
                          color.withValues(alpha: 0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      topic.topicTitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${topic.timesPrayed}x',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
