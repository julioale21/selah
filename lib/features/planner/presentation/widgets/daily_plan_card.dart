import 'package:flutter/material.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../../prayer_topics/domain/entities/prayer_topic.dart';
import '../../domain/entities/daily_plan.dart';

class DailyPlanCard extends StatefulWidget {
  final DailyPlan? plan;
  final List<PrayerTopic> suggestedTopics;
  final List<PrayerTopic> allTopics;
  final Function(List<String>) onCreatePlan;
  final Function(List<String>)? onEditPlan;
  final VoidCallback onStartPrayer;
  final VoidCallback? onDeletePlan;

  const DailyPlanCard({
    super.key,
    this.plan,
    required this.suggestedTopics,
    required this.allTopics,
    required this.onCreatePlan,
    this.onEditPlan,
    required this.onStartPrayer,
    this.onDeletePlan,
  });

  @override
  State<DailyPlanCard> createState() => _DailyPlanCardState();
}

class _DailyPlanCardState extends State<DailyPlanCard> {
  final Set<String> _selectedTopicIds = {};
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeSelectedTopics();
  }

  @override
  void didUpdateWidget(DailyPlanCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan?.id != widget.plan?.id) {
      _isEditing = false;
      _initializeSelectedTopics();
    }
  }

  void _initializeSelectedTopics() {
    _selectedTopicIds.clear();
    if (widget.plan != null) {
      _selectedTopicIds.addAll(widget.plan!.topicIds);
    } else {
      for (final topic in widget.suggestedTopics) {
        _selectedTopicIds.add(topic.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.plan != null) {
      return _buildExistingPlanCard(context);
    }
    return _buildCreatePlanCard(context);
  }

  Widget _buildExistingPlanCard(BuildContext context) {
    final plan = widget.plan!;
    final planTopics = widget.allTopics
        .where((t) => plan.topicIds.contains(t.id))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SelahSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  plan.isCompleted ? Icons.check_circle : Icons.schedule,
                  color: plan.isCompleted ? SelahColors.success : SelahColors.primary,
                ),
                const SizedBox(width: SelahSpacing.sm),
                Expanded(
                  child: Text(
                    _isEditing
                        ? 'Editar plan'
                        : (plan.isCompleted ? 'Plan completado' : 'Plan del día'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (widget.onEditPlan != null && !_isEditing)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => setState(() => _isEditing = true),
                    tooltip: 'Editar plan',
                  ),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _initializeSelectedTopics();
                      });
                    },
                    tooltip: 'Cancelar',
                  ),
                if (widget.onDeletePlan != null && !_isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: widget.onDeletePlan,
                    tooltip: 'Eliminar plan',
                    color: Theme.of(context).colorScheme.error,
                  ),
              ],
            ),
            const SizedBox(height: SelahSpacing.md),

            // Topics - show as chips when viewing, filter chips when editing
            Text(
              'Temas:',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: SelahSpacing.xs),

            if (_isEditing) ...[
              // Editing mode - show all topics as selectable
              Wrap(
                spacing: SelahSpacing.xs,
                runSpacing: SelahSpacing.xs,
                children: widget.allTopics.map((topic) => FilterChip(
                  selected: _selectedTopicIds.contains(topic.id),
                  avatar: const Icon(Icons.bookmark, size: 18),
                  label: Text(topic.title),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTopicIds.add(topic.id);
                      } else {
                        _selectedTopicIds.remove(topic.id);
                      }
                    });
                  },
                )).toList(),
              ),
              const SizedBox(height: SelahSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _initializeSelectedTopics();
                        });
                      },
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: SelahSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedTopicIds.isEmpty
                          ? null
                          : () {
                              widget.onEditPlan?.call(_selectedTopicIds.toList());
                              setState(() => _isEditing = false);
                            },
                      child: Text('Guardar (${_selectedTopicIds.length})'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // View mode - show plan topics as regular chips
              Wrap(
                spacing: SelahSpacing.xs,
                runSpacing: SelahSpacing.xs,
                children: planTopics.map((topic) => Chip(
                  avatar: const Icon(Icons.bookmark, size: 18),
                  label: Text(topic.title),
                )).toList(),
              ),
              const SizedBox(height: SelahSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onStartPrayer,
                  icon: Icon(plan.isCompleted ? Icons.replay : Icons.play_arrow),
                  label: Text(plan.isCompleted ? 'Orar de nuevo' : 'Iniciar Oración'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePlanCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SelahSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.add_task, color: SelahColors.primary),
                const SizedBox(width: SelahSpacing.sm),
                Text(
                  'Crear plan para hoy',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: SelahSpacing.md),

            if (widget.suggestedTopics.isNotEmpty) ...[
              Text(
                'Temas sugeridos:',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: SelahSpacing.xs),
              Wrap(
                spacing: SelahSpacing.xs,
                runSpacing: SelahSpacing.xs,
                children: widget.suggestedTopics.map((topic) => FilterChip(
                  selected: _selectedTopicIds.contains(topic.id),
                  avatar: const Icon(
                    Icons.bookmark,
                    size: 18,
                  ),
                  label: Text(topic.title),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTopicIds.add(topic.id);
                      } else {
                        _selectedTopicIds.remove(topic.id);
                      }
                    });
                  },
                )).toList(),
              ),
              const SizedBox(height: SelahSpacing.md),
            ],

            // All topics (expandable)
            ExpansionTile(
              title: const Text('Más temas'),
              tilePadding: EdgeInsets.zero,
              children: [
                Wrap(
                  spacing: SelahSpacing.xs,
                  runSpacing: SelahSpacing.xs,
                  children: widget.allTopics
                      .where((t) => !widget.suggestedTopics.any((s) => s.id == t.id))
                      .map((topic) => FilterChip(
                            selected: _selectedTopicIds.contains(topic.id),
                            avatar: const Icon(
                              Icons.bookmark,
                              size: 18,
                            ),
                            label: Text(topic.title),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedTopicIds.add(topic.id);
                                } else {
                                  _selectedTopicIds.remove(topic.id);
                                }
                              });
                            },
                          ))
                      .toList(),
                ),
              ],
            ),

            const SizedBox(height: SelahSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedTopicIds.isEmpty
                    ? null
                    : () => widget.onCreatePlan(_selectedTopicIds.toList()),
                child: Text('Crear Plan (${_selectedTopicIds.length} temas)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
