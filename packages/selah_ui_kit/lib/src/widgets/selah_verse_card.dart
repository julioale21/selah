import 'package:flutter/material.dart';

import '../theme/selah_colors.dart';
import '../theme/selah_spacing.dart';
import '../theme/selah_typography.dart';

class SelahVerseCard extends StatelessWidget {
  final String verseText;
  final String reference;
  final String? category;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const SelahVerseCard({
    super.key,
    required this.verseText,
    required this.reference,
    this.category,
    this.onTap,
    this.onShare,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = category != null
        ? SelahColors.getCategoryColor(category!)
        : SelahColors.secondary;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            categoryColor.withValues(alpha: 0.1),
            categoryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(SelahSpacing.radiusLg),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SelahSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(SelahSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quote icon
                Icon(
                  Icons.format_quote,
                  color: categoryColor.withValues(alpha: 0.5),
                  size: 32,
                ),
                const SizedBox(height: SelahSpacing.sm),

                // Verse text
                Text(
                  verseText,
                  style: SelahTypography.verseText.copyWith(
                    color: isDark
                        ? SelahColors.textPrimaryDark
                        : SelahColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: SelahSpacing.md),

                // Reference and actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reference,
                      style: SelahTypography.verseReference.copyWith(
                        color: categoryColor,
                      ),
                    ),
                    Row(
                      children: [
                        if (onFavorite != null)
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? SelahColors.error : categoryColor,
                            ),
                            onPressed: onFavorite,
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        if (onShare != null) ...[
                          const SizedBox(width: SelahSpacing.sm),
                          IconButton(
                            icon: Icon(Icons.share, color: categoryColor),
                            onPressed: onShare,
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
