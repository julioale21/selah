import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/router/selah_routes.dart';
import '../../../bible/domain/entities/verse.dart';
import '../../../categories/domain/entities/category.dart' as cat;
import '../../../prayer_topics/domain/entities/prayer_topic.dart';
import '../../../prayer_topics/presentation/cubit/topics_cubit.dart';
import '../../../prayer_topics/presentation/cubit/topics_state.dart';
import '../cubit/prayer_session_cubit.dart';
import '../cubit/prayer_session_state.dart';
import '../cubit/session_timer_cubit.dart';
import '../widgets/acts_phase_indicator.dart';
import '../widgets/focus_mode_view.dart';
import '../widgets/prayer_prompt_card.dart';
import '../widgets/session_timer_widget.dart';

class PrayerSessionScreen extends StatefulWidget {
  const PrayerSessionScreen({super.key});

  @override
  State<PrayerSessionScreen> createState() => _PrayerSessionScreenState();
}

class _PrayerSessionScreenState extends State<PrayerSessionScreen> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TopicsCubit>().loadTopics();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PrayerSessionCubit, PrayerSessionState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          context.showSnackBar(state.errorMessage!, isError: true);
          context.read<PrayerSessionCubit>().clearError();
        }
      },
      builder: (context, state) {
        // Show focus mode view when active
        if (state.isFocusMode && !state.isSetup && !state.isSummary) {
          return FocusModeView(
            state: state,
            onExit: () => context.read<PrayerSessionCubit>().exitFocusMode(),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(state.phaseTitle),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _showExitDialog(context, state),
            ),
            actions: [
              if (!state.isSetup && !state.isSummary) ...[
                // Focus mode button
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  tooltip: 'Modo enfocado',
                  onPressed: () =>
                      context.read<PrayerSessionCubit>().toggleFocusMode(),
                ),
                const SessionTimerWidget(),
              ],
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // ACTS Progress indicator
                if (!state.isSetup && !state.isSummary)
                  ACTSPhaseIndicator(
                    currentPhase: state.phase,
                    onPhaseTap: (phase) {
                      context.read<PrayerSessionCubit>().goToPhase(phase);
                    },
                  ),

                // Main content
                Expanded(
                  child: _buildPhaseContent(context, state),
                ),

                // Navigation buttons
                _buildNavigationBar(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhaseContent(BuildContext context, PrayerSessionState state) {
    switch (state.phase) {
      case SessionPhase.setup:
        return _SetupPhaseContent(
          selectedTopics: state.selectedTopics,
          onToggleTopic: (topic) {
            context.read<PrayerSessionCubit>().toggleTopic(topic);
          },
          isTopicSelected: (topicId) {
            return context.read<PrayerSessionCubit>().isTopicSelected(topicId);
          },
        );
      case SessionPhase.adoration:
      case SessionPhase.confession:
      case SessionPhase.thanksgiving:
      case SessionPhase.supplication:
        return _PrayerPhaseContent(
          state: state,
          noteController: _noteController,
          onNoteSaved: () {
            context.read<PrayerSessionCubit>().saveEntry();
            _noteController.clear();
          },
          onRefreshVerse: () {
            context.read<PrayerSessionCubit>().refreshVerse();
          },
        );
      case SessionPhase.summary:
        return _SummaryPhaseContent(state: state);
    }
  }

  Widget _buildNavigationBar(BuildContext context, PrayerSessionState state) {
    if (state.isSetup) {
      return Padding(
        padding: const EdgeInsets.all(SelahSpacing.md),
        child: SelahButton(
          label: 'Comenzar Oración',
          isFullWidth: true,
          onPressed: state.selectedTopics.isEmpty
              ? null
              : () {
                  context.read<PrayerSessionCubit>().startSession();
                  context.read<SessionTimerCubit>().start();
                },
        ),
      );
    }

    if (state.isSummary) {
      return Padding(
        padding: const EdgeInsets.all(SelahSpacing.md),
        child: SelahButton(
          label: 'Finalizar',
          isFullWidth: true,
          onPressed: () => context.go(SelahRoutes.home),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(SelahSpacing.md),
      child: Row(
        children: [
          if (!state.isAdoration)
            Expanded(
              child: SelahButton(
                label: 'Anterior',
                variant: SelahButtonVariant.secondary,
                onPressed: () {
                  context.read<PrayerSessionCubit>().previousPhase();
                },
              ),
            ),
          if (!state.isAdoration) const SizedBox(width: SelahSpacing.md),
          Expanded(
            child: SelahButton(
              label: state.phase == SessionPhase.supplication
                  ? 'Terminar'
                  : 'Siguiente',
              onPressed: () {
                if (state.phase == SessionPhase.supplication) {
                  final elapsed =
                      context.read<SessionTimerCubit>().state.elapsedSeconds;
                  context.read<PrayerSessionCubit>().finishSession(elapsed);
                  context.read<SessionTimerCubit>().finish();
                } else {
                  context.read<PrayerSessionCubit>().nextPhase();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context, PrayerSessionState state) {
    if (state.isSetup) {
      context.go(SelahRoutes.home);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Salir de la sesión?'),
        content: const Text('Tu progreso no se guardará.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(SelahRoutes.home);
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}

class _SetupPhaseContent extends StatelessWidget {
  final List<PrayerTopic> selectedTopics;
  final Function(PrayerTopic) onToggleTopic;
  final bool Function(String) isTopicSelected;

  const _SetupPhaseContent({
    required this.selectedTopics,
    required this.onToggleTopic,
    required this.isTopicSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicsCubit, TopicsState>(
      builder: (context, topicsState) {
        if (topicsState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (topicsState.topics.isEmpty) {
          return SelahEmptyState(
            icon: Icons.bookmark_border,
            title: 'Sin temas',
            description: 'Crea temas de oración primero para comenzar una sesión',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(SelahSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecciona los temas por los que deseas orar:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: SelahSpacing.xs),
                  Text(
                    '${selectedTopics.length} tema(s) seleccionado(s)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: SelahSpacing.md),
                itemCount: topicsState.topics.length,
                itemBuilder: (context, index) {
                  final topic = topicsState.topics[index];
                  final isSelected = isTopicSelected(topic.id);
                  final iconData =
                      cat.Category.iconMap[topic.iconName] ?? Icons.bookmark;

                  return Card(
                    margin: const EdgeInsets.only(bottom: SelahSpacing.sm),
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: (_) => onToggleTopic(topic),
                      secondary: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.5),
                          borderRadius:
                              BorderRadius.circular(SelahSpacing.radiusSm),
                        ),
                        child: Icon(
                          iconData,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(topic.title),
                      subtitle: topic.description != null
                          ? Text(
                              topic.description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PrayerPhaseContent extends StatelessWidget {
  final PrayerSessionState state;
  final TextEditingController noteController;
  final VoidCallback onNoteSaved;
  final VoidCallback onRefreshVerse;

  const _PrayerPhaseContent({
    required this.state,
    required this.noteController,
    required this.onNoteSaved,
    required this.onRefreshVerse,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SelahSpacing.md),
      child: Column(
        children: [
          // Phase description
          Text(
            state.phaseDescription,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SelahSpacing.md),

          // Verse card for this phase
          if (state.currentVerse != null)
            _SessionVerseCard(
              verse: state.currentVerse!,
              phase: state.phase,
              onRefresh: onRefreshVerse,
            ),
          const SizedBox(height: SelahSpacing.lg),

          // Prayer prompt card
          PrayerPromptCard(
            phase: state.phase,
            topic: state.currentTopic,
          ),
          const SizedBox(height: SelahSpacing.lg),

          // Topic navigator (if multiple topics)
          if (state.selectedTopics.length > 1)
            _TopicNavigator(
              topics: state.selectedTopics,
              currentIndex: state.currentTopicIndex,
              onPrevious: () =>
                  context.read<PrayerSessionCubit>().previousTopic(),
              onNext: () => context.read<PrayerSessionCubit>().nextTopic(),
            ),
          const SizedBox(height: SelahSpacing.lg),

          // Journal entry
          SelahTextField(
            controller: noteController,
            label: 'Notas (opcional)',
            hint: 'Escribe lo que está en tu corazón...',
            maxLines: 4,
            onChanged: (value) {
              context.read<PrayerSessionCubit>().updateNote(value);
            },
          ),
          const SizedBox(height: SelahSpacing.md),

          if (noteController.text.isNotEmpty)
            SelahButton(
              label: 'Guardar nota',
              variant: SelahButtonVariant.secondary,
              icon: Icons.save,
              onPressed: onNoteSaved,
            ),

          // Show saved entries for this phase
          if (state.entries
              .where((e) => e.actsStep == state.phase.name)
              .isNotEmpty) ...[
            const SizedBox(height: SelahSpacing.lg),
            const Divider(),
            const SizedBox(height: SelahSpacing.sm),
            Text(
              'Notas guardadas',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: SelahSpacing.sm),
            ...state.entries
                .where((e) => e.actsStep == state.phase.name)
                .map((entry) => Card(
                      margin: const EdgeInsets.only(bottom: SelahSpacing.xs),
                      child: Padding(
                        padding: const EdgeInsets.all(SelahSpacing.sm),
                        child: Text(entry.content),
                      ),
                    )),
          ],
        ],
      ),
    );
  }
}

class _TopicNavigator extends StatelessWidget {
  final List<PrayerTopic> topics;
  final int currentIndex;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _TopicNavigator({
    required this.topics,
    required this.currentIndex,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topic = topics[currentIndex];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onTap: currentIndex > 0 ? onPrevious : null,
            isDark: isDark,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Orando por',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark ? Colors.white38 : Colors.black38,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  topic.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(topics.length, (i) {
                    return Container(
                      width: i == currentIndex ? 16 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i == currentIndex
                            ? theme.colorScheme.primary
                            : (isDark ? Colors.white12 : Colors.black12),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onTap: currentIndex < topics.length - 1 ? onNext : null,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isEnabled
              ? (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 24,
          color: isEnabled
              ? (isDark ? Colors.white70 : Colors.black54)
              : (isDark ? Colors.white12 : Colors.black12),
        ),
      ),
    );
  }
}

class _SummaryPhaseContent extends StatelessWidget {
  final PrayerSessionState state;

  const _SummaryPhaseContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final duration = Duration(seconds: state.session?.durationSeconds ?? 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SelahSpacing.md),
      child: Column(
        children: [
          // Success icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: SelahColors.success.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: SelahColors.success,
              size: 40,
            ),
          ),
          const SizedBox(height: SelahSpacing.lg),

          Text(
            '¡Sesión completada!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: SelahSpacing.md),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                icon: Icons.timer,
                value:
                    '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                label: 'Duración',
              ),
              _StatItem(
                icon: Icons.topic,
                value: '${state.selectedTopics.length}',
                label: 'Temas',
              ),
              _StatItem(
                icon: Icons.note,
                value: '${state.entries.length}',
                label: 'Notas',
              ),
            ],
          ),

          if (state.entries.isNotEmpty) ...[
            const SizedBox(height: SelahSpacing.xl),
            const Divider(),
            const SizedBox(height: SelahSpacing.md),
            Text(
              'Tus notas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: SelahSpacing.md),
            ...state.entries.map((entry) => Card(
                  margin: const EdgeInsets.only(bottom: SelahSpacing.sm),
                  child: Padding(
                    padding: const EdgeInsets.all(SelahSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SelahSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getPhaseColor(entry.actsStep)
                                .withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(SelahSpacing.radiusSm),
                          ),
                          child: Text(
                            _getPhaseLabel(entry.actsStep),
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: _getPhaseColor(entry.actsStep),
                                    ),
                          ),
                        ),
                        const SizedBox(height: SelahSpacing.xs),
                        Text(entry.content),
                      ],
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Color _getPhaseColor(String? phase) {
    switch (phase) {
      case 'adoration':
        return SelahColors.adoration;
      case 'confession':
        return SelahColors.confession;
      case 'thanksgiving':
        return SelahColors.thanksgiving;
      case 'supplication':
        return SelahColors.supplication;
      default:
        return SelahColors.primary;
    }
  }

  String _getPhaseLabel(String? phase) {
    switch (phase) {
      case 'adoration':
        return 'Adoración';
      case 'confession':
        return 'Confesión';
      case 'thanksgiving':
        return 'Gratitud';
      case 'supplication':
        return 'Súplica';
      default:
        return '';
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _SessionVerseCard extends StatelessWidget {
  final Verse verse;
  final SessionPhase phase;
  final VoidCallback onRefresh;

  const _SessionVerseCard({
    required this.verse,
    required this.phase,
    required this.onRefresh,
  });

  Color _getPhaseColor() {
    switch (phase) {
      case SessionPhase.adoration:
        return const Color(0xFFE8A838); // Warm gold
      case SessionPhase.confession:
        return const Color(0xFF9B7FC7); // Soft purple
      case SessionPhase.thanksgiving:
        return const Color(0xFF5BAE7D); // Fresh green
      case SessionPhase.supplication:
        return const Color(0xFF5B9FD4); // Calm blue
      default:
        return SelahColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final phaseColor = _getPhaseColor();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: phaseColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: phaseColor.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  size: 18,
                  color: phaseColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Versículo para meditar',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: phaseColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onRefresh,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: phaseColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 16,
                      color: phaseColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${verse.textEs}"',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                    color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: phaseColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    verse.displayReference,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: phaseColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
