import 'package:flutter/material.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../domain/entities/category.dart';

class IconPicker extends StatelessWidget {
  final String? selectedIcon;
  final ValueChanged<String> onIconSelected;

  const IconPicker({
    super.key,
    this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final icons = Category.availableIcons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Seleccionar icono',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: SelahSpacing.sm),
        Wrap(
          spacing: SelahSpacing.xs,
          runSpacing: SelahSpacing.xs,
          children: icons.map((iconName) {
            final isSelected = iconName == selectedIcon;
            final icon = Category.iconMap[iconName] ?? Icons.folder;

            return InkWell(
              onTap: () => onIconSelected(iconName),
              borderRadius: BorderRadius.circular(SelahSpacing.radiusSm),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(SelahSpacing.radiusSm),
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

Future<String?> showIconPickerDialog(
  BuildContext context, {
  String? initialIcon,
}) async {
  return showDialog<String>(
    context: context,
    builder: (context) {
      String? selectedIcon = initialIcon;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Seleccionar icono'),
            content: SizedBox(
              width: double.maxFinite,
              child: IconPicker(
                selectedIcon: selectedIcon,
                onIconSelected: (icon) {
                  setState(() => selectedIcon = icon);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: selectedIcon != null
                    ? () => Navigator.pop(context, selectedIcon)
                    : null,
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    },
  );
}
