import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../../../core/router/selah_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selah'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(SelahRoutes.settings),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(SelahSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.self_improvement,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: SelahSpacing.lg),
              Text(
                'Bienvenido a Selah',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: SelahSpacing.xs),
              Text(
                'Tu espacio de oración personal',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: SelahSpacing.xxl),
              ElevatedButton.icon(
                onPressed: () => context.push(SelahRoutes.session),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar Oración'),
              ),
              const SizedBox(height: SelahSpacing.md),
              OutlinedButton.icon(
                onPressed: () => context.push(SelahRoutes.planner),
                icon: const Icon(Icons.calendar_today),
                label: const Text('Planificador'),
              ),
              const SizedBox(height: SelahSpacing.md),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: SelahSpacing.sm,
                runSpacing: SelahSpacing.xs,
                children: [
                  TextButton.icon(
                    onPressed: () => context.push(SelahRoutes.topics),
                    icon: const Icon(Icons.list),
                    label: const Text('Temas'),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push(SelahRoutes.verses),
                    icon: const Icon(Icons.menu_book),
                    label: const Text('Versículos'),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push(SelahRoutes.journal),
                    icon: const Icon(Icons.book),
                    label: const Text('Diario'),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push(SelahRoutes.categories),
                    icon: const Icon(Icons.category),
                    label: const Text('Categorías'),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push(SelahRoutes.stats),
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('Estadísticas'),
                  ),
                ],
              ),
              const SizedBox(height: SelahSpacing.xxl),
              // ACTS Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActsChip(
                    label: 'A',
                    color: SelahColors.adoration,
                    tooltip: 'Adoración',
                  ),
                  _ActsChip(
                    label: 'C',
                    color: SelahColors.confession,
                    tooltip: 'Confesión',
                  ),
                  _ActsChip(
                    label: 'T',
                    color: SelahColors.thanksgiving,
                    tooltip: 'Gratitud',
                  ),
                  _ActsChip(
                    label: 'S',
                    color: SelahColors.supplication,
                    tooltip: 'Súplica',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActsChip extends StatelessWidget {
  final String label;
  final Color color;
  final String tooltip;

  const _ActsChip({
    required this.label,
    required this.color,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
