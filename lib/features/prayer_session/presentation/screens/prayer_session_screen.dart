import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/router/selah_routes.dart';
import '../../../bible/domain/entities/verse.dart';
import '../../../prayer_topics/domain/entities/prayer_topic.dart';
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
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Defer initialization to after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
        context.read<PrayerSessionCubit>().initializeSession();
        context.read<SessionTimerCubit>().start();
      }
    });
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
        // Show loading
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show focus mode view when active
        if (state.isFocusMode && !state.isSummary) {
          return FocusModeView(
            state: state,
            onExit: () => context.read<PrayerSessionCubit>().exitFocusMode(),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_getTitle(state)),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _showExitDialog(context),
            ),
            actions: [
              if (!state.isSummary) ...[
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
                if (!state.isSummary)
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

  String _getTitle(PrayerSessionState state) {
    if (state.isSupplication && state.selectedTopics.isNotEmpty) {
      return '${state.phaseTitle} - ${state.currentTopicIndex + 1}/${state.selectedTopics.length}';
    }
    return state.phaseTitle;
  }

  Widget _buildPhaseContent(BuildContext context, PrayerSessionState state) {
    if (state.isSummary) {
      return _SummaryPhaseContent(state: state);
    }

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
  }

  Widget _buildNavigationBar(BuildContext context, PrayerSessionState state) {
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

    // Determine if we're at the last step
    final isLastTopicInSupplication = state.isSupplication &&
        state.selectedTopics.isNotEmpty &&
        state.currentTopicIndex >= state.selectedTopics.length - 1;

    final isLastPhaseBeforeSupplication =
        state.phase == SessionPhase.thanksgiving;

    final bool isAtEnd = state.isSupplication &&
        (state.selectedTopics.isEmpty || isLastTopicInSupplication);

    // Determine button labels
    String nextLabel;
    if (isAtEnd) {
      nextLabel = 'Amén';
    } else if (isLastPhaseBeforeSupplication && state.selectedTopics.isEmpty) {
      nextLabel = 'Amén';
    } else {
      nextLabel = 'Siguiente';
    }

    return Padding(
      padding: const EdgeInsets.all(SelahSpacing.md),
      child: Row(
        children: [
          // Previous button
          if (!state.isAdoration)
            Expanded(
              child: SelahButton(
                label: 'Anterior',
                variant: SelahButtonVariant.secondary,
                onPressed: () => _handlePrevious(context, state),
              ),
            ),
          if (!state.isAdoration) const SizedBox(width: SelahSpacing.md),

          // Next button
          Expanded(
            child: SelahButton(
              label: nextLabel,
              onPressed: () => _handleNext(context, state),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePrevious(BuildContext context, PrayerSessionState state) {
    if (state.isSupplication && state.currentTopicIndex > 0) {
      // Navigate to previous topic
      context.read<PrayerSessionCubit>().previousTopic();
    } else if (state.isSupplication && state.currentTopicIndex == 0) {
      // Go back to thanksgiving
      context.read<PrayerSessionCubit>().previousPhase();
    } else {
      // Go to previous phase
      context.read<PrayerSessionCubit>().previousPhase();
    }
  }

  void _handleNext(BuildContext context, PrayerSessionState state) {
    if (state.isSupplication) {
      if (state.selectedTopics.isEmpty ||
          state.currentTopicIndex >= state.selectedTopics.length - 1) {
        // Finish session
        final elapsed =
            context.read<SessionTimerCubit>().state.elapsedSeconds;
        context.read<PrayerSessionCubit>().finishSession(elapsed);
        context.read<SessionTimerCubit>().finish();
      } else {
        // Next topic
        context.read<PrayerSessionCubit>().nextTopic();
      }
    } else if (state.phase == SessionPhase.thanksgiving &&
        state.selectedTopics.isEmpty) {
      // No topics, finish session
      final elapsed = context.read<SessionTimerCubit>().state.elapsedSeconds;
      context.read<PrayerSessionCubit>().finishSession(elapsed);
      context.read<SessionTimerCubit>().finish();
    } else {
      // Next phase
      context.read<PrayerSessionCubit>().nextPhase();
    }
  }

  void _showExitDialog(BuildContext context) {
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

          // Show topic card only in Supplication phase
          if (state.isSupplication && state.currentTopic != null)
            _TopicCard(
              topic: state.currentTopic!,
              currentIndex: state.currentTopicIndex,
              totalTopics: state.selectedTopics.length,
            )
          else
            // Prayer prompt card for other phases
            PrayerPromptCard(
              phase: state.phase,
              topic: null,
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

class _TopicCard extends StatelessWidget {
  final PrayerTopic topic;
  final int currentIndex;
  final int totalTopics;

  const _TopicCard({
    required this.topic,
    required this.currentIndex,
    required this.totalTopics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const phaseColor = Color(0xFF5B9FD4); // Supplication color

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  phaseColor.withValues(alpha: 0.2),
                  phaseColor.withValues(alpha: 0.1),
                ]
              : [
                  phaseColor.withValues(alpha: 0.15),
                  phaseColor.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: phaseColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalTopics, (i) {
              return Container(
                width: i == currentIndex ? 20 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: i == currentIndex
                      ? phaseColor
                      : phaseColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Topic info
          Text(
            'Orando por',
            style: theme.textTheme.labelMedium?.copyWith(
              color: phaseColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            topic.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (topic.description != null) ...[
            const SizedBox(height: 8),
            Text(
              topic.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          Text(
            '${currentIndex + 1} de $totalTopics',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
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
        return const Color(0xFFE8A838);
      case SessionPhase.confession:
        return const Color(0xFF9B7FC7);
      case SessionPhase.thanksgiving:
        return const Color(0xFF5BAE7D);
      case SessionPhase.supplication:
        return const Color(0xFF5B9FD4);
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: phaseColor.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  size: 18,
                  color: phaseColor,
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
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
