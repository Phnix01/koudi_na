import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Astuce financière du jour, affichée sur l'écran Analyse juste après
/// `ObservationsAutomatiques`. Même habillage (carte à bordure accent),
/// mais une icône différente (ampoule plutôt qu'étincelle) pour qu'elle
/// ne se confonde pas avec une observation personnalisée — et, à la
/// différence de celle-ci, toujours affichée (pas de cas vide).
class AstuceDuJour extends StatelessWidget {
  const AstuceDuJour({super.key, required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        side: const BorderSide(color: AppColors.accent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 3),
              child: PhosphorIcon(
                PhosphorIconsFill.lightbulb,
                size: 14,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Expanded(child: Text(texte)),
          ],
        ),
      ),
    );
  }
}
