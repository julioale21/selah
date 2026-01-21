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
  GoalType _selectedType = GoalType.dailyDuration;
  int? _selectedMinutes;
  int _customMinutes = 30;
  bool _showCustomSlider = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    context.read<GoalsCubit>().loadGoals();
  }

  void _initializeFromState(GoalsState state) {
    if (_initialized || state.activeGoal == null) return;
    _initialized = true;

    _selectedType = state.activeGoal!.type;
    _selectedMinutes = state.activeGoal!.targetMinutes;

    final suggestedMinutes = _selectedType == GoalType.dailyDuration
        ? PrayerGoal.suggestedDailyMinutes
        : PrayerGoal.suggestedWeeklyMinutes;

    if (!suggestedMinutes.contains(state.activeGoal!.targetMinutes)) {
      _showCustomSlider = true;
      _customMinutes = state.activeGoal!.targetMinutes;
    }
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
        _initializeFromState(state);

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

                      // Goal type selector
                      _buildGoalTypeSelector(context),
                      const SizedBox(height: SelahSpacing.lg),

                      // Goal minutes selector
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
          'Meta de oración',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SelahSpacing.sm),
        Text(
          'Establece un objetivo de minutos de oración para mantener una disciplina espiritual consistente.',
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meta actual',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      goal.typeDisplayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
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

  Widget _buildGoalTypeSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de meta',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SelahSpacing.md),
        Row(
          children: [
            Expanded(
              child: _GoalTypeCard(
                icon: Icons.today_rounded,
                title: 'Diaria',
                subtitle: 'Minutos por día',
                isSelected: _selectedType == GoalType.dailyDuration,
                onTap: () {
                  setState(() {
                    _selectedType = GoalType.dailyDuration;
                    _selectedMinutes = null;
                    _showCustomSlider = false;
                    _customMinutes = 30;
                  });
                },
              ),
            ),
            const SizedBox(width: SelahSpacing.md),
            Expanded(
              child: _GoalTypeCard(
                icon: Icons.date_range_rounded,
                title: 'Semanal',
                subtitle: 'Minutos por semana',
                isSelected: _selectedType == GoalType.weeklyDuration,
                onTap: () {
                  setState(() {
                    _selectedType = GoalType.weeklyDuration;
                    _selectedMinutes = null;
                    _showCustomSlider = false;
                    _customMinutes = 120;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalSelector(BuildContext context, GoalsState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isDaily = _selectedType == GoalType.dailyDuration;
    final suggestedMinutes = isDaily
        ? PrayerGoal.suggestedDailyMinutes
        : PrayerGoal.suggestedWeeklyMinutes;
    final maxMinutes = isDaily ? 120 : 420; // 2h daily, 7h weekly
    final minMinutes = isDaily ? 5 : 30;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isDaily ? 'Minutos por día' : 'Minutos por semana',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SelahSpacing.md),

        // Predefined options
        Wrap(
          spacing: SelahSpacing.sm,
          runSpacing: SelahSpacing.sm,
          children: suggestedMinutes.map((minutes) {
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
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
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
            color:
                _showCustomSlider ? Colors.white : theme.colorScheme.onSurface,
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
                  value: _customMinutes.toDouble().clamp(
                        minMinutes.toDouble(),
                        maxMinutes.toDouble(),
                      ),
                  min: minMinutes.toDouble(),
                  max: maxMinutes.toDouble(),
                  divisions: (maxMinutes - minMinutes) ~/ 5,
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
                      _formatMinutes(minMinutes),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      _formatMinutes(maxMinutes),
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
        (_selectedMinutes != state.activeGoal?.targetMinutes ||
            _selectedType != state.activeGoal?.type);

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: hasChanges && !state.isSaving ? () => _saveGoal(context) : null,
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

    context.read<GoalsCubit>().setGoal(
          type: _selectedType,
          targetMinutes: _selectedMinutes!,
        );

    final typeLabel =
        _selectedType == GoalType.dailyDuration ? 'diaria' : 'semanal';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Meta $typeLabel establecida: ${_formatMinutes(_selectedMinutes!)}'),
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

class _GoalTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(SelahSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: SelahSpacing.sm),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
