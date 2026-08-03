import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/couleur_utils.dart';
import '../../logic/services/comparaison_mensuelle.dart';

/// Graphique 3 de la section 5.1 : barres groupées, ce mois contre le
/// mois précédent, catégorie par catégorie. `comparaisons` doit déjà
/// être limité aux catégories à afficher (le Top 5, à l'appelant de
/// tronquer — ce widget se contente de dessiner ce qu'on lui donne).
class GraphiqueComparaison extends StatelessWidget {
  const GraphiqueComparaison({super.key, required this.comparaisons});

  final List<ComparaisonCategorie> comparaisons;

  @override
  Widget build(BuildContext context) {
    if (comparaisons.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'Pas assez de données pour comparer',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    final plusGrandeValeur = comparaisons.fold<int>(0, (max, c) {
      final pic = c.moisCourant > c.moisPrecedent
          ? c.moisCourant
          : c.moisPrecedent;
      return pic > max ? pic : max;
    });

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: plusGrandeValeur == 0 ? 10 : plusGrandeValeur * 1.2,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                const FlLine(color: AppColors.surfaceHigh, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: _libelleCategorie,
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < comparaisons.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: comparaisons[i].moisPrecedent.toDouble(),
                    color: AppColors.textMuted,
                    width: 10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  BarChartRodData(
                    toY: comparaisons[i].moisCourant.toDouble(),
                    color: depuisHex(comparaisons[i].categorie.couleurHex),
                    width: 10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _libelleCategorie(double value, TitleMeta meta) {
    final index = value.round();
    if (index < 0 || index >= comparaisons.length) {
      return const SizedBox.shrink();
    }
    final libelle = comparaisons[index].categorie.libelle;
    final court = libelle.length > 8 ? '${libelle.substring(0, 7)}…' : libelle;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        court,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
      ),
    );
  }
}
