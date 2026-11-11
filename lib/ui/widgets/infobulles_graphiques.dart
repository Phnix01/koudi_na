import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

/// Infobulles communes aux graphiques de l'écran Analyse. Sans elles,
/// fl_chart affiche `y.toString()` : « 125000.0 », sans séparateur ni
/// devise.

const _style = TextStyle(fontWeight: FontWeight.w600, fontSize: 12);
final _rayon = BorderRadius.circular(10);

LineTouchData touchLigneMontants() {
  return LineTouchData(
    touchTooltipData: LineTouchTooltipData(
      getTooltipColor: (_) => AppColors.surfaceHigh,
      tooltipBorderRadius: _rayon,
      fitInsideHorizontally: true,
      fitInsideVertically: true,
      getTooltipItems: (points) {
        final dejaAffiches = <(double, double)>{};
        return [
          for (final point in points)
            // Là où deux courbes se rejoignent (réel puis projection),
            // une seule ligne suffit.
            if (dejaAffiches.add((point.x, point.y)))
              LineTooltipItem(
                formaterMontant(point.y.round()),
                _style.copyWith(color: point.bar.color ?? AppColors.textPrimary),
              )
            else
              null,
        ];
      },
    ),
  );
}

BarTouchData touchBarresMontants() {
  return BarTouchData(
    touchTooltipData: BarTouchTooltipData(
      getTooltipColor: (_) => AppColors.surfaceHigh,
      tooltipBorderRadius: _rayon,
      fitInsideHorizontally: true,
      fitInsideVertically: true,
      getTooltipItem: (_, _, barre, _) => BarTooltipItem(
        formaterMontant(barre.toY.round()),
        _style.copyWith(color: barre.color ?? AppColors.textPrimary),
      ),
    ),
  );
}
