import 'package:flutter/material.dart';

import '../theme/selah_colors.dart';
import '../theme/selah_spacing.dart';

enum SelahCardVariant { elevated, outlined, filled }

class SelahCard extends StatelessWidget {
  final Widget child;
  final SelahCardVariant variant;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;

  const SelahCard({
    super.key,
    required this.child,
    this.variant = SelahCardVariant.elevated,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultPadding = padding ?? const EdgeInsets.all(SelahSpacing.cardPadding);

    BoxDecoration decoration;
    switch (variant) {
      case SelahCardVariant.elevated:
        decoration = BoxDecoration(
          color: backgroundColor ?? (isDark ? SelahColors.surfaceDark : SelahColors.surfaceLight),
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
        break;
      case SelahCardVariant.outlined:
        decoration = BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          border: Border.all(
            color: borderColor ?? (isDark ? SelahColors.dividerDark : SelahColors.dividerLight),
          ),
        );
        break;
      case SelahCardVariant.filled:
        decoration = BoxDecoration(
          color: backgroundColor ?? (isDark ? SelahColors.surfaceDark : SelahColors.backgroundLight),
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
        );
        break;
    }

    Widget card = Container(
      decoration: decoration,
      padding: defaultPadding,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          child: card,
        ),
      );
    }

    return card;
  }
}
