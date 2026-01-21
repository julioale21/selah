import 'package:flutter/material.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

class GoalCelebrationDialog extends StatefulWidget {
  final int minutesCompleted;
  final int targetMinutes;
  final String? verseText;
  final String? verseReference;

  const GoalCelebrationDialog({
    super.key,
    required this.minutesCompleted,
    required this.targetMinutes,
    this.verseText,
    this.verseReference,
  });

  static Future<void> show(
    BuildContext context, {
    required int minutesCompleted,
    required int targetMinutes,
    String? verseText,
    String? verseReference,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GoalCelebrationDialog(
        minutesCompleted: minutesCompleted,
        targetMinutes: targetMinutes,
        verseText: verseText,
        verseReference: verseReference,
      ),
    );
  }

  @override
  State<GoalCelebrationDialog> createState() => _GoalCelebrationDialogState();
}

class _GoalCelebrationDialogState extends State<GoalCelebrationDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeIn,
    );

    _scaleController.forward();
    _confettiController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: SelahColors.thanksgiving.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Confetti/celebration icons
                _CelebrationHeader(controller: _confettiController),
                const SizedBox(height: 16),

                // Trophy icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        SelahColors.thanksgiving,
                        SelahColors.adoration,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: SelahColors.thanksgiving.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🏆',
                      style: TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Congratulations text
                Text(
                  '¡Meta cumplida!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Oraste ${widget.minutesCompleted} minutos hoy',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),

                // Encouragement message
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: SelahColors.thanksgiving.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getEncouragementMessage(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: SelahColors.thanksgiving,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Bible verse
                if (widget.verseText != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '"${widget.verseText}"',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.white70 : Colors.black54,
                            height: 1.5,
                          ),
                        ),
                        if (widget.verseReference != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.verseReference!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: SelahColors.supplication,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: SelahColors.thanksgiving,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '¡Gloria a Dios!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getEncouragementMessage() {
    final messages = [
      '¡Excelente disciplina espiritual!',
      '¡Tu fidelidad es inspiradora!',
      '¡Dios se agrada de tu dedicación!',
      '¡Sigue buscando Su presencia!',
      '¡Tu constancia da fruto!',
    ];
    return messages[DateTime.now().day % messages.length];
  }
}

class _CelebrationHeader extends StatelessWidget {
  final AnimationController controller;

  const _CelebrationHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final delay = index * 0.15;
              final progress = (controller.value - delay).clamp(0.0, 1.0);
              final yOffset = -20 * Curves.easeOut.transform(progress);
              final opacity = progress > 0.5 ? (1.0 - progress) * 2 : progress * 2;

              return Transform.translate(
                offset: Offset(0, yOffset),
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      _getEmoji(index),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  String _getEmoji(int index) {
    const emojis = ['🎉', '⭐', '✨', '🙏', '🎊'];
    return emojis[index];
  }
}
