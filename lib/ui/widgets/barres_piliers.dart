import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../logic/services/calcul_piliers.dart';
import '../../l10n/l10n.dart';

/// Les trois barres de la règle 40/25/35 (section 4, écran B) : réel
/// contre cible pour chaque pilier, vert si respecté, orange si proche,
/// rouge si dépassé.
class BarresPiliers extends StatelessWidget {
  const BarresPiliers({super.key, required this.progressions});

  final List<ProgressionPilier> progressions;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.regle402535,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (final progression in progressions) ...[
              _BarrePilier(progression: progression),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _BarrePilier extends StatelessWidget {
  const _BarrePilier({required this.progression});

  final ProgressionPilier progression;

  Color get _couleur {
    if (progression.progression > 1.0) return AppColors.negative;
    if (progression.progression >= 0.8) return AppColors.avertissement;
    return AppColors.positive;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.libellePilier(progression.pilier),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${formaterMontant(progression.montantReel)} / ${formaterMontant(progression.objectifMontant)}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progression.progression.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.surfaceHigh,
            color: _couleur,
          ),
        ),
      ],
    );
  }
}
