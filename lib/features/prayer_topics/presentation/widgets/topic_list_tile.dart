import 'package:flutter/material.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../../categories/domain/entities/category.dart' as cat;
import '../../domain/entities/prayer_topic.dart';

class TopicListTile extends StatelessWidget {
  final PrayerTopic topic;
  final cat.Category? category;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TopicListTile({
    super.key,
    required this.topic,
    this.category,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = cat.Category.iconMap[topic.iconName] ?? Icons.bookmark;
    final color = category?.color ?? Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: SelahSpacing.md,
        vertical: SelahSpacing.xs,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(SelahSpacing.md),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(SelahSpacing.radiusSm),
                ),
                child: Icon(
                  iconData,
                  color: color,
                ),
              ),
              const SizedBox(width: SelahSpacing.md),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (topic.description != null && topic.description!.isNotEmpty) ...[
                      const SizedBox(height: SelahSpacing.xxs),
                      Text(
                        topic.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: SelahSpacing.xs),
                    Row(
                      children: [
                        if (category != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SelahSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(SelahSpacing.radiusSm),
                            ),
                            child: Text(
                              category!.name,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: color,
                                  ),
                            ),
                          ),
                          const SizedBox(width: SelahSpacing.sm),
                        ],
                        Icon(
                          Icons.favorite,
                          size: 14,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${topic.prayerCount}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        if (topic.answeredCount > 0) ...[
                          const SizedBox(width: SelahSpacing.sm),
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: SelahColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${topic.answeredCount}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: SelahColors.success,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(
                        'Eliminar',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
