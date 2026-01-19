import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../../../core/extensions/extensions.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<TopicsCubit>().loadTopics();
    context.read<CategoriesCubit>().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Temas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTopicDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo tema'),
      ),
    );
  }

  Widget _buildTopicsList(BuildContext context, TopicsState state) {
    final topics = state.filteredTopics;

    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, categoriesState) {
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
              onTap: () {
                // TODO: Navigate to topic detail or prayer session
              },
              onEdit: () => _showEditTopicDialog(context, topic, category),
              onDelete: () => _showDeleteConfirmation(context, topic),
            );
          },
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BlocBuilder<CategoriesCubit, CategoriesState>(
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
