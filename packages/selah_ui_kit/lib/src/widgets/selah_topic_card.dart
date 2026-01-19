import 'package:flutter/material.dart';

import '../theme/selah_colors.dart';
import '../theme/selah_spacing.dart';
import '../theme/selah_typography.dart';

class SelahTopicCard extends StatelessWidget {
  final String title;
  final String? description;
  final String category;
  final IconData icon;
  final int prayerCount;
  final int answeredCount;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SelahTopicCard({
    super.key,
    required this.title,
    this.description,
    required this.category,
    required this.icon,
    this.prayerCount = 0,
    this.answeredCount = 0,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = SelahColors.getCategoryColor(category);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? SelahColors.surfaceDark : SelahColors.surfaceLight,
            borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
            border: Border(
              left: BorderSide(
                color: categoryColor,
                width: 4,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(SelahSpacing.cardPadding),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(SelahSpacing.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: SelahSpacing.md),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: SelahTypography.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description != null) ...[
                      const SizedBox(height: SelahSpacing.xxs),
                      Text(
                        description!,
                        style: SelahTypography.bodySmall.copyWith(
                          color: isDark
                              ? SelahColors.textSecondaryDark
                              : SelahColors.textSecondaryLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: SelahSpacing.xs),
                    // Stats row
                    Row(
                      children: [
                        _StatChip(
                          icon: Icons.repeat,
                          value: prayerCount.toString(),
                          color: SelahColors.primary,
                        ),
                        const SizedBox(width: SelahSpacing.sm),
                        _StatChip(
                          icon: Icons.check_circle,
                          value: answeredCount.toString(),
                          color: SelahColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right,
                color: isDark
                    ? SelahColors.textSecondaryDark
                    : SelahColors.textSecondaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: SelahTypography.labelSmall.copyWith(color: color),
        ),
      ],
    );
  }
}
