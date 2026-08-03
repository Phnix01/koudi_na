import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../logic/services/evolution_mensuelle.dart';

/// Graphique 1 de la section 5.1 : double courbe entrées/dépenses sur
/// 12 mois, avec zone remplie en dégradé sous chaque courbe.
class GraphiqueEvolutionMensuelle extends StatelessWidget {
  const GraphiqueEvolutionMensuelle({super.key, required this.points});

  final List<PointMensuel> points;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: LineChart(
        duration: const Duration(milliseconds: 400),
        LineChartData(
          minY: 0,
          lineTouchData: const LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: _couleurInfobulle,
            ),
          ),
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
          lineBarsData: [
            _courbe(
              couleur: AppColors.positive,
              valeurs: points.map((p) => p.entrees).toList(),
            ),
            _courbe(
              couleur: AppColors.negative,
              valeurs: points.map((p) => p.depenses).toList(),
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _courbe({
    required Color couleur,
    required List<int> valeurs,
  }) {
    return LineChartBarData(
      isCurved: true,
      barWidth: 3,
      color: couleur,
      dotData: const FlDotData(show: false),
      spots: [
        for (var i = 0; i < valeurs.length; i++)
          FlSpot(i.toDouble(), valeurs[i].toDouble()),
      ],
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            couleur.withValues(alpha: 0.25),
            couleur.withValues(alpha: 0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _libelleMois(double value, TitleMeta meta) {
    final index = value.round();
    if (index < 0 || index >= points.length) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        DateFormat('MMM', 'fr_FR').format(points[index].mois),
        style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
      ),
    );
  }

  static Color _couleurInfobulle(LineBarSpot spot) => AppColors.surfaceHigh;
}
