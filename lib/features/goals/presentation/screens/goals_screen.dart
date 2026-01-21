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

  @override
  void initState() {
    super.initState();
    context.read<GoalsCubit>().loadGoals();
  }

  void _onTypeSelected(GoalType type, GoalsState state) {
    final existingGoal = state.getActiveGoalByType(type);

    setState(() {
      _selectedType = type;
      _showCustomSlider = false;

      if (existingGoal != null) {
        _selectedMinutes = existingGoal.targetMinutes;
        final suggestedMinutes = PrayerGoal.getSuggestedMinutes(type);
        if (!suggestedMinutes.contains(existingGoal.targetMinutes)) {
          _showCustomSlider = true;
          _customMinutes = existingGoal.targetMinutes;
        }
      } else {
        _selectedMinutes = null;
        _customMinutes = PrayerGoal.getDefaultCustomMinutes(type);
      }
    });
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
        return Scaffold(
          appBar: AppBar(
            title: const Text('Metas de oración'),
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

                      // Active goals summary
                      if (state.hasActiveGoals) ...[
                        _buildActiveGoalsSummary(context, state),
                        const SizedBox(height: SelahSpacing.xl),
                      ],

                      // Goal type selector
                      _buildGoalTypeSelector(context, state),
                      const SizedBox(height: SelahSpacing.lg),

                      // Goal minutes selector
                      _buildGoalSelector(context, state),

                      // Daily equivalent for monthly/annual goals
                      if (_selectedMinutes != null &&
                          (_selectedType == GoalType.monthlyDuration ||
                              _selectedType == GoalType.annualDuration)) ...[
                        const SizedBox(height: SelahSpacing.md),
                        _buildDailyEquivalent(context),
                      ],

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
          'Metas de oración',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SelahSpacing.sm),
        Text(
          'Puedes establecer metas diarias, semanales, mensuales y anuales para mantener una disciplina espiritual consistente.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveGoalsSummary(BuildContext context, GoalsState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tus metas activas',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SelahSpacing.md),
        ...state.allProgress.map((progress) => Padding(
              padding: const EdgeInsets.only(bottom: SelahSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(SelahSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: progress.isCompleted
                        ? SelahColors.thanksgiving.withValues(alpha: 0.5)
                        : isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      progress.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.flag_rounded,
                      color: progress.isCompleted
                          ? SelahColors.thanksgiving
                          : SelahColors.supplication,
                      size: 24,
                    ),
                    const SizedBox(width: SelahSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            progress.goal.typeDisplayName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${progress.progressString} - ${progress.percentageInt}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        width: 60,
                        height: 6,
                        child: LinearProgressIndicator(
                          value: progress.clampedPercentage,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress.isCompleted
                                ? SelahColors.thanksgiving
                                : SelahColors.supplication,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildGoalTypeSelector(BuildContext context, GoalsState state) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configurar meta',
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
                subtitle: 'Por día',
                isSelected: _selectedType == GoalType.dailyDuration,
                hasGoal: state.getActiveGoalByType(GoalType.dailyDuration) != null,
                onTap: () => _onTypeSelected(GoalType.dailyDuration, state),
              ),
            ),
            const SizedBox(width: SelahSpacing.sm),
            Expanded(
              child: _GoalTypeCard(
                icon: Icons.date_range_rounded,
                title: 'Semanal',
                subtitle: 'Por semana',
                isSelected: _selectedType == GoalType.weeklyDuration,
                hasGoal: state.getActiveGoalByType(GoalType.weeklyDuration) != null,
                onTap: () => _onTypeSelected(GoalType.weeklyDuration, state),
              ),
            ),
          ],
        ),
        const SizedBox(height: SelahSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _GoalTypeCard(
                icon: Icons.calendar_month_rounded,
                title: 'Mensual',
                subtitle: 'Por mes',
                isSelected: _selectedType == GoalType.monthlyDuration,
                hasGoal: state.getActiveGoalByType(GoalType.monthlyDuration) != null,
                onTap: () => _onTypeSelected(GoalType.monthlyDuration, state),
              ),
            ),
            const SizedBox(width: SelahSpacing.sm),
            Expanded(
              child: _GoalTypeCard(
                icon: Icons.calendar_today_rounded,
                title: 'Anual',
                subtitle: 'Por año',
                isSelected: _selectedType == GoalType.annualDuration,
                hasGoal: state.getActiveGoalByType(GoalType.annualDuration) != null,
                onTap: () => _onTypeSelected(GoalType.annualDuration, state),
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

    final suggestedMinutes = PrayerGoal.getSuggestedMinutes(_selectedType);
    final (minMinutes, maxMinutes) = PrayerGoal.getMinMaxMinutes(_selectedType);

    String periodLabel;
    switch (_selectedType) {
      case GoalType.dailyDuration:
        periodLabel = 'Minutos por día';
        break;
      case GoalType.weeklyDuration:
        periodLabel = 'Minutos por semana';
        break;
      case GoalType.monthlyDuration:
        periodLabel = 'Horas por mes';
        break;
      case GoalType.annualDuration:
        periodLabel = 'Horas por año';
        break;
    }

    // For monthly and annual goals, slider moves in 1-hour increments
    final bool useHourIncrements = _selectedType == GoalType.monthlyDuration ||
                                    _selectedType == GoalType.annualDuration;
    final int sliderStep = useHourIncrements ? 60 : 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          periodLabel,
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
                  divisions: (maxMinutes - minMinutes) ~/ sliderStep,
                  label: _formatMinutes(_customMinutes),
                  onChanged: (value) {
                    setState(() {
                      // Round to nearest step (hour for monthly/annual)
                      _customMinutes = ((value / sliderStep).round() * sliderStep)
                          .clamp(minMinutes, maxMinutes);
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

  Widget _buildDailyEquivalent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_selectedMinutes == null) return const SizedBox.shrink();

    // Calculate daily equivalent
    final int daysInPeriod =
        _selectedType == GoalType.monthlyDuration ? 30 : 365;
    final double dailyMinutes = _selectedMinutes! / daysInPeriod;

    String dailyText;
    if (dailyMinutes < 1) {
      dailyText = 'menos de 1 min';
    } else if (dailyMinutes < 60) {
      dailyText = '${dailyMinutes.round()} min';
    } else {
      final hours = (dailyMinutes / 60).floor();
      final mins = (dailyMinutes % 60).round();
      if (mins == 0) {
        dailyText = '$hours ${hours == 1 ? 'hora' : 'horas'}';
      } else {
        dailyText = '${hours}h ${mins}min';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SelahSpacing.md,
        vertical: SelahSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? SelahColors.supplication.withValues(alpha: 0.15)
            : SelahColors.supplication.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: SelahColors.supplication,
          ),
          const SizedBox(width: SelahSpacing.xs),
          Text(
            'Equivale a ~$dailyText por día',
            style: theme.textTheme.bodySmall?.copyWith(
              color: SelahColors.supplication,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, GoalsState state) {
    final existingGoal = state.getActiveGoalByType(_selectedType);
    final hasChanges = _selectedMinutes != null &&
        (_selectedMinutes != existingGoal?.targetMinutes);

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
        label: Text(state.isSaving
            ? 'Guardando...'
            : existingGoal != null
                ? 'Actualizar meta'
                : 'Establecer meta'),
      ),
    );
  }

  void _saveGoal(BuildContext context) {
    if (_selectedMinutes == null) return;

    context.read<GoalsCubit>().setGoal(
          type: _selectedType,
          targetMinutes: _selectedMinutes!,
        );

    String typeLabel;
    switch (_selectedType) {
      case GoalType.dailyDuration:
        typeLabel = 'diaria';
        break;
      case GoalType.weeklyDuration:
        typeLabel = 'semanal';
        break;
      case GoalType.monthlyDuration:
        typeLabel = 'mensual';
        break;
      case GoalType.annualDuration:
        typeLabel = 'anual';
        break;
    }

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
  final bool hasGoal;
  final VoidCallback onTap;

  const _GoalTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.hasGoal,
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
            Stack(
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                if (hasGoal)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: SelahColors.thanksgiving,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: SelahSpacing.xs),
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
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
