import 'package:flutter/material.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../cubit/prayer_session_state.dart';

class ACTSPhaseIndicator extends StatelessWidget {
  final SessionPhase currentPhase;
  final Function(SessionPhase) onPhaseTap;

  const ACTSPhaseIndicator({
    super.key,
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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: phases.asMap().entries.map((entry) {
          final index = entry.key;
          final phase = entry.value;
          final isActive = phase == currentPhase;
          final isPast = phases.indexOf(phase) < phases.indexOf(currentPhase);
          final color = _getPhaseColor(phase);
          final isLast = index == phases.length - 1;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onPhaseTap(phase),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isActive || isPast
                                ? color
                                : color.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                            border: isActive
                                ? Border.all(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: isPast
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : Text(
                                    phase.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getPhaseLabel(phase),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            color: isActive
                                ? color
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    height: 2,
                    width: 16,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: isPast
                        ? color
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
              ],
            ),
          );
        }).toList(),
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

  String _getPhaseLabel(SessionPhase phase) {
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
