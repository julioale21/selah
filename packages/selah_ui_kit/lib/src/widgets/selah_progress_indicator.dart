import 'package:flutter/material.dart';

import '../theme/selah_colors.dart';
import '../theme/selah_spacing.dart';
import '../theme/selah_typography.dart';

class SelahProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String? label;
  final Color? color;
  final double height;
  final bool showPercentage;

  const SelahProgressIndicator({
    super.key,
    required this.progress,
    this.label,
    this.color,
    this.height = 8,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressColor = color ?? SelahColors.primary;
    final backgroundColor = isDark
        ? SelahColors.dividerDark
        : SelahColors.dividerLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: SelahSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: SelahTypography.labelMedium.copyWith(
                      color: isDark
                          ? SelahColors.textSecondaryDark
                          : SelahColors.textSecondaryLight,
                    ),
                  ),
                if (showPercentage)
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: SelahTypography.labelMedium.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(height / 2),
              child: Stack(
                children: [
                  Container(
                    height: height,
                    width: double.infinity,
                    color: backgroundColor,
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: height,
                    width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
