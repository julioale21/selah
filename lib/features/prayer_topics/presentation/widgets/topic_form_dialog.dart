import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../../categories/domain/entities/category.dart' as cat;
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../../categories/presentation/widgets/icon_picker.dart';
import '../../domain/entities/prayer_topic.dart';

class TopicFormDialog extends StatefulWidget {
  final PrayerTopic? topic;
  final Function(String title, String? description, String? categoryId, String iconName) onSave;

  const TopicFormDialog({
    super.key,
    this.topic,
    required this.onSave,
  });

  @override
  State<TopicFormDialog> createState() => _TopicFormDialogState();
}

class _TopicFormDialogState extends State<TopicFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  String? _selectedCategoryId;
  String? _selectedIcon;
  final _formKey = GlobalKey<FormState>();

  bool get isEditing => widget.topic != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.topic?.title ?? '');
    _descriptionController = TextEditingController(text: widget.topic?.description ?? '');
    _selectedCategoryId = widget.topic?.categoryId;
    _selectedIcon = widget.topic?.iconName ?? 'bookmark';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() != true) return;

    widget.onSave(
      _titleController.text.trim(),
      _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      _selectedCategoryId,
      _selectedIcon ?? 'bookmark',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Editar tema' : 'Nuevo tema de oración'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ej: Mi familia',
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El título es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: SelahSpacing.md),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  hintText: 'Ej: Orar por la salud y unidad familiar',
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
              ),
              const SizedBox(height: SelahSpacing.lg),

              // Category selector
              _buildCategorySelector(context),
              const SizedBox(height: SelahSpacing.lg),

              // Icon selector
              _buildIconSelector(context),
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

  Widget _buildCategorySelector(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        final categories = state.categories;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categoría',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: SelahSpacing.sm),
            Wrap(
              spacing: SelahSpacing.xs,
              runSpacing: SelahSpacing.xs,
              children: [
                // No category option
                ChoiceChip(
                  label: const Text('Sin categoría'),
                  selected: _selectedCategoryId == null,
                  onSelected: (_) {
                    setState(() => _selectedCategoryId = null);
                  },
                ),
                // Category chips
                ...categories.map((category) {
                  final isSelected = _selectedCategoryId == category.id;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category.icon,
                          size: 16,
                          color: isSelected ? null : category.color,
                        ),
                        const SizedBox(width: 4),
                        Text(category.name),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategoryId = category.id);
                    },
                  );
                }),
              ],
            ),
          ],
        );
      },
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
                  cat.Category.iconMap[_selectedIcon] ?? Icons.bookmark,
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

Future<void> showTopicFormDialog(
  BuildContext context, {
  PrayerTopic? topic,
  required Function(String title, String? description, String? categoryId, String iconName) onSave,
}) {
  final categoriesCubit = context.read<CategoriesCubit>();

  return showDialog(
    context: context,
    builder: (dialogContext) => BlocProvider.value(
      value: categoriesCubit,
      child: TopicFormDialog(
        topic: topic,
        onSave: onSave,
      ),
    ),
  );
}
