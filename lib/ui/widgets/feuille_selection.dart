import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/l10n.dart';

/// Feuille de choix unique générique : ouverte via `showModalBottomSheet`,
/// elle sert à tout endroit où l'utilisateur choisit un élément dans une
/// liste (filtres du Mois, catégorie/compte d'une récurrence...) sans
/// tripler la même mise en page. `estSelectionne` compare par id plutôt
/// que par identité d'objet — indispensable pour Catégorie/Compte, dont
/// deux instances peuvent représenter la même donnée sans être `==`.
class FeuilleSelection<T> extends StatelessWidget {
  const FeuilleSelection({
    super.key,
    required this.titre,
    required this.options,
    required this.libelleDe,
    required this.estSelectionne,
    this.avecOptionTous = true,
  });

  final String titre;
  final List<T> options;
  final String Function(T) libelleDe;
  final bool Function(T) estSelectionne;

  /// Affiche une première ligne "Tous" qui referme la feuille sans rien
  /// choisir (`Navigator.pop()` sans valeur) — utile pour un filtre
  /// optionnel, inutile pour un champ de formulaire obligatoire.
  final bool avecOptionTous;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(titre, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (avecOptionTous)
            ListTile(
              title: Text(context.l10n.tous),
              onTap: () => Navigator.of(context).pop(),
            ),
          ...options.map((option) {
            return ListTile(
              title: Text(libelleDe(option)),
              trailing: estSelectionne(option)
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(option),
            );
          }),
        ],
      ),
    );
  }
}
