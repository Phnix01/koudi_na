import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../logic/providers/repositories_providers.dart';

/// Petite puce « X jours » sous l'en-tête de l'écran de capture.
/// Masquée tant qu'aucune série n'est en cours : pas de "0 jour" qui
/// culpabilise au premier lancement.
class ChipSerie extends ConsumerWidget {
  const ChipSerie({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationRepositoryProvider);

    return ValueListenableBuilder(
      valueListenable: gamification.listenable(),
      builder: (context, _, _) {
        final serie = gamification.serieCourante;
        if (serie == 0) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Chip(
            avatar: const PhosphorIcon(
              PhosphorIconsFill.flame,
              color: AppColors.accent,
              size: 16,
            ),
            label: Text('$serie'),
          ),
        );
      },
    );
  }
}
