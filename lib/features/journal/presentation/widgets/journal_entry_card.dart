import 'package:flutter/material.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../../prayer_session/domain/entities/journal_entry.dart';

class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const JournalEntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(SelahSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _TypeBadge(type: entry.type),
                  const SizedBox(width: SelahSpacing.xs),
                  if (entry.actsStep != null) _ActsBadge(step: entry.actsStep!),
                  const Spacer(),
                  Text(
                    _formatTime(entry.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: onDelete,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              const SizedBox(height: SelahSpacing.sm),
              Text(
                entry.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: SelahSpacing.xs),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: entry.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#$tag',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _TypeBadge extends StatelessWidget {
  final JournalEntryType type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (type) {
      JournalEntryType.prayer => (Icons.self_improvement, SelahColors.primary, 'Oración'),
      JournalEntryType.reflection => (Icons.psychology, SelahColors.accent, 'Reflexión'),
      JournalEntryType.gratitude => (Icons.favorite, SelahColors.thanksgiving, 'Gratitud'),
      JournalEntryType.testimony => (Icons.auto_awesome, SelahColors.success, 'Testimonio'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ActsBadge extends StatelessWidget {
  final String step;

  const _ActsBadge({required this.step});

  @override
  Widget build(BuildContext context) {
    final color = switch (step.toLowerCase()) {
      'adoration' => SelahColors.adoration,
      'confession' => SelahColors.confession,
      'thanksgiving' => SelahColors.thanksgiving,
      'supplication' => SelahColors.supplication,
      _ => SelahColors.primary,
    };

    final label = switch (step.toLowerCase()) {
      'adoration' => 'A',
      'confession' => 'C',
      'thanksgiving' => 'T',
      'supplication' => 'S',
      _ => step[0].toUpperCase(),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
