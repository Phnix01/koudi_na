import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/categorie.dart';
import '../../data/models/compte.dart';
import '../../data/models/type_mouvement.dart';
import 'feuille_selection.dart';

/// Trois puces de filtre rapide (section 4, écran B) : type, catégorie,
/// compte. Chacune ouvre une feuille de sélection à choix unique ;
/// "Tous" en tête de liste efface le filtre correspondant.
class FiltresMois extends StatelessWidget {
  const FiltresMois({
    super.key,
    required this.type,
    required this.categorieSelectionnee,
    required this.compteSelectionne,
    required this.categories,
    required this.comptes,
    required this.onTypeChange,
    required this.onCategorieChange,
    required this.onCompteChange,
  });

  final TypeMouvement? type;
  final Categorie? categorieSelectionnee;
  final Compte? compteSelectionne;
  final List<Categorie> categories;
  final List<Compte> comptes;
  final ValueChanged<TypeMouvement?> onTypeChange;
  final ValueChanged<Categorie?> onCategorieChange;
  final ValueChanged<Compte?> onCompteChange;

  bool get _unFiltreActif =>
      type != null ||
      categorieSelectionnee != null ||
      compteSelectionne != null;

  Future<void> _choisirType(BuildContext context) async {
    final choix = await showModalBottomSheet<TypeMouvement>(
      context: context,
      builder: (context) => FeuilleSelection<TypeMouvement>(
        titre: 'Type',
        options: const [TypeMouvement.depense, TypeMouvement.entree],
        libelleDe: (t) => t == TypeMouvement.depense ? 'Dépense' : 'Entrée',
        estSelectionne: (t) => t == type,
      ),
    );
    onTypeChange(choix);
  }

  Future<void> _choisirCategorie(BuildContext context) async {
    final choix = await showModalBottomSheet<Categorie>(
      context: context,
      builder: (context) => FeuilleSelection<Categorie>(
        titre: 'Catégorie',
        options: categories,
        libelleDe: (c) => c.libelle,
        estSelectionne: (c) => c.id == categorieSelectionnee?.id,
      ),
    );
    onCategorieChange(choix);
  }

  Future<void> _choisirCompte(BuildContext context) async {
    final choix = await showModalBottomSheet<Compte>(
      context: context,
      builder: (context) => FeuilleSelection<Compte>(
        titre: 'Compte',
        options: comptes,
        libelleDe: (c) => c.libelle,
        estSelectionne: (c) => c.id == compteSelectionne?.id,
      ),
    );
    onCompteChange(choix);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _ChipFiltre(
            libelle: type == null
                ? 'Type'
                : (type == TypeMouvement.depense ? 'Dépense' : 'Entrée'),
            actif: type != null,
            onTap: () => _choisirType(context),
          ),
          const SizedBox(width: 8),
          _ChipFiltre(
            libelle: categorieSelectionnee?.libelle ?? 'Catégorie',
            actif: categorieSelectionnee != null,
            onTap: () => _choisirCategorie(context),
          ),
          const SizedBox(width: 8),
          _ChipFiltre(
            libelle: compteSelectionne?.libelle ?? 'Compte',
            actif: compteSelectionne != null,
            onTap: () => _choisirCompte(context),
          ),
          if (_unFiltreActif) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                onTypeChange(null);
                onCategorieChange(null);
                onCompteChange(null);
              },
              child: const Text('Réinitialiser'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChipFiltre extends StatelessWidget {
  const _ChipFiltre({
    required this.libelle,
    required this.actif,
    required this.onTap,
  });

  final String libelle;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(libelle),
      onPressed: onTap,
      backgroundColor: actif
          ? AppColors.primary.withValues(alpha: 0.2)
          : AppColors.surfaceHigh,
      side: BorderSide.none,
      labelStyle: TextStyle(
        color: actif ? AppColors.primary : AppColors.textPrimary,
      ),
    );
  }
}
