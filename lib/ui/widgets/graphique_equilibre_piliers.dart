import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/couleurs_piliers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/pilier.dart';
import '../../logic/services/equilibre_piliers.dart';

/// Graphique 7 de la section 5.1 : une barre empilée par mois (6 mois),
/// chaque segment représentant un pilier. `rodStackItems` est
/// l'extension naturelle de ce qu'on a appris sur `BarChartRodData` au
/// graphique 3 : au lieu d'une barre pleine, plusieurs segments
/// empilés du bas vers le haut, chacun avec sa propre couleur.
class GraphiqueEquilibrePiliers extends StatelessWidget {
  const GraphiqueEquilibrePiliers({super.key, required this.mois});

  final List<MoisPiliers> mois;

  @override
  Widget build(BuildContext context) {
    if (mois.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'Pas assez de données',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    final maxTotal = mois.fold<int>(0, (max, m) {
      final total = m.epargne + m.famille + m.vie;
      return total > max ? total : max;
    });

    return SizedBox(
      height: 220,
      child: BarChart(
        duration: const Duration(milliseconds: 400),
        BarChartData(
          maxY: maxTotal == 0 ? 10 : maxTotal * 1.1,
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
                reservedSize: 24,
                getTitlesWidget: _libelleMois,
              ),
            ),
          ),
          barGroups: [for (var i = 0; i < mois.length; i++) _groupeDuMois(i)],
        ),
      ),
    );
  }

  BarChartGroupData _groupeDuMois(int index) {
    final donnees = mois[index];
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: (donnees.epargne + donnees.famille + donnees.vie).toDouble(),
          width: 18,
          borderRadius: BorderRadius.circular(4),
          rodStackItems: [
            BarChartRodStackItem(
              0,
              donnees.epargne.toDouble(),
              couleursPiliers[Pilier.epargne]!,
            ),
            BarChartRodStackItem(
              donnees.epargne.toDouble(),
              (donnees.epargne + donnees.famille).toDouble(),
              couleursPiliers[Pilier.famille]!,
            ),
            BarChartRodStackItem(
              (donnees.epargne + donnees.famille).toDouble(),
              (donnees.epargne + donnees.famille + donnees.vie).toDouble(),
              couleursPiliers[Pilier.vie]!,
            ),
          ],
        ),
      ],
    );
  }

  Widget _libelleMois(double value, TitleMeta meta) {
    final index = value.round();
    if (index < 0 || index >= mois.length) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        DateFormat('MMM', 'fr_FR').format(mois[index].mois),
        style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
      ),
    );
  }
}
