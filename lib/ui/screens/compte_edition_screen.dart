import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/couleur_utils.dart';
import '../../data/models/compte.dart';
import '../../logic/providers/repositories_providers.dart';
import '../widgets/selecteur_couleur.dart';
import '../widgets/selecteur_icone.dart';

/// Création ou modification d'un compte, avec solde initial (section 4,
/// écran D). `compte` nul → création ; sinon, édition du compte fourni.
class CompteEditionScreen extends ConsumerStatefulWidget {
  const CompteEditionScreen({super.key, this.compte});

  final Compte? compte;

  @override
  ConsumerState<CompteEditionScreen> createState() =>
      _CompteEditionScreenState();
}

class _CompteEditionScreenState extends ConsumerState<CompteEditionScreen> {
  late final _controleurLibelle = TextEditingController(
    text: widget.compte?.libelle ?? '',
  );
  late final _controleurSolde = TextEditingController(
    text: '${widget.compte?.soldeInitial ?? 0}',
  );
  late TypeCompte _type = widget.compte?.type ?? TypeCompte.especes;
  late String _iconeCode = widget.compte?.iconeCode ?? 'wallet';
  late String _couleurHex = widget.compte?.couleurHex ?? '#00C2A8';
  late bool _actif = widget.compte?.actif ?? true;

  @override
  void dispose() {
    _controleurLibelle.dispose();
    _controleurSolde.dispose();
    super.dispose();
  }

  bool get _peutEnregistrer => _controleurLibelle.text.trim().isNotEmpty;

  Future<void> _enregistrer() async {
    final compte =
        widget.compte ??
        Compte(
          id: const Uuid().v4(),
          libelle: '',
          type: _type,
          iconeCode: _iconeCode,
          couleurHex: _couleurHex,
        );
    compte
      ..libelle = _controleurLibelle.text.trim()
      ..type = _type
      ..iconeCode = _iconeCode
      ..couleurHex = _couleurHex
      ..soldeInitial = int.tryParse(_controleurSolde.text) ?? 0
      ..actif = _actif;

    await ref.read(compteRepositoryProvider).enregistrer(compte);
    if (mounted) Navigator.of(context).pop();
  }

  String _libelleType(TypeCompte type) {
    switch (type) {
      case TypeCompte.especes:
        return 'Espèces';
      case TypeCompte.banque:
        return 'Banque';
      case TypeCompte.mobileMoney:
        return 'Mobile Money';
      case TypeCompte.epargne:
        return 'Épargne';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.compte == null ? 'Nouveau compte' : 'Modifier le compte',
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
          TextField(
            controller: _controleurSolde,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Solde initial (FCFA)',
            ),
          ),
          const SizedBox(height: 20),
          Text('Type', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: TypeCompte.values.map((type) {
              return ChoiceChip(
                label: Text(_libelleType(type)),
                selected: _type == type,
                onSelected: (_) => setState(() => _type = type),
              );
            }).toList(),
          ),
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
            title: const Text('Actif'),
            subtitle: const Text(
              'Un compte désactivé disparaît de la saisie, sans effacer son historique',
            ),
            value: _actif,
            onChanged: (valeur) => setState(() => _actif = valeur),
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
