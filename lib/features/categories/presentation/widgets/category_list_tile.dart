import 'package:flutter/material.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../domain/entities/category.dart';

class CategoryListTile extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showDragHandle;

  const CategoryListTile({
    super.key,
    required this.category,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showDragHandle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: SelahSpacing.md,
        vertical: SelahSpacing.xs,
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle) ...[
              ReorderableDragStartListener(
                index: 0,
                child: const Icon(Icons.drag_handle),
              ),
              const SizedBox(width: SelahSpacing.sm),
            ],
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(SelahSpacing.radiusSm),
              ),
              child: Icon(
                category.icon,
                color: category.color,
              ),
            ),
          ],
        ),
        title: Text(category.name),
        subtitle: category.isDefault
            ? Text(
                'Predefinida',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              )
            : null,
        trailing: category.canEdit
            ? PopupMenuButton<String>(
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
              )
            : const Icon(Icons.lock_outline, size: 20),
        onTap: onTap,
      ),
    );
  }
}
