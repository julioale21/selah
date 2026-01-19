import 'package:flutter/material.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../../prayer_topics/domain/entities/prayer_topic.dart';
import '../../domain/entities/daily_plan.dart';

class DailyPlanCard extends StatefulWidget {
  final DailyPlan? plan;
  final List<PrayerTopic> suggestedTopics;
  final List<PrayerTopic> allTopics;
  final Function(List<String>) onCreatePlan;
  final VoidCallback onStartPrayer;
  final VoidCallback? onDeletePlan;

  const DailyPlanCard({
    super.key,
    this.plan,
    required this.suggestedTopics,
    required this.allTopics,
    required this.onCreatePlan,
    required this.onStartPrayer,
    this.onDeletePlan,
  });

  @override
  State<DailyPlanCard> createState() => _DailyPlanCardState();
}

class _DailyPlanCardState extends State<DailyPlanCard> {
  final Set<String> _selectedTopicIds = {};

  @override
  void initState() {
    super.initState();
    // Pre-select suggested topics
    for (final topic in widget.suggestedTopics) {
      _selectedTopicIds.add(topic.id);
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
                    plan.isCompleted ? 'Plan completado' : 'Plan del día',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (!plan.isCompleted && widget.onDeletePlan != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: widget.onDeletePlan,
                    color: Theme.of(context).colorScheme.error,
                  ),
              ],
            ),
            const SizedBox(height: SelahSpacing.md),

            // Topics
            Text(
              'Temas:',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: SelahSpacing.xs),
            Wrap(
              spacing: SelahSpacing.xs,
              runSpacing: SelahSpacing.xs,
              children: planTopics.map((topic) => Chip(
                avatar: Icon(
                  IconData(
                    int.tryParse(topic.iconName) ?? Icons.circle.codePoint,
                    fontFamily: 'MaterialIcons',
                  ),
                  size: 18,
                ),
                label: Text(topic.title),
              )).toList(),
            ),

            if (!plan.isCompleted) ...[
              const SizedBox(height: SelahSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onStartPrayer,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar Oración'),
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
                  avatar: Icon(
                    IconData(
                      int.tryParse(topic.iconName) ?? Icons.circle.codePoint,
                      fontFamily: 'MaterialIcons',
                    ),
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
                            avatar: Icon(
                              IconData(
                                int.tryParse(topic.iconName) ?? Icons.circle.codePoint,
                                fontFamily: 'MaterialIcons',
                              ),
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
