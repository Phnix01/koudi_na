import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/icones.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/couleur_utils.dart';
import '../../data/models/categorie.dart';
import '../../data/models/pilier.dart';
import '../../data/models/type_mouvement.dart';
import '../../logic/providers/repositories_providers.dart';
import '../navigation/route_animee.dart';
import 'categorie_edition_screen.dart';

/// Gestion des catégories (section 4, écran D) : création, modification,
/// réordonnancement par glisser-déposer, désactivation.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  TypeMouvement _type = TypeMouvement.depense;

  Future<void> _reordonner(
    List<Categorie> actives,
    int ancienIndex,
    int nouvelIndex,
  ) async {
    // ReorderableListView donne le nouvel index *avant* le retrait de
    // l'élément déplacé : au-delà de son ancienne position, il faut le
    // décrémenter d'un cran pour retomber sur l'index réel d'insertion.
    if (nouvelIndex > ancienIndex) nouvelIndex -= 1;

    final reordonnees = [...actives];
    final deplacee = reordonnees.removeAt(ancienIndex);
    reordonnees.insert(nouvelIndex, deplacee);

    final repo = ref.read(categorieRepositoryProvider);
    for (var i = 0; i < reordonnees.length; i++) {
      if (reordonnees[i].ordre != i) {
        reordonnees[i].ordre = i;
        await repo.enregistrer(reordonnees[i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(categorieRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Catégories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(routeAnimee(CategorieEditionScreen(typeParDefaut: _type))),
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: repo.listenable(),
        builder: (context, _, _) {
          final toutes = repo.tous().where((c) => c.type == _type).toList()
            ..sort((a, b) => a.ordre.compareTo(b.ordre));
          final actives = toutes.where((c) => c.active).toList();
          final desactivees = toutes.where((c) => !c.active).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SegmentedButton<TypeMouvement>(
                  segments: const [
                    ButtonSegment(
                      value: TypeMouvement.depense,
                      label: Text('Dépense'),
                    ),
                    ButtonSegment(
                      value: TypeMouvement.entree,
                      label: Text('Entrée'),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) =>
                      setState(() => _type = selection.first),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ReorderableListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      onReorder: (ancien, nouveau) =>
                          _reordonner(actives, ancien, nouveau),
                      children: [
                        for (final categorie in actives)
                          _LigneCategorie(
                            key: ValueKey(categorie.id),
                            categorie: categorie,
                          ),
                      ],
                    ),
                    if (desactivees.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Text(
                          'Désactivées',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ),
                      for (final categorie in desactivees)
                        _LigneCategorie(
                          key: ValueKey(categorie.id),
                          categorie: categorie,
                        ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LigneCategorie extends ConsumerWidget {
  const _LigneCategorie({required super.key, required this.categorie});

  final Categorie categorie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couleur = depuisHex(categorie.couleurHex);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: couleur.withValues(
          alpha: categorie.active ? 0.18 : 0.08,
        ),
        child: PhosphorIcon(
          icones[categorie.iconeCode] ?? PhosphorIconsFill.question,
          color: couleur,
          size: 20,
        ),
      ),
      title: Text(
        categorie.libelle,
        style: TextStyle(
          color: categorie.active ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
      subtitle: categorie.pilier != null
          ? Text(_libellePilier(categorie.pilier!))
          : null,
      trailing: categorie.active
          ? const Icon(Icons.chevron_right)
          : const Icon(Icons.visibility_off_outlined, size: 18),
      onTap: () => Navigator.of(context).push(
        routeAnimee(
          CategorieEditionScreen(
            categorie: categorie,
            typeParDefaut: categorie.type,
          ),
        ),
      ),
    );
  }

  String _libellePilier(Pilier pilier) {
    switch (pilier) {
      case Pilier.epargne:
        return 'Épargne';
      case Pilier.famille:
        return 'Famille';
      case Pilier.vie:
        return 'Vie';
    }
  }
}
