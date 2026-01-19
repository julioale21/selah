import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/category.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';
import '../widgets/category_form_dialog.dart';
import '../widgets/category_list_tile.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CategoriesCubit>().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
      ),
      body: BlocConsumer<CategoriesCubit, CategoriesState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            context.showSnackBar(state.errorMessage!, isError: true);
            context.read<CategoriesCubit>().clearError();
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.categories.isEmpty) {
            return const SelahEmptyState(
              icon: Icons.category_outlined,
              title: 'Sin categorías',
              description: 'No hay categorías disponibles',
            );
          }

          return _buildCategoryList(context, state);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva categoría'),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, CategoriesState state) {
    return CustomScrollView(
      slivers: [
        // Default categories section
        if (state.defaultCategories.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                SelahSpacing.md,
                SelahSpacing.md,
                SelahSpacing.md,
                SelahSpacing.sm,
              ),
              child: Text(
                'Categorías predefinidas',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = state.defaultCategories[index];
                return CategoryListTile(
                  category: category,
                );
              },
              childCount: state.defaultCategories.length,
            ),
          ),
        ],

        // Custom categories section
        if (state.customCategories.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                SelahSpacing.md,
                SelahSpacing.lg,
                SelahSpacing.md,
                SelahSpacing.sm,
              ),
              child: Text(
                'Mis categorías',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
          ),
          SliverReorderableList(
            itemBuilder: (context, index) {
              final category = state.customCategories[index];
              return ReorderableDelayedDragStartListener(
                key: ValueKey(category.id),
                index: index,
                child: CategoryListTile(
                  category: category,
                  showDragHandle: true,
                  onEdit: () => _showEditCategoryDialog(context, category),
                  onDelete: () => _showDeleteConfirmation(context, category),
                ),
              );
            },
            itemCount: state.customCategories.length,
            onReorder: (oldIndex, newIndex) {
              // Adjust for default categories offset
              final defaultCount = state.defaultCategories.length;
              context.read<CategoriesCubit>().reorder(
                    oldIndex + defaultCount,
                    newIndex + defaultCount,
                  );
            },
          ),
        ],

        // Bottom padding for FAB
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showCategoryFormDialog(
      context,
      onSave: (name, iconName, colorHex) {
        context.read<CategoriesCubit>().addCategory(
              name: name,
              iconName: iconName,
              colorHex: colorHex,
            );
      },
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    showCategoryFormDialog(
      context,
      category: category,
      onSave: (name, iconName, colorHex) {
        context.read<CategoriesCubit>().editCategory(
              id: category.id,
              name: name,
              iconName: iconName,
              colorHex: colorHex,
            );
      },
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    Category category,
  ) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Eliminar categoría',
      message:
          '¿Estás seguro de que deseas eliminar "${category.name}"?\n\nLos temas de oración asociados quedarán sin categoría.',
      confirmText: 'Eliminar',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<CategoriesCubit>().removeCategory(category.id);
    }
  }
}
