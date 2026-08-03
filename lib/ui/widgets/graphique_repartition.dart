import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/couleur_utils.dart';
import '../../core/utils/formatters.dart';
import '../../logic/services/repartition_categories.dart';

/// Graphique 2 de la section 5.1 : anneau des dépenses du mois par
/// catégorie, avec le total au centre.
class GraphiqueRepartition extends StatelessWidget {
  const GraphiqueRepartition({super.key, required this.parts});

  final List<PartCategorie> parts;

  int get _total => parts.fold(0, (somme, part) => somme + part.montant);

  @override
  Widget build(BuildContext context) {
    if (parts.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'Aucune dépense ce mois-ci',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                duration: const Duration(milliseconds: 400),
                PieChartData(
                  sections: [
                    for (final part in parts)
                      PieChartSectionData(
                        value: part.montant.toDouble(),
                        color: depuisHex(part.categorie.couleurHex),
                        radius: 34,
                        showTitle: false,
                      ),
                  ],
                  centerSpaceRadius: 55,
                  sectionsSpace: 2,
                ),
              ),
              // Le "trou" au centre (centerSpaceRadius) laisse la place
              // à ce total, superposé par-dessus le graphique via Stack.
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  Text(
                    formaterMontant(_total),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final part in parts) _LigneLegende(part: part),
      ],
    );
  }
}

class _LigneLegende extends StatelessWidget {
  const _LigneLegende({required this.part});

  final PartCategorie part;

  @override
  Widget build(BuildContext context) {
    final couleur = depuisHex(part.categorie.couleurHex);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(part.categorie.libelle)),
          Text(
            '${(part.part * 100).round()} %',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(width: 12),
          Text(formaterMontant(part.montant)),
        ],
      ),
    );
  }
}
