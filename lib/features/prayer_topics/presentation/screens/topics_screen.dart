import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/router/selah_routes.dart';
import '../../../categories/domain/entities/category.dart' as cat;
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../domain/entities/prayer_topic.dart';
import '../cubit/topics_cubit.dart';
import '../cubit/topics_state.dart';
import '../widgets/topic_form_dialog.dart';
import '../widgets/topic_list_tile.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  bool _isReorderMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload when navigating back to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  void _loadData() {
    context.read<TopicsCubit>().loadTopics();
    context.read<CategoriesCubit>().loadCategories();
  }

  void _toggleReorderMode() {
    setState(() {
      _isReorderMode = !_isReorderMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isReorderMode ? 'Ordenar Temas' : 'Mis Temas'),
        leading: _isReorderMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleReorderMode,
              )
            : null,
        actions: [
          if (_isReorderMode)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _toggleReorderMode,
              tooltip: 'Listo',
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.swap_vert),
              onPressed: _toggleReorderMode,
              tooltip: 'Ordenar temas',
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterSheet(context),
            ),
          ],
        ],
      ),
      body: BlocConsumer<TopicsCubit, TopicsState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            context.showSnackBar(state.errorMessage!, isError: true);
            context.read<TopicsCubit>().clearError();
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.topics.isEmpty) {
            return SelahEmptyState(
              icon: Icons.bookmark_border,
              title: 'Sin temas aún',
              description: 'Agrega tu primer tema de oración',
              actionLabel: 'Agregar tema',
              onAction: () => _showAddTopicDialog(context),
            );
          }

          return _buildTopicsList(context, state);
        },
      ),
      floatingActionButton: _isReorderMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showAddTopicDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo tema'),
            ),
    );
  }

  Widget _buildTopicsList(BuildContext context, TopicsState state) {
    // When in reorder mode, use all topics (not filtered)
    final topics = _isReorderMode ? state.topics : state.filteredTopics;

    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, categoriesState) {
        if (_isReorderMode) {
          return ReorderableListView.builder(
            padding: const EdgeInsets.only(
              top: SelahSpacing.sm,
              bottom: 80,
            ),
            itemCount: topics.length,
            onReorder: (oldIndex, newIndex) {
              context.read<TopicsCubit>().reorder(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final topic = topics[index];
              final category = topic.categoryId != null
                  ? categoriesState.getCategoryById(topic.categoryId!)
                  : null;

              return _ReorderableTopicTile(
                key: ValueKey(topic.id),
                topic: topic,
                category: category,
              );
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(
            top: SelahSpacing.sm,
            bottom: 80,
          ),
          itemCount: topics.length,
          itemBuilder: (context, index) {
            final topic = topics[index];
            final category = topic.categoryId != null
                ? categoriesState.getCategoryById(topic.categoryId!)
                : null;

            return TopicListTile(
              topic: topic,
              category: category,
              onTap: () => context.go(SelahRoutes.session, extra: [topic.id]),
              onEdit: () => _showEditTopicDialog(context, topic, category),
              onDelete: () => _showDeleteConfirmation(context, topic),
            );
          },
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    final topicsCubit = context.read<TopicsCubit>();
    final categoriesCubit = context.read<CategoriesCubit>();

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: topicsCubit),
            BlocProvider.value(value: categoriesCubit),
          ],
          child: BlocBuilder<CategoriesCubit, CategoriesState>(
            builder: (context, categoriesState) {
              return BlocBuilder<TopicsCubit, TopicsState>(
                builder: (context, topicsState) {
                  return Container(
                    padding: const EdgeInsets.all(SelahSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filtrar por categoría',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: SelahSpacing.md),
                        Wrap(
                          spacing: SelahSpacing.xs,
                          runSpacing: SelahSpacing.xs,
                          children: [
                            FilterChip(
                              label: const Text('Todos'),
                              selected: topicsState.selectedCategoryId == null,
                              onSelected: (_) {
                                context.read<TopicsCubit>().filterByCategory(null);
                                Navigator.pop(context);
                              },
                            ),
                            ...categoriesState.categories.map((category) {
                              return FilterChip(
                                avatar: Icon(
                                  category.icon,
                                  size: 18,
                                  color: category.color,
                                ),
                                label: Text(category.name),
                                selected: topicsState.selectedCategoryId == category.id,
                                onSelected: (_) {
                                  context.read<TopicsCubit>().filterByCategory(category.id);
                                  Navigator.pop(context);
                                },
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: SelahSpacing.lg),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showAddTopicDialog(BuildContext context) {
    showTopicFormDialog(
      context,
      onSave: (title, description, categoryId, iconName) {
        context.read<TopicsCubit>().createTopic(
              title: title,
              description: description,
              categoryId: categoryId,
              iconName: iconName,
            );
      },
    );
  }

  void _showEditTopicDialog(BuildContext context, PrayerTopic topic, cat.Category? category) {
    showTopicFormDialog(
      context,
      topic: topic,
      onSave: (title, description, categoryId, iconName) {
        context.read<TopicsCubit>().editTopic(
              topic.copyWith(
                title: title,
                description: description,
                categoryId: categoryId,
                iconName: iconName,
              ),
            );
      },
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, PrayerTopic topic) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Eliminar tema',
      message: '¿Estás seguro de que deseas eliminar "${topic.title}"?',
      confirmText: 'Eliminar',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<TopicsCubit>().removeTopic(topic.id);
    }
  }
}

class _ReorderableTopicTile extends StatelessWidget {
  final PrayerTopic topic;
  final cat.Category? category;

  const _ReorderableTopicTile({
    super.key,
    required this.topic,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: SelahSpacing.md,
        vertical: SelahSpacing.xs,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: category?.color.withValues(alpha: 0.2) ??
                theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.bookmark,
            color: category?.color ?? theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          topic.title,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: category != null
            ? Text(
                category!.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: category!.color,
                ),
              )
            : null,
        trailing: ReorderableDragStartListener(
          index: 0, // The index is handled by the ReorderableListView
          child: Icon(
            Icons.drag_handle,
            color: isDark ? Colors.white54 : Colors.black38,
          ),
        ),
      ),
    );
  }
}
