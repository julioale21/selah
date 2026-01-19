import 'package:flutter/material.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../domain/entities/category.dart';

class ColorPicker extends StatelessWidget {
  final String? selectedColor;
  final ValueChanged<String> onColorSelected;

  const ColorPicker({
    super.key,
    this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Category.suggestedColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Seleccionar color',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: SelahSpacing.sm),
        Wrap(
          spacing: SelahSpacing.xs,
          runSpacing: SelahSpacing.xs,
          children: colors.map((colorHex) {
            final isSelected = colorHex == selectedColor;
            final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

            return InkWell(
              onTap: () => onColorSelected(colorHex),
              borderRadius: BorderRadius.circular(SelahSpacing.radiusFull),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 3,
                        )
                      : Border.all(
                          color: Colors.transparent,
                          width: 3,
                        ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: _getContrastColor(color),
                        size: 18,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

Future<String?> showColorPickerDialog(
  BuildContext context, {
  String? initialColor,
}) async {
  return showDialog<String>(
    context: context,
    builder: (context) {
      String? selectedColor = initialColor;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Seleccionar color'),
            content: ColorPicker(
              selectedColor: selectedColor,
              onColorSelected: (color) {
                setState(() => selectedColor = color);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: selectedColor != null
                    ? () => Navigator.pop(context, selectedColor)
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
