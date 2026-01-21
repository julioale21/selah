import 'package:flutter/material.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../domain/entities/goal_progress.dart';
import '../../domain/entities/prayer_goal.dart';

class GoalProgressCard extends StatelessWidget {
  final GoalProgress progress;
  final VoidCallback? onTap;

  const GoalProgressCard({
    super.key,
    required this.progress,
    this.onTap,
  });

  String get _goalLabel {
    switch (progress.goal.type) {
      case GoalType.dailyDuration:
        return 'Meta del día';
      case GoalType.weeklyDuration:
        return 'Meta de la semana';
      case GoalType.sessionsPerWeek:
        return 'Sesiones de la semana';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(SelahSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.06),
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
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: progress.isCompleted
                          ? [
                              SelahColors.thanksgiving,
                              SelahColors.thanksgiving.withValues(alpha: 0.7),
                            ]
                          : [
                              SelahColors.supplication,
                              SelahColors.supplication.withValues(alpha: 0.7),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    progress.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.flag_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: SelahSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _goalLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        progress.motivationalMessage,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
              ],
            ),
            const SizedBox(height: SelahSpacing.lg),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clampedPercentage,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.06),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress.isCompleted
                      ? SelahColors.thanksgiving
                      : SelahColors.supplication,
                ),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: SelahSpacing.sm),

            // Progress text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  progress.progressString,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: progress.isCompleted
                        ? SelahColors.thanksgiving.withValues(alpha: 0.15)
                        : SelahColors.supplication.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${progress.percentageInt}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: progress.isCompleted
                          ? SelahColors.thanksgiving
                          : SelahColors.supplication,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact version of the goal progress card for smaller spaces
class GoalProgressCardCompact extends StatelessWidget {
  final GoalProgress progress;
  final VoidCallback? onTap;

  const GoalProgressCardCompact({
    super.key,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SelahSpacing.md,
          vertical: SelahSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: progress.isCompleted
                ? [
                    SelahColors.thanksgiving.withValues(alpha: 0.15),
                    SelahColors.thanksgiving.withValues(alpha: 0.05),
                  ]
                : [
                    SelahColors.supplication.withValues(alpha: 0.15),
                    SelahColors.supplication.withValues(alpha: 0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: progress.isCompleted
                ? SelahColors.thanksgiving.withValues(alpha: 0.3)
                : SelahColors.supplication.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              progress.isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.flag_rounded,
              color: progress.isCompleted
                  ? SelahColors.thanksgiving
                  : SelahColors.supplication,
              size: 20,
            ),
            const SizedBox(width: SelahSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    progress.progressString,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clampedPercentage,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.06),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress.isCompleted
                            ? SelahColors.thanksgiving
                            : SelahColors.supplication,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SelahSpacing.sm),
            Text(
              '${progress.percentageInt}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: progress.isCompleted
                    ? SelahColors.thanksgiving
                    : SelahColors.supplication,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
