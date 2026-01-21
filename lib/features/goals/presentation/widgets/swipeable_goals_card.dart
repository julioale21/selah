import 'package:flutter/material.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../domain/entities/goal_progress.dart';
import '../../domain/entities/prayer_goal.dart';

class SwipeableGoalsCard extends StatefulWidget {
  final List<GoalProgress> progressList;
  final VoidCallback? onTap;
  final Function(GoalProgress progress)? onGoalCompleted;

  const SwipeableGoalsCard({
    super.key,
    required this.progressList,
    this.onTap,
    this.onGoalCompleted,
  });

  @override
  State<SwipeableGoalsCard> createState() => _SwipeableGoalsCardState();
}

class _SwipeableGoalsCardState extends State<SwipeableGoalsCard> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.progressList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Goal cards with PageView
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: widget.progressList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _GoalCard(
                  progress: widget.progressList[index],
                  onTap: widget.onTap,
                  isDark: isDark,
                ),
              );
            },
          ),
        ),

        // Page indicators and navigation
        if (widget.progressList.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left arrow
              _NavButton(
                icon: Icons.chevron_left_rounded,
                enabled: _currentPage > 0,
                isDark: isDark,
                onTap: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              const SizedBox(width: 12),

              // Dots
              ...List.generate(
                widget.progressList.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _DotIndicator(
                    isActive: index == _currentPage,
                    goalType: widget.progressList[index].goal.type,
                    isDark: isDark,
                  ),
                ),
              ),

              const SizedBox(width: 12),
              // Right arrow
              _NavButton(
                icon: Icons.chevron_right_rounded,
                enabled: _currentPage < widget.progressList.length - 1,
                isDark: isDark,
                onTap: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalProgress progress;
  final VoidCallback? onTap;
  final bool isDark;

  const _GoalCard({
    required this.progress,
    this.onTap,
    required this.isDark,
  });

  Color get _accentColor {
    switch (progress.goal.type) {
      case GoalType.dailyDuration:
        return SelahColors.adoration;
      case GoalType.weeklyDuration:
        return SelahColors.supplication;
      case GoalType.monthlyDuration:
        return SelahColors.thanksgiving;
      case GoalType.annualDuration:
        return SelahColors.confession;
    }
  }

  String get _periodLabel {
    switch (progress.goal.type) {
      case GoalType.dailyDuration:
        return 'Hoy';
      case GoalType.weeklyDuration:
        return 'Esta semana';
      case GoalType.monthlyDuration:
        return 'Este mes';
      case GoalType.annualDuration:
        return 'Este año';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(SelahSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: progress.isCompleted
                ? SelahColors.thanksgiving.withValues(alpha: 0.5)
                : isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.06),
            width: progress.isCompleted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _accentColor,
                        _accentColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    progress.isCompleted
                        ? Icons.check_rounded
                        : Icons.flag_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress.goal.typeDisplayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        _periodLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                // Percentage
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: progress.isCompleted
                        ? SelahColors.thanksgiving.withValues(alpha: 0.15)
                        : _accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${progress.percentageInt}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: progress.isCompleted
                          ? SelahColors.thanksgiving
                          : _accentColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clampedPercentage,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.06),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress.isCompleted ? SelahColors.thanksgiving : _accentColor,
                ),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 8),

            // Progress text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  progress.progressString,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                if (progress.isCompleted)
                  Text(
                    progress.motivationalMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: SelahColors.thanksgiving,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else if (progress.remainingMinutes > 0)
                  Text(
                    'Faltan ${_formatMinutes(progress.remainingMinutes)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '$hours ${hours == 1 ? 'hora' : 'horas'}';
      }
      return '${hours}h ${mins}min';
    }
    return '$minutes min';
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final bool isDark;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? (isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? (isDark ? Colors.white70 : Colors.black54)
              : (isDark ? Colors.white24 : Colors.black12),
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final bool isActive;
  final GoalType goalType;
  final bool isDark;

  const _DotIndicator({
    required this.isActive,
    required this.goalType,
    required this.isDark,
  });

  Color get _color {
    switch (goalType) {
      case GoalType.dailyDuration:
        return SelahColors.adoration;
      case GoalType.weeklyDuration:
        return SelahColors.supplication;
      case GoalType.monthlyDuration:
        return SelahColors.thanksgiving;
      case GoalType.annualDuration:
        return SelahColors.confession;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? _color
            : (isDark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
