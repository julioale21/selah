import 'package:flutter/material.dart';

import '../theme/selah_colors.dart';
import '../theme/selah_spacing.dart';
import '../theme/selah_typography.dart';

enum SelahButtonVariant { primary, secondary, text, danger }
enum SelahButtonSize { small, medium, large }

class SelahButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final SelahButtonVariant variant;
  final SelahButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const SelahButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = SelahButtonVariant.primary,
    this.size = SelahButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = _getPadding();

    Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(_getLoadingColor()),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: _getIconSize()),
                const SizedBox(width: SelahSpacing.xs),
              ],
              Text(label, style: _getTextStyle()),
            ],
          );

    Widget button;
    switch (variant) {
      case SelahButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: SelahColors.primary,
            foregroundColor: Colors.white,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
            ),
          ),
          child: child,
        );
        break;
      case SelahButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: SelahColors.primary,
            side: const BorderSide(color: SelahColors.primary),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
            ),
          ),
          child: child,
        );
        break;
      case SelahButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: SelahColors.primary,
            padding: padding,
          ),
          child: child,
        );
        break;
      case SelahButtonVariant.danger:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: SelahColors.error,
            foregroundColor: Colors.white,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
            ),
          ),
          child: child,
        );
        break;
    }

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case SelahButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case SelahButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case SelahButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case SelahButtonSize.small:
        return SelahTypography.labelSmall;
      case SelahButtonSize.medium:
        return SelahTypography.labelLarge;
      case SelahButtonSize.large:
        return SelahTypography.titleMedium;
    }
  }

  double _getIconSize() {
    switch (size) {
      case SelahButtonSize.small:
        return 16;
      case SelahButtonSize.medium:
        return 20;
      case SelahButtonSize.large:
        return 24;
    }
  }

  Color _getLoadingColor() {
    switch (variant) {
      case SelahButtonVariant.primary:
      case SelahButtonVariant.danger:
        return Colors.white;
      case SelahButtonVariant.secondary:
      case SelahButtonVariant.text:
        return SelahColors.primary;
    }
  }
}
