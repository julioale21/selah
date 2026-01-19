import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/session_timer_cubit.dart';

class SessionTimerWidget extends StatelessWidget {
  const SessionTimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionTimerCubit, SessionTimerState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () => context.read<SessionTimerCubit>().toggle(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  state.isRunning ? Icons.pause : Icons.play_arrow,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  state.formattedTime,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
