import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final phases = [
      SessionPhase.adoration,
      SessionPhase.confession,
      SessionPhase.thanksgiving,
      SessionPhase.supplication,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAFAFA),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
          ),
        ),
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
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Phase circle
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isActive ? 42 : 36,
                          height: isActive ? 42 : 36,
                          decoration: BoxDecoration(
                            gradient: (isActive || isPast)
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      color,
                                      color.withValues(alpha: 0.7),
                                    ],
                                  )
                                : null,
                            color: (isActive || isPast) ? null : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
                            shape: BoxShape.circle,
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
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
                                    style: TextStyle(
                                      color: (isActive || isPast)
                                          ? Colors.white
                                          : (isDark ? Colors.white38 : Colors.black38),
                                      fontWeight: FontWeight.bold,
                                      fontSize: isActive ? 16 : 14,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Phase label
                        Text(
                          _getPhaseLabel(phase),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                            color: isActive
                                ? color
                                : (isDark ? Colors.white54 : Colors.black45),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                // Connector line
                if (!isLast)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2,
                    width: 20,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: isPast
                          ? color.withValues(alpha: 0.5)
                          : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(1),
                    ),
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
        return const Color(0xFFE8A838); // Warm gold
      case SessionPhase.confession:
        return const Color(0xFF9B7FC7); // Soft purple
      case SessionPhase.thanksgiving:
        return const Color(0xFF5BAE7D); // Fresh green
      case SessionPhase.supplication:
        return const Color(0xFF5B9FD4); // Calm blue
      default:
        return const Color(0xFF5B9FD4);
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
