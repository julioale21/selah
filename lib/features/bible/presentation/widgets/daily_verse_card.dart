import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';

import '../cubit/verses_cubit.dart';
import '../cubit/verses_state.dart';
import 'verse_card.dart';

class DailyVerseCard extends StatelessWidget {
  const DailyVerseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VersesCubit, VersesState>(
      buildWhen: (prev, curr) => prev.dailyVerse != curr.dailyVerse,
      builder: (context, state) {
        if (state.dailyVerse == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.wb_sunny,
                  color: SelahColors.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Versículo del día',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: SelahColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: SelahSpacing.sm),
            VerseCard(
              verse: state.dailyVerse!,
              onFavorite: () {
                context.read<VersesCubit>().toggleFavorite(state.dailyVerse!.id);
              },
              showCategory: false,
            ),
          ],
        );
      },
    );
  }
}
