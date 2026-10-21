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
import '../../l10n/l10n.dart';

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
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categorie == null
              ? l10n.nouvelleCategorie
              : l10n.modifierCategorie,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _controleurLibelle,
            decoration: InputDecoration(labelText: l10n.libelle),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Center(
            child: SegmentedButton<TypeMouvement>(
              segments: [
                ButtonSegment(
                  value: TypeMouvement.depense,
                  label: Text(context.l10n.depense),
                ),
                ButtonSegment(
                  value: TypeMouvement.entree,
                  label: Text(context.l10n.entree),
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
              l10n.pilierRegle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Center(
              child: SegmentedButton<Pilier?>(
                segments: [
                  for (final pilier in Pilier.values)
                    ButtonSegment(
                      value: pilier,
                      label: Text(l10n.libellePilier(pilier)),
                    ),
                ],
                selected: {_pilier ?? Pilier.vie},
                onSelectionChanged: (selection) =>
                    setState(() => _pilier = selection.first),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(l10n.icone, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          SelecteurIcone(
            iconeSelectionnee: _iconeCode,
            couleur: depuisHex(_couleurHex),
            onChange: (cle) => setState(() => _iconeCode = cle),
          ),
          const SizedBox(height: 20),
          Text(l10n.couleur, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          SelecteurCouleur(
            couleurSelectionnee: _couleurHex,
            onChange: (hex) => setState(() => _couleurHex = hex),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.active),
            subtitle: Text(l10n.categorieDesactiveeExplication),
            value: _active,
            onChanged: (valeur) => setState(() => _active = valeur),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _peutEnregistrer ? _enregistrer : null,
            child: Text(l10n.enregistrer),
          ),
        ],
      ),
    );
  }
}
