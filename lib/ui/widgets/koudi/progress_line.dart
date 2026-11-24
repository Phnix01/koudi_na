import 'package:flutter/material.dart';

import '../../../core/theme/koudi_tokens.dart';

/// Rail de progression plein (brief §3.4), 4 ou 8 px, avec un marqueur
/// vertical optionnel (la position du jour dans le mois, barre de rythme).
/// Le remplissage s'anime quand la valeur change.
class ProgressLine extends StatelessWidget {
  const ProgressLine({
    super.key,
    required this.valeur,
    required this.couleur,
    this.hauteur = 4,
    this.marqueur,
    this.couleurMarqueur,
    this.couleurRail,
  });

  /// Entre 0 et 1 (bornée à l'affichage).
  final double valeur;
  final Color couleur;
  final double hauteur;
  final double? marqueur;
  final Color? couleurMarqueur;
  final Color? couleurRail;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final rayon = BorderRadius.circular(hauteur / 2);
    return LayoutBuilder(
      builder: (context, c) {
        final largeur = c.maxWidth;
        return SizedBox(
          height: marqueur == null ? hauteur : hauteur + 10,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: hauteur,
                decoration: BoxDecoration(color: couleurRail ?? t.track, borderRadius: rayon),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(end: valeur.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => Container(
                  width: largeur * v,
                  height: hauteur,
                  decoration: BoxDecoration(color: couleur, borderRadius: rayon),
                ),
              ),
              if (marqueur != null)
                Positioned(
                  left: (largeur * marqueur!.clamp(0.0, 1.0) - 1).clamp(0.0, largeur - 2),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      color: couleurMarqueur ?? t.positive,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
