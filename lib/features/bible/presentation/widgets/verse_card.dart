import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/verse.dart';

class VerseCard extends StatelessWidget {
  final Verse verse;
  final VoidCallback? onFavorite;
  final bool showCategory;

  const VerseCard({
    super.key,
    required this.verse,
    this.onFavorite,
    this.showCategory = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SelahSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category chip
            if (showCategory)
              Padding(
                padding: const EdgeInsets.only(bottom: SelahSpacing.sm),
                child: Chip(
                  label: Text(
                    _capitalizeCategory(verse.category),
                    style: const TextStyle(fontSize: 11),
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),

            // Verse text
            Text(
              '"${verse.textEs}"',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: SelahSpacing.sm),

            // Reference
            Text(
              verse.displayReference,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: SelahColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),

            // Actions
            const SizedBox(height: SelahSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: 'Copiar',
                  onPressed: () => _copyToClipboard(context),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.share, size: 20),
                  tooltip: 'Compartir',
                  onPressed: () => _share(),
                  visualDensity: VisualDensity.compact,
                ),
                if (onFavorite != null)
                  IconButton(
                    icon: Icon(
                      verse.isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: verse.isFavorite ? Colors.red : null,
                    ),
                    tooltip: verse.isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
                    onPressed: onFavorite,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _capitalizeCategory(String category) {
    if (category.isEmpty) return category;
    return '${category[0].toUpperCase()}${category.substring(1)}';
  }

  void _copyToClipboard(BuildContext context) {
    final text = '"${verse.textEs}"\n- ${verse.displayReference}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Versículo copiado'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _share() {
    final text = '"${verse.textEs}"\n- ${verse.displayReference}\n\nCompartido desde Selah';
    SharePlus.instance.share(ShareParams(text: text));
  }
}
