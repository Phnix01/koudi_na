import 'package:flutter/material.dart';

import '../../core/constants/badges.dart';

/// Médaille d'un badge. Verrouillée : la même image en niveaux de gris
/// et estompée — on voit la récompense à aller chercher, sans fichier
/// supplémentaire par état.
class MedailleBadge extends StatelessWidget {
  const MedailleBadge({
    super.key,
    required this.badge,
    required this.taille,
    this.debloque = true,
  });

  final BadgeInfo badge;
  final double taille;
  final bool debloque;

  static const _niveauxDeGris = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      badge.image,
      width: taille,
      height: taille,
      filterQuality: FilterQuality.medium,
    );
    if (debloque) return image;
    return Opacity(
      opacity: 0.4,
      child: ColorFiltered(colorFilter: _niveauxDeGris, child: image),
    );
  }
}
