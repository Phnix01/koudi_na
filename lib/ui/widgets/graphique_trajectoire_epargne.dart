import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../logic/services/trajectoire_epargne.dart';

/// Graphique 6 de la section 5.1 : épargne cumulée sur 12 mois, avec
/// une ligne de repère à l'objectif réglé sur le compte Épargne (même
/// technique que la ligne "Entrées du mois" du graphique Rythme du mois).
class GraphiqueTrajectoireEpargne extends StatelessWidget {
  const GraphiqueTrajectoireEpargne({super.key, required this.trajectoire});

  final TrajectoireEpargne trajectoire;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: LineChart(
        duration: const Duration(milliseconds: 400),
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
                reservedSize: 28,
                getTitlesWidget: _libelleMois,
              ),
            ),
          ),
          extraLinesData: trajectoire.objectif > 0
              ? ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: trajectoire.objectif.toDouble(),
                      color: AppColors.accent,
                      strokeWidth: 1,
                      dashArray: const [6, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 10,
                        ),
                        labelResolver: (_) => 'Objectif',
                      ),
                    ),
                  ],
                )
              : const ExtraLinesData(),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              barWidth: 3,
              color: AppColors.primary,
              dotData: const FlDotData(show: false),
              spots: [
                for (var i = 0; i < trajectoire.points.length; i++)
                  FlSpot(i.toDouble(), trajectoire.points[i].cumul.toDouble()),
              ],
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.25),
                    AppColors.primary.withValues(alpha: 0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _libelleMois(double value, TitleMeta meta) {
    final index = value.round();
    if (index < 0 || index >= trajectoire.points.length) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        DateFormat('MMM', 'fr_FR').format(trajectoire.points[index].mois),
        style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
      ),
    );
  }
}
