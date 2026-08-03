import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';

/// Affiche les phrases générées par `genererObservations` (section 5.3),
/// en haut de l'écran Analyse. Ne s'affiche pas du tout si la liste est
/// vide — pas de carte creuse avec un message "rien à observer".
class ObservationsAutomatiques extends StatelessWidget {
  const ObservationsAutomatiques({super.key, required this.observations});

  final List<String> observations;

  @override
  Widget build(BuildContext context) {
    if (observations.isEmpty) return const SizedBox.shrink();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.accent)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final observation in observations)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: PhosphorIcon(PhosphorIconsFill.sparkle, size: 14, color: AppColors.accent),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(observation)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
