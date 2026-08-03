import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../logic/services/habitudes_hebdomadaires.dart';

/// Graphique 5 de la section 5.1 : une grille 7×4 où la couleur de
/// chaque case indique combien on a dépensé ce jour-là, à ce moment de
/// la journée. Aucun widget Flutter standard ne dessine "une grille de
/// rectangles colorés avec des libellés" : on descend donc d'un niveau,
/// sous les widgets, avec un [CustomPainter].
///
/// Un `CustomPainter` reçoit un [Canvas] — la même primitive bas niveau
/// que web `<canvas>` ou Skia — et un [Size] déjà calculé par Flutter.
/// On y dessine directement avec des instructions impératives
/// (`drawRRect`, du texte via [TextPainter]...), au lieu de composer
/// des widgets. C'est le bon outil quand la forme voulue n'existe dans
/// aucune bibliothèque, mais c'est plus bas niveau : pas de `Theme.of`,
/// pas de mise en page automatique, tout se calcule à la main.
class HeatmapHabitudes extends StatelessWidget {
  const HeatmapHabitudes({super.key, required this.grille});

  final GrilleHabitudes grille;

  @override
  Widget build(BuildContext context) {
    if (grille.maxMontant == 0) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'Pas assez de données sur les 90 derniers jours',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    // CustomPaint a besoin de contraintes fermes : sans ce SizedBox
    // explicite, un Canvas sans dimension imposée se réduirait à zéro
    // pixel (aucune erreur, juste invisible).
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: CustomPaint(painter: _PeintreHeatmap(grille: grille)),
    );
  }
}

class _PeintreHeatmap extends CustomPainter {
  _PeintreHeatmap({required this.grille});

  final GrilleHabitudes grille;

  static const _jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  static const _moments = ['Matin', 'Aprèm', 'Soir', 'Nuit'];
  static const _largeurLabelJour = 32.0;
  static const _hauteurLabelMoment = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    final largeurCellule = (size.width - _largeurLabelJour) / _moments.length;
    final hauteurCellule = (size.height - _hauteurLabelMoment) / _jours.length;
    final stylePeinture = Paint();
    const styleLabel = TextStyle(color: AppColors.textMuted, fontSize: 10);

    for (var m = 0; m < _moments.length; m++) {
      _dessinerTexteCentre(
        canvas,
        _moments[m],
        Offset(
          _largeurLabelJour + m * largeurCellule + largeurCellule / 2,
          _hauteurLabelMoment / 2,
        ),
        styleLabel,
      );
    }

    for (var j = 0; j < _jours.length; j++) {
      _dessinerTexteCentre(
        canvas,
        _jours[j],
        Offset(
          _largeurLabelJour / 2,
          _hauteurLabelMoment + j * hauteurCellule + hauteurCellule / 2,
        ),
        styleLabel,
      );

      for (var m = 0; m < _moments.length; m++) {
        final montant = grille.montants[j][m];
        final intensite = montant / grille.maxMontant;
        // Interpole entre "case vide" et "rouge dépense" selon l'intensité :
        // Color.lerp(a, b, t) mélange deux couleurs, t=0 → a, t=1 → b.
        stylePeinture.color = Color.lerp(
          AppColors.surfaceHigh,
          AppColors.negative,
          intensite,
        )!;

        final rect = Rect.fromLTWH(
          _largeurLabelJour + m * largeurCellule + 2,
          _hauteurLabelMoment + j * hauteurCellule + 2,
          largeurCellule - 4,
          hauteurCellule - 4,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          stylePeinture,
        );
      }
    }
  }

  void _dessinerTexteCentre(
    Canvas canvas,
    String texte,
    Offset centre,
    TextStyle style,
  ) {
    final peintreTexte = TextPainter(
      text: TextSpan(text: texte, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    peintreTexte.paint(
      canvas,
      centre - Offset(peintreTexte.width / 2, peintreTexte.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _PeintreHeatmap oldDelegate) {
    // La grille est recalculée à chaque frappe : comparer son contenu
    // case par case coûterait plus cher que redessiner les 28 cases.
    return true;
  }
}
