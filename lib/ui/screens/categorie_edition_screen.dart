import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/couleur_utils.dart';
import '../../data/models/categorie.dart';
import '../../data/models/pilier.dart';
import '../../data/models/type_mouvement.dart';
import '../../logic/providers/repositories_providers.dart';
import '../widgets/selecteur_couleur.dart';
import '../widgets/selecteur_icone.dart';

/// Création ou modification d'une catégorie (section 4, écran D).
/// `categorie` nul → création ; sinon, édition de la catégorie fournie.
class CategorieEditionScreen extends ConsumerStatefulWidget {
  const CategorieEditionScreen({
    super.key,
    this.categorie,
    required this.typeParDefaut,
  });

  final Categorie? categorie;
  final TypeMouvement typeParDefaut;

  @override
  ConsumerState<CategorieEditionScreen> createState() =>
      _CategorieEditionScreenState();
}

class _CategorieEditionScreenState
    extends ConsumerState<CategorieEditionScreen> {
  late final _controleurLibelle = TextEditingController(
    text: widget.categorie?.libelle ?? '',
  );
  late TypeMouvement _type = widget.categorie?.type ?? widget.typeParDefaut;
  late String _iconeCode = widget.categorie?.iconeCode ?? 'dotsThreeOutline';
  late String _couleurHex = widget.categorie?.couleurHex ?? '#00C2A8';
  late Pilier? _pilier = widget.categorie?.pilier;
  late bool _active = widget.categorie?.active ?? true;

  @override
  void dispose() {
    _controleurLibelle.dispose();
    super.dispose();
  }

  bool get _peutEnregistrer => _controleurLibelle.text.trim().isNotEmpty;

  Future<void> _enregistrer() async {
    final categorie =
        widget.categorie ??
        Categorie(
          id: const Uuid().v4(),
          libelle: '',
          type: _type,
          iconeCode: _iconeCode,
          couleurHex: _couleurHex,
        );
    categorie
      ..libelle = _controleurLibelle.text.trim()
      ..type = _type
      ..iconeCode = _iconeCode
      ..couleurHex = _couleurHex
      ..pilier = _type == TypeMouvement.depense ? _pilier : null
      ..active = _active;

    await ref.read(categorieRepositoryProvider).enregistrer(categorie);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categorie == null
              ? 'Nouvelle catégorie'
              : 'Modifier la catégorie',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _controleurLibelle,
            decoration: const InputDecoration(labelText: 'Libellé'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Center(
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
          if (_type == TypeMouvement.depense) ...[
            const SizedBox(height: 20),
            Text(
              'Pilier (règle 40/25/35)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Center(
              child: SegmentedButton<Pilier?>(
                segments: const [
                  ButtonSegment(value: Pilier.epargne, label: Text('Épargne')),
                  ButtonSegment(value: Pilier.famille, label: Text('Famille')),
                  ButtonSegment(value: Pilier.vie, label: Text('Vie')),
                ],
                selected: {_pilier ?? Pilier.vie},
                onSelectionChanged: (selection) =>
                    setState(() => _pilier = selection.first),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text('Icône', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          SelecteurIcone(
            iconeSelectionnee: _iconeCode,
            couleur: depuisHex(_couleurHex),
            onChange: (cle) => setState(() => _iconeCode = cle),
          ),
          const SizedBox(height: 20),
          Text('Couleur', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          SelecteurCouleur(
            couleurSelectionnee: _couleurHex,
            onChange: (hex) => setState(() => _couleurHex = hex),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Active'),
            subtitle: const Text(
              'Une catégorie désactivée disparaît de la saisie, sans effacer son historique',
            ),
            value: _active,
            onChanged: (valeur) => setState(() => _active = valeur),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _peutEnregistrer ? _enregistrer : null,
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
