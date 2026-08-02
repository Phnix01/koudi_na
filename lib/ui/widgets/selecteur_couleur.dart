import 'package:flutter/material.dart';

import '../../core/constants/palette_couleurs.dart';
import '../../core/utils/couleur_utils.dart';

/// Rangée de pastilles de couleur, pour l'édition d'une catégorie ou
/// d'un compte (section 4, écran D).
class SelecteurCouleur extends StatelessWidget {
  const SelecteurCouleur({
    super.key,
    required this.couleurSelectionnee,
    required this.onChange,
  });

  final String couleurSelectionnee;
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: paletteCouleurs.map((hex) {
        final selectionnee = hex == couleurSelectionnee;
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onChange(hex),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: depuisHex(hex),
              shape: BoxShape.circle,
              border: selectionnee
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
            child: selectionnee
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
