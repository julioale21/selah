import 'package:flutter/material.dart';

import '../theme/selah_colors.dart';
import '../theme/selah_spacing.dart';
import '../theme/selah_typography.dart';
import 'selah_button.dart';

class SelahEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SelahEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SelahSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SelahColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: SelahColors.primary,
              ),
            ),
            const SizedBox(height: SelahSpacing.lg),
            Text(
              title,
              style: SelahTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: SelahSpacing.sm),
              Text(
                description!,
                style: SelahTypography.bodyMedium.copyWith(
                  color: isDark
                      ? SelahColors.textSecondaryDark
                      : SelahColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: SelahSpacing.lg),
              SelahButton(
                label: actionLabel!,
                onPressed: onAction,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
