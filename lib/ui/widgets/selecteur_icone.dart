import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/icones.dart';
import '../../core/theme/app_colors.dart';

/// Grille de sélection d'icône, pour l'édition d'une catégorie ou d'un
/// compte (section 4, écran D). Puise dans [icones], le même registre
/// que celui utilisé pour l'affichage — impossible de choisir une clé
/// qui n'existe pas.
class SelecteurIcone extends StatelessWidget {
  const SelecteurIcone({
    super.key,
    required this.iconeSelectionnee,
    required this.couleur,
    required this.onChange,
  });

  final String iconeSelectionnee;
  final Color couleur;
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: icones.length,
      itemBuilder: (context, index) {
        final cle = icones.keys.elementAt(index);
        final selectionnee = cle == iconeSelectionnee;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChange(cle),
          child: Container(
            decoration: BoxDecoration(
              color: selectionnee ? couleur : AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: PhosphorIcon(
                icones[cle]!,
                color: selectionnee ? AppColors.bg : couleur,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }
}
