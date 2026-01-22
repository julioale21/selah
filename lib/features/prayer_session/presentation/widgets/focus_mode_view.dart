import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../../bible/domain/entities/verse.dart';
import '../../../prayer_topics/domain/entities/prayer_topic.dart';
import '../cubit/prayer_session_cubit.dart';
import '../cubit/prayer_session_state.dart';
import '../cubit/session_timer_cubit.dart';

class FocusModeView extends StatefulWidget {
  final PrayerSessionState state;
  final VoidCallback onExit;

  const FocusModeView({
    super.key,
    required this.state,
    required this.onExit,
  });

  @override
  State<FocusModeView> createState() => _FocusModeViewState();
}

class _FocusModeViewState extends State<FocusModeView> {
  void _showAddNoteDialog(BuildContext context, Color phaseColor) {
    final noteController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            margin: const EdgeInsets.all(SelahSpacing.md),
            padding: const EdgeInsets.all(SelahSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_note,
                      color: phaseColor,
                      size: 24,
                    ),
                    const SizedBox(width: SelahSpacing.sm),
                    Text(
                      'Agregar nota',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                if (widget.state.currentTopic != null) ...[
                  const SizedBox(height: SelahSpacing.xs),
                  Text(
                    'Para: ${widget.state.currentTopic!.title}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                  ),
                ],
                const SizedBox(height: SelahSpacing.md),
                TextField(
                  controller: noteController,
                  autofocus: true,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu nota, reflexión o petición...',
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: phaseColor, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: SelahSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: SelahSpacing.sm),
                    FilledButton.icon(
                      onPressed: () {
                        if (noteController.text.trim().isNotEmpty) {
                          context.read<PrayerSessionCubit>().saveEntryWithContent(
                                noteController.text.trim(),
                              );
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Nota guardada'),
                              backgroundColor: phaseColor,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Guardar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: phaseColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final phaseColor = _getPhaseColor(state.phase);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF0D1117)
        : const Color(0xFFF8F9FA);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtleTextColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Swipe left or right to exit focus mode
          if (details.primaryVelocity != null &&
              details.primaryVelocity!.abs() > 300) {
            widget.onExit();
          }
        },
        child: SafeArea(
          child: Stack(
          children: [
            // Subtle gradient accent
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      phaseColor.withValues(alpha: isDark ? 0.15 : 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Bottom accent
            Positioned(
              bottom: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      phaseColor.withValues(alpha: isDark ? 0.1 : 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main scrollable content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Header with exit button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SelahSpacing.md,
                      vertical: SelahSpacing.sm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Timer small
                        BlocBuilder<SessionTimerCubit, SessionTimerState>(
                          builder: (context, timerState) {
                            return _SmallTimer(
                              elapsedSeconds: timerState.elapsedSeconds,
                              isDark: isDark,
                            );
                          },
                        ),
                        // Action buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Add note button
                            IconButton(
                              icon: Icon(
                                Icons.edit_note,
                                color: phaseColor,
                              ),
                              onPressed: () => _showAddNoteDialog(context, phaseColor),
                              tooltip: 'Agregar nota',
                            ),
                            // Exit button
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: subtleTextColor,
                              ),
                              onPressed: widget.onExit,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: SelahSpacing.xl),

                  // Phase label with elegant styling
                  _PhaseChip(phase: state.phase, color: phaseColor),

                  const SizedBox(height: SelahSpacing.xxl),

                  // Large timer - centered and prominent
                  BlocBuilder<SessionTimerCubit, SessionTimerState>(
                    builder: (context, timerState) {
                      return _LargeTimer(
                        elapsedSeconds: timerState.elapsedSeconds,
                        textColor: textColor,
                      );
                    },
                  ),

                  const SizedBox(height: SelahSpacing.xxl),

                  // Current topic - only show in Supplication phase
                  if (state.isSupplication && state.currentTopic != null)
                    _TopicDisplay(
                      topic: state.currentTopic!,
                      currentIndex: state.currentTopicIndex,
                      totalTopics: state.selectedTopics.length,
                      phaseColor: phaseColor,
                      textColor: textColor,
                      subtleTextColor: subtleTextColor,
                    ),

                  const SizedBox(height: SelahSpacing.xxl),

                  // Verse card
                  if (state.currentVerse != null)
                    _VerseCard(
                      verse: state.currentVerse!,
                      phaseColor: phaseColor,
                      isDark: isDark,
                      onRefresh: () =>
                          context.read<PrayerSessionCubit>().refreshVerse(),
                    ),

                  const SizedBox(height: SelahSpacing.xxl),

                  // Phase dots
                  _PhaseDots(
                    currentPhase: state.phase,
                    onPhaseTap: (phase) {
                      context.read<PrayerSessionCubit>().goToPhase(phase);
                    },
                  ),

                  const SizedBox(height: SelahSpacing.lg),

                  // Navigation
                  _NavigationBar(
                    state: state,
                    phaseColor: phaseColor,
                    isDark: isDark,
                  ),

                  // Extra padding for bottom menu
                  const SizedBox(height: SelahSpacing.xxl + SelahSpacing.xl),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Color _getPhaseColor(SessionPhase phase) {
    switch (phase) {
      case SessionPhase.adoration:
        return const Color(0xFFE8B931); // Warm gold
      case SessionPhase.confession:
        return const Color(0xFFAF7AC5); // Soft purple
      case SessionPhase.thanksgiving:
        return const Color(0xFF58D68D); // Fresh green
      case SessionPhase.supplication:
        return const Color(0xFF5DADE2); // Calm blue
      default:
        return Colors.white;
    }
  }
}

class _SmallTimer extends StatelessWidget {
  final int elapsedSeconds;
  final bool isDark;

  const _SmallTimer({
    required this.elapsedSeconds,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;
    final bgColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.05);
    final iconColor = isDark ? Colors.white54 : Colors.black45;
    final textColor = isDark ? Colors.white70 : Colors.black54;

    final timeString = hours > 0
        ? '${hours.toString()}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SelahSpacing.sm,
        vertical: SelahSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(SelahSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: iconColor, size: 16),
          const SizedBox(width: 4),
          Text(
            timeString,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  final SessionPhase phase;
  final Color color;

  const _PhaseChip({required this.phase, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SelahSpacing.lg,
        vertical: SelahSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        _getPhaseName(phase).toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 3,
        ),
      ),
    );
  }

  String _getPhaseName(SessionPhase phase) {
    switch (phase) {
      case SessionPhase.adoration:
        return 'Adoración';
      case SessionPhase.confession:
        return 'Confesión';
      case SessionPhase.thanksgiving:
        return 'Gratitud';
      case SessionPhase.supplication:
        return 'Súplica';
      default:
        return '';
    }
  }
}

class _LargeTimer extends StatelessWidget {
  final int elapsedSeconds;
  final Color textColor;

  const _LargeTimer({
    required this.elapsedSeconds,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;

    final timeString = hours > 0
        ? '${hours.toString()}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Reduce font size when showing hours
    final fontSize = hours > 0 ? 72.0 : 96.0;

    return Text(
      timeString,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w100,
        color: textColor,
        letterSpacing: -2,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

class _TopicDisplay extends StatelessWidget {
  final PrayerTopic topic;
  final int currentIndex;
  final int totalTopics;
  final Color phaseColor;
  final Color textColor;
  final Color subtleTextColor;

  const _TopicDisplay({
    required this.topic,
    required this.currentIndex,
    required this.totalTopics,
    required this.phaseColor,
    required this.textColor,
    required this.subtleTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Orando por',
          style: TextStyle(
            color: subtleTextColor,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SelahSpacing.lg),
          child: Text(
            topic.title,
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (totalTopics > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${currentIndex + 1} de $totalTopics',
              style: TextStyle(
                color: subtleTextColor.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _VerseCard extends StatelessWidget {
  final Verse verse;
  final Color phaseColor;
  final bool isDark;
  final VoidCallback onRefresh;

  const _VerseCard({
    required this.verse,
    required this.phaseColor,
    required this.isDark,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.03);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);
    final textColor = isDark
        ? Colors.white.withValues(alpha: 0.85)
        : Colors.black.withValues(alpha: 0.8);
    final iconColor = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.3);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: SelahSpacing.lg),
      padding: const EdgeInsets.all(SelahSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote,
                color: phaseColor.withValues(alpha: 0.7),
                size: 20,
              ),
              const Spacer(),
              GestureDetector(
                onTap: onRefresh,
                child: Icon(
                  Icons.refresh,
                  color: iconColor,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            verse.textEs,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            verse.displayReference,
            style: TextStyle(
              color: phaseColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseDots extends StatelessWidget {
  final SessionPhase currentPhase;
  final Function(SessionPhase) onPhaseTap;

  const _PhaseDots({
    required this.currentPhase,
    required this.onPhaseTap,
  });

  @override
  Widget build(BuildContext context) {
    final phases = [
      SessionPhase.adoration,
      SessionPhase.confession,
      SessionPhase.thanksgiving,
      SessionPhase.supplication,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: phases.asMap().entries.map((entry) {
        final index = entry.key;
        final phase = entry.value;
        final isCurrent = phase == currentPhase;
        final color = _getPhaseColor(phase);

        return GestureDetector(
          onTap: () => onPhaseTap(phase),
          child: Container(
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 8,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isCurrent ? 28 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: isCurrent ? color : color.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getPhaseColor(SessionPhase phase) {
    switch (phase) {
      case SessionPhase.adoration:
        return const Color(0xFFE8B931);
      case SessionPhase.confession:
        return const Color(0xFFAF7AC5);
      case SessionPhase.thanksgiving:
        return const Color(0xFF58D68D);
      case SessionPhase.supplication:
        return const Color(0xFF5DADE2);
      default:
        return Colors.white;
    }
  }
}

class _NavigationBar extends StatelessWidget {
  final PrayerSessionState state;
  final Color phaseColor;
  final bool isDark;

  const _NavigationBar({
    required this.state,
    required this.phaseColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PrayerSessionCubit>();
    final timerCubit = context.read<SessionTimerCubit>();
    final buttonColor = isDark ? Colors.white54 : Colors.black54;
    final buttonForeground = isDark ? Colors.black87 : Colors.white;

    // Determine if we're at the end
    final isLastTopicInSupplication = state.isSupplication &&
        state.selectedTopics.isNotEmpty &&
        state.currentTopicIndex >= state.selectedTopics.length - 1;

    final isAtEnd = state.isSupplication &&
        (state.selectedTopics.isEmpty || isLastTopicInSupplication);

    void finishSession() {
      cubit.finishSession(timerCubit.state.elapsedSeconds);
      timerCubit.finish();
      cubit.exitFocusMode();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SelahSpacing.xl),
      child: Row(
        children: [
          // Previous button
          Expanded(
            child: state.isAdoration
                ? const SizedBox()
                : TextButton.icon(
                    onPressed: () => _handlePrevious(context, cubit),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Anterior'),
                    style: TextButton.styleFrom(
                      foregroundColor: buttonColor,
                    ),
                  ),
          ),

          // Amén button - always visible
          FilledButton.icon(
            onPressed: finishSession,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Amén'),
            style: FilledButton.styleFrom(
              backgroundColor: phaseColor,
              foregroundColor: buttonForeground,
              padding: const EdgeInsets.symmetric(
                horizontal: SelahSpacing.lg,
                vertical: SelahSpacing.sm,
              ),
            ),
          ),

          // Next button (when not at end)
          Expanded(
            child: isAtEnd
                ? const SizedBox()
                : TextButton.icon(
                    onPressed: () => _handleNext(context, cubit),
                    icon: const Text('Siguiente'),
                    label: const Icon(Icons.arrow_forward, size: 18),
                    style: TextButton.styleFrom(
                      foregroundColor: buttonColor,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _handlePrevious(BuildContext context, PrayerSessionCubit cubit) {
    if (state.isSupplication && state.currentTopicIndex > 0) {
      // Navigate to previous topic
      cubit.previousTopic();
    } else if (state.isSupplication && state.currentTopicIndex == 0) {
      // Go back to thanksgiving
      cubit.previousPhase();
    } else {
      // Go to previous phase
      cubit.previousPhase();
    }
  }

  void _handleNext(BuildContext context, PrayerSessionCubit cubit) {
    if (state.isSupplication) {
      if (state.currentTopicIndex < state.selectedTopics.length - 1) {
        // Next topic
        cubit.nextTopic();
      }
      // If at last topic, the Amén button handles finishing
    } else {
      // Next phase
      cubit.nextPhase();
    }
  }
}
