import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/l10n.dart';

/// Astuce financière du jour, affichée sur l'écran Analyse juste après
/// `ObservationsAutomatiques`. Teinte (et non bordure seule) + étiquette
/// en capitales : volontairement une identité différente de celle des
/// observations personnalisées, pour qu'on ne les confonde pas même
/// quand les deux cartes s'enchaînent. Toujours affichée (pas de cas
/// vide, à la différence des observations).
class AstuceDuJour extends StatelessWidget {
  const AstuceDuJour({super.key, required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const PhosphorIcon(
              PhosphorIconsFill.lightbulb,
              size: 18,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.astuceDuJourEtiquette.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(texte),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
