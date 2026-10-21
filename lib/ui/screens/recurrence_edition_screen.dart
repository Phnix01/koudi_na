import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/categorie.dart';
import '../../data/models/compte.dart';
import '../../data/models/recurrence.dart';
import '../../data/models/type_mouvement.dart';
import '../../logic/providers/repositories_providers.dart';
import '../widgets/feuille_selection.dart';
import '../../l10n/l10n.dart';

/// Création ou modification d'une transaction récurrente (Phase 4,
/// section 2.3). `recurrence` nul → création ; sinon, édition.
class RecurrenceEditionScreen extends ConsumerStatefulWidget {
  const RecurrenceEditionScreen({super.key, this.recurrence});

  final Recurrence? recurrence;

  @override
  ConsumerState<RecurrenceEditionScreen> createState() =>
      _RecurrenceEditionScreenState();
}

class _RecurrenceEditionScreenState
    extends ConsumerState<RecurrenceEditionScreen> {
  late final _controleurLibelle = TextEditingController(
    text: widget.recurrence?.libelle ?? '',
  );
  late final _controleurMontant = TextEditingController(
    text: '${widget.recurrence?.montant ?? ''}',
  );
  late final _controleurJour = TextEditingController(
    text: '${widget.recurrence?.jourDuMois ?? 1}',
  );
  late TypeMouvement _type = widget.recurrence?.type ?? TypeMouvement.depense;
  late String? _categorieId = widget.recurrence?.categorieId;
  late String? _compteId = widget.recurrence?.compteId;
  late bool _active = widget.recurrence?.active ?? true;

  @override
  void dispose() {
    _controleurLibelle.dispose();
    _controleurMontant.dispose();
    _controleurJour.dispose();
    super.dispose();
  }

  bool get _peutEnregistrer =>
      _controleurLibelle.text.trim().isNotEmpty &&
      (int.tryParse(_controleurMontant.text) ?? 0) > 0 &&
      _categorieId != null &&
      _compteId != null;

  Future<void> _choisirCategorie(List<Categorie> categories) async {
    // Filtrées par type : une récurrence de dépense ne propose que des
    // catégories de dépense, comme à l'écran Capture.
    final categoriesFiltrees = categories
        .where((c) => c.type == _type)
        .toList();
    final choix = await showModalBottomSheet<Categorie>(
      context: context,
      builder: (context) => FeuilleSelection<Categorie>(
        titre: context.l10n.categorie,
        options: categoriesFiltrees,
        libelleDe: (c) => c.libelle,
        estSelectionne: (c) => c.id == _categorieId,
        avecOptionTous: false,
      ),
    );
    if (choix != null) setState(() => _categorieId = choix.id);
  }

  Future<void> _choisirCompte(List<Compte> comptes) async {
    final choix = await showModalBottomSheet<Compte>(
      context: context,
      builder: (context) => FeuilleSelection<Compte>(
        titre: context.l10n.compte,
        options: comptes,
        libelleDe: (c) => c.libelle,
        estSelectionne: (c) => c.id == _compteId,
        avecOptionTous: false,
      ),
    );
    if (choix != null) setState(() => _compteId = choix.id);
  }

  Future<void> _enregistrer() async {
    final recurrence =
        widget.recurrence ??
        Recurrence(
          id: const Uuid().v4(),
          libelle: '',
          type: _type,
          montant: 0,
          categorieId: '',
          compteId: '',
          jourDuMois: 1,
        );
    recurrence
      ..libelle = _controleurLibelle.text.trim()
      ..type = _type
      ..montant = int.tryParse(_controleurMontant.text) ?? 0
      ..categorieId = _categorieId!
      ..compteId = _compteId!
      ..jourDuMois = (int.tryParse(_controleurJour.text) ?? 1).clamp(1, 31)
      ..active = _active;

    await ref.read(recurrenceRepositoryProvider).enregistrer(recurrence);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categorieRepositoryProvider).tous();
    final comptes = ref
        .watch(compteRepositoryProvider)
        .tous()
        .where((c) => c.actif)
        .toList();
    final categorieChoisie = categories
        .where((c) => c.id == _categorieId)
        .firstOrNull;
    final compteChoisi = comptes.where((c) => c.id == _compteId).firstOrNull;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recurrence == null
              ? l10n.nouvelleRecurrence
              : l10n.modifierRecurrence,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _controleurLibelle,
            decoration: InputDecoration(labelText: l10n.libelleExemple),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controleurMontant,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.montantFcfa),
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
              onSelectionChanged: (selection) => setState(() {
                _type = selection.first;
                _categorieId =
                    null; // la liste de catégories change avec le type
              }),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.categorie),
            subtitle: Text(categorieChoisie?.libelle ?? l10n.aChoisir),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _choisirCategorie(categories),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.compte),
            subtitle: Text(compteChoisi?.libelle ?? l10n.aChoisir),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _choisirCompte(comptes),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controleurJour,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.jourDuMois),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.active),
            subtitle: Text(l10n.recurrenceDesactiveeExplication),
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
