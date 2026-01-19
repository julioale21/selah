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
    final color = _getPhaseColor(phase);
    final prompts = _getPrompts(phase);

    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(SelahSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      phase.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SelahSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPhaseTitle(phase),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (topic != null)
                        Text(
                          'Tema: ${topic!.title}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: SelahSpacing.lg),
            Text(
              'Sugerencias:',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: SelahSpacing.sm),
            ...prompts.map((prompt) => Padding(
                  padding: const EdgeInsets.only(bottom: SelahSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: color,
                      ),
                      const SizedBox(width: SelahSpacing.xs),
                      Expanded(
                        child: Text(
                          prompt,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Color _getPhaseColor(SessionPhase phase) {
    switch (phase) {
      case SessionPhase.adoration:
        return SelahColors.adoration;
      case SessionPhase.confession:
        return SelahColors.confession;
      case SessionPhase.thanksgiving:
        return SelahColors.thanksgiving;
      case SessionPhase.supplication:
        return SelahColors.supplication;
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
