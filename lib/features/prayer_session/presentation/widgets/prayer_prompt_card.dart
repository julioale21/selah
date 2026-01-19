import 'package:flutter/material.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../../prayer_topics/domain/entities/prayer_topic.dart';
import '../cubit/prayer_session_state.dart';

class PrayerPromptCard extends StatelessWidget {
  final SessionPhase phase;
  final PrayerTopic? topic;

  const PrayerPromptCard({
    super.key,
    required this.phase,
    this.topic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = _getPhaseAccentColor(phase);
    final prompts = _getPrompts(phase);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: Row(
              children: [
                // Phase icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor,
                        accentColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      phase.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPhaseTitle(phase),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (topic != null)
                        Text(
                          topic!.title,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Prompts
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sugerencias',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                ...prompts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final prompt = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.6 - (index * 0.1)),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            prompt,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPhaseAccentColor(SessionPhase phase) {
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

  String _getPhaseTitle(SessionPhase phase) {
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

  List<String> _getPrompts(SessionPhase phase) {
    switch (phase) {
      case SessionPhase.adoration:
        return [
          'Alaba a Dios por su amor incondicional',
          'Reconoce su poder y majestad',
          'Agradece por su fidelidad',
          'Medita en sus atributos',
        ];
      case SessionPhase.confession:
        return [
          'Examina tu corazón con humildad',
          'Confiesa pecados específicos',
          'Pide perdón con sinceridad',
          'Recibe su gracia y perdón',
        ];
      case SessionPhase.thanksgiving:
        return [
          'Agradece por las bendiciones recibidas',
          'Reconoce su provisión diaria',
          'Da gracias en todas las circunstancias',
          'Celebra sus respuestas a oraciones',
        ];
      case SessionPhase.supplication:
        return [
          'Presenta tus necesidades personales',
          'Intercede por tu familia',
          'Ora por tu comunidad e iglesia',
          'Pide sabiduría y dirección',
        ];
      default:
        return [];
    }
  }
}
