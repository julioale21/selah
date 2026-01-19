import 'package:flutter/material.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../domain/entities/answered_prayer.dart';

class PrayerCard extends StatelessWidget {
  final AnsweredPrayer prayer;
  final bool isPending;
  final VoidCallback? onMarkAnswered;
  final VoidCallback? onDelete;

  const PrayerCard({
    super.key,
    required this.prayer,
    required this.isPending,
    this.onMarkAnswered,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SelahSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPending ? Icons.pending_outlined : Icons.check_circle,
                  color: isPending ? SelahColors.warning : SelahColors.success,
                  size: 20,
                ),
                const SizedBox(width: SelahSpacing.xs),
                Text(
                  _formatDate(prayer.prayedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                if (!isPending && prayer.answeredAt != null) ...[
                  const Text(' → '),
                  Icon(Icons.celebration, size: 14, color: SelahColors.success),
                  const SizedBox(width: 2),
                  Text(
                    _formatDate(prayer.answeredAt!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SelahColors.success,
                        ),
                  ),
                ],
                const Spacer(),
                if (isPending)
                  Text(
                    prayer.waitingTimeDisplay,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
              prayer.prayerText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (!isPending && prayer.answerText != null) ...[
              const SizedBox(height: SelahSpacing.sm),
              Container(
                padding: const EdgeInsets.all(SelahSpacing.sm),
                decoration: BoxDecoration(
                  color: SelahColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SelahSpacing.radiusSm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.celebration,
                      color: SelahColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: SelahSpacing.xs),
                    Expanded(
                      child: Text(
                        prayer.answerText!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: SelahColors.success,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (isPending && onMarkAnswered != null) ...[
              const SizedBox(height: SelahSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onMarkAnswered,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Marcar como respondida'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SelahColors.success,
                    side: const BorderSide(color: SelahColors.success),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
