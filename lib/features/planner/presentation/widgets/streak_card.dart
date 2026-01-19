import 'package:flutter/material.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../../domain/entities/weekly_streak.dart';

class StreakCard extends StatelessWidget {
  final WeeklyStreak streak;

  const StreakCard({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SelahSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SelahColors.primary,
            SelahColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
      ),
      child: Row(
        children: [
          // Flame icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              streak.hasStreak ? Icons.local_fire_department : Icons.brightness_5,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: SelahSpacing.md),

          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  streak.hasStreak ? '${streak.currentStreak} días' : 'Comienza hoy',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  streak.hasStreak
                      ? 'Racha actual de oración'
                      : 'Inicia tu racha de oración',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Best streak
          Column(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber),
              Text(
                '${streak.longestStreak}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Mejor',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
