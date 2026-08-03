import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../logic/services/rythme_mois.dart';

/// Graphique 4 de la section 5.1 : dépenses cumulées du mois (trait
/// plein), prolongées par une projection en pointillés jusqu'à la fin
/// du mois. Une ligne horizontale marque les entrées du mois, pour
/// visualiser d'un coup d'œil si la projection les dépasse.
class GraphiqueRythme extends StatelessWidget {
  const GraphiqueRythme({super.key, required this.rythme});

  final RythmeMois rythme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: 0,
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
                interval: 5,
                getTitlesWidget: _libelleJour,
              ),
            ),
          ),
          extraLinesData: rythme.entreesMois > 0
              ? ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: rythme.entreesMois.toDouble(),
                      color: AppColors.positive,
                      strokeWidth: 1,
                      dashArray: [6, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: const TextStyle(
                          color: AppColors.positive,
                          fontSize: 10,
                        ),
                        labelResolver: (_) => 'Entrées du mois',
                      ),
                    ),
                  ],
                )
              : const ExtraLinesData(),
          lineBarsData: [
            // Trait plein : ce qui a réellement été dépensé jusqu'à aujourd'hui.
            LineChartBarData(
              isCurved: false,
              barWidth: 3,
              color: AppColors.negative,
              dotData: const FlDotData(show: false),
              spots: [
                for (final point in rythme.reel)
                  FlSpot(point.jour.toDouble(), point.montant.toDouble()),
              ],
            ),
            // Pointillés : extrapolation du même rythme jusqu'à la fin du mois.
            LineChartBarData(
              isCurved: false,
              barWidth: 2,
              color: AppColors.negative.withValues(alpha: 0.5),
              dashArray: const [6, 4],
              dotData: const FlDotData(show: false),
              spots: [
                for (final point in rythme.projection)
                  FlSpot(point.jour.toDouble(), point.montant.toDouble()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _libelleJour(double value, TitleMeta meta) {
    final jour = value.round();
    if (jour != 1 && jour % 5 != 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        '$jour',
        style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
      ),
    );
  }
}
