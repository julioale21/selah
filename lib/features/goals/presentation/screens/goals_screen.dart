import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../domain/entities/prayer_goal.dart';
import '../cubit/goals_cubit.dart';
import '../cubit/goals_state.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  int? _selectedMinutes;
  int _customMinutes = 30;
  bool _showCustomSlider = false;

  @override
  void initState() {
    super.initState();
    context.read<GoalsCubit>().loadGoals();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GoalsCubit, GoalsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
          context.read<GoalsCubit>().clearError();
        }
      },
      builder: (context, state) {
        // Set initial selection from active goal
        if (_selectedMinutes == null && state.activeGoal != null) {
          _selectedMinutes = state.activeGoal!.targetMinutes;
          if (!PrayerGoal.suggestedDailyMinutes
              .contains(state.activeGoal!.targetMinutes)) {
            _showCustomSlider = true;
            _customMinutes = state.activeGoal!.targetMinutes;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Meta de oración'),
          ),
          body: state.status == GoalsStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(SelahSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(context),
                      const SizedBox(height: SelahSpacing.xl),

                      // Current goal display
                      if (state.activeGoal != null) ...[
                        _buildCurrentGoalCard(context, state),
                        const SizedBox(height: SelahSpacing.xl),
                      ],

                      // Goal selector
                      _buildGoalSelector(context, state),
                      const SizedBox(height: SelahSpacing.xl),

                      // Save button
                      _buildSaveButton(context, state),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meta diaria de oración',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SelahSpacing.sm),
        Text(
          'Establece un objetivo de minutos de oración por día para mantener una disciplina espiritual consistente.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentGoalCard(BuildContext context, GoalsState state) {
    final theme = Theme.of(context);
    final goal = state.activeGoal!;
    final progress = state.dailyProgress;

    return Container(
      padding: const EdgeInsets.all(SelahSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SelahColors.adoration,
            SelahColors.supplication,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flag_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: SelahSpacing.sm),
              Text(
                'Meta actual',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: SelahSpacing.md),
          Text(
            goal.targetDisplayString,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: SelahSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clampedPercentage,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: SelahSpacing.sm),
            Text(
              '${progress.progressString} - ${progress.percentageInt}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalSelector(BuildContext context, GoalsState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona tu meta',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SelahSpacing.md),

        // Predefined options
        Wrap(
          spacing: SelahSpacing.sm,
          runSpacing: SelahSpacing.sm,
          children: PrayerGoal.suggestedDailyMinutes.map((minutes) {
            final isSelected =
                _selectedMinutes == minutes && !_showCustomSlider;
            return ChoiceChip(
              label: Text(_formatMinutes(minutes)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedMinutes = minutes;
                  _showCustomSlider = false;
                });
              },
              selectedColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: SelahSpacing.md),

        // Custom option
        ChoiceChip(
          label: const Text('Personalizado'),
          selected: _showCustomSlider,
          onSelected: (selected) {
            setState(() {
              _showCustomSlider = selected;
              if (selected) {
                _selectedMinutes = _customMinutes;
              }
            });
          },
          selectedColor: theme.colorScheme.primary,
          labelStyle: TextStyle(
            color: _showCustomSlider
                ? Colors.white
                : theme.colorScheme.onSurface,
            fontWeight: _showCustomSlider ? FontWeight.bold : FontWeight.normal,
          ),
        ),

        // Custom slider
        if (_showCustomSlider) ...[
          const SizedBox(height: SelahSpacing.lg),
          Container(
            padding: const EdgeInsets.all(SelahSpacing.lg),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                Text(
                  _formatMinutes(_customMinutes),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: SelahSpacing.md),
                Slider(
                  value: _customMinutes.toDouble(),
                  min: 5,
                  max: 120,
                  divisions: 23,
                  label: _formatMinutes(_customMinutes),
                  onChanged: (value) {
                    setState(() {
                      _customMinutes = value.round();
                      _selectedMinutes = _customMinutes;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '5 min',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      '2 horas',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, GoalsState state) {
    final hasChanges = _selectedMinutes != null &&
        _selectedMinutes != state.activeGoal?.targetMinutes;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: hasChanges && !state.isSaving
            ? () => _saveGoal(context)
            : null,
        icon: state.isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check),
        label: Text(state.isSaving ? 'Guardando...' : 'Guardar meta'),
      ),
    );
  }

  void _saveGoal(BuildContext context) {
    if (_selectedMinutes == null) return;

    context.read<GoalsCubit>().setDailyGoal(_selectedMinutes!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Meta establecida: ${_formatMinutes(_selectedMinutes!)}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '$hours ${hours == 1 ? 'hora' : 'horas'}';
      }
      return '$hours h $mins min';
    }
    return '$minutes min';
  }
}
