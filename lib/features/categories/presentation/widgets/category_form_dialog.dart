import 'package:flutter/material.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../domain/entities/category.dart';
import 'color_picker.dart';
import 'icon_picker.dart';

class CategoryFormDialog extends StatefulWidget {
  final Category? category;
  final Function(String name, String iconName, String colorHex) onSave;

  const CategoryFormDialog({
    super.key,
    this.category,
    required this.onSave,
  });

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  late final TextEditingController _nameController;
  String? _selectedIcon;
  String? _selectedColor;
  final _formKey = GlobalKey<FormState>();

  bool get isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedIcon = widget.category?.iconName ?? Category.availableIcons.first;
    _selectedColor = widget.category?.colorHex ?? Category.suggestedColors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedIcon == null || _selectedColor == null) return;

    widget.onSave(
      _nameController.text.trim(),
      _selectedIcon!,
      _selectedColor!,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Editar categoría' : 'Nueva categoría'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej: Amigos',
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  if (value.trim().length < 2) {
                    return 'El nombre debe tener al menos 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: SelahSpacing.lg),

              // Preview
              Center(
                child: _buildPreview(context),
              ),
              const SizedBox(height: SelahSpacing.lg),

              // Icon picker
              _buildIconSelector(context),
              const SizedBox(height: SelahSpacing.lg),

              // Color picker
              ColorPicker(
                selectedColor: _selectedColor,
                onColorSelected: (color) {
                  setState(() => _selectedColor = color);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _handleSave,
          child: Text(isEditing ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    final color = _selectedColor != null
        ? Color(int.parse(_selectedColor!.replaceFirst('#', '0xFF')))
        : Theme.of(context).colorScheme.primary;
    final icon = _selectedIcon != null
        ? Category.iconMap[_selectedIcon] ?? Icons.folder
        : Icons.folder;

    return Column(
      children: [
        Text(
          'Vista previa',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: SelahSpacing.xs),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
          ),
          child: Icon(
            icon,
            color: color,
            size: 32,
          ),
        ),
      ],
    );
  }

  Widget _buildIconSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icono',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: SelahSpacing.sm),
        InkWell(
          onTap: () async {
            final icon = await showIconPickerDialog(
              context,
              initialIcon: _selectedIcon,
            );
            if (icon != null) {
              setState(() => _selectedIcon = icon);
            }
          },
          borderRadius: BorderRadius.circular(SelahSpacing.radiusSm),
          child: Container(
            padding: const EdgeInsets.all(SelahSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(SelahSpacing.radiusSm),
            ),
            child: Row(
              children: [
                Icon(
                  _selectedIcon != null
                      ? Category.iconMap[_selectedIcon] ?? Icons.folder
                      : Icons.folder,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: SelahSpacing.md),
                Expanded(
                  child: Text(
                    _selectedIcon ?? 'Seleccionar icono',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> showCategoryFormDialog(
  BuildContext context, {
  Category? category,
  required Function(String name, String iconName, String colorHex) onSave,
}) {
  return showDialog(
    context: context,
    builder: (context) => CategoryFormDialog(
      category: category,
      onSave: onSave,
    ),
  );
}
