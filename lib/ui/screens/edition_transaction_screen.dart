import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/transaction.dart';
import '../../logic/providers/capture_form_provider.dart';
import '../../logic/providers/repositories_providers.dart';
import '../widgets/formulaire_transaction.dart';

/// Écran d'édition : réutilise [FormulaireTransaction] tel quel, sans y
/// toucher. Le tour de passe-passe est le `ProviderScope` ci-dessous :
/// il redéfinit *localement*, pour ce seul sous-arbre, ce que
/// `captureFormProvider` retourne — un formulaire pré-rempli à partir
/// de la transaction à modifier plutôt que le formulaire vide de
/// l'écran Capture. Tous les widgets enfants (pavé numérique, grille de
/// catégories...) continuent de lire `captureFormProvider` sans savoir
/// qu'ils sont dans un contexte d'édition.
class EditionTransactionScreen extends StatelessWidget {
  const EditionTransactionScreen({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        captureFormProvider.overrideWith(
          (ref) => CaptureFormNotifier.depuisTransaction(transaction),
        ),
      ],
      child: _CorpsEdition(transactionOriginale: transaction),
    );
  }
}

class _CorpsEdition extends ConsumerWidget {
  const _CorpsEdition({required this.transactionOriginale});

  final Transaction transactionOriginale;

  Future<void> _enregistrer(WidgetRef ref, BuildContext context) async {
    final form = ref.read(captureFormProvider);
    final transaction = Transaction(
      id: transactionOriginale.id,
      date: form.date,
      type: form.type,
      montant: form.montant,
      categorieId: form.categorieId!,
      compteId: form.compteId,
      note: form.note.isEmpty ? null : form.note,
    );
    await ref.read(transactionRepositoryProvider).enregistrer(transaction);
    HapticFeedback.lightImpact();
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _supprimer(WidgetRef ref, BuildContext context) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette transaction ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirme != true) return;
    await ref
        .read(transactionRepositoryProvider)
        .supprimer(transactionOriginale.id);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final montant = ref.watch(
      captureFormProvider.select((form) => form.montant),
    );
    final categorieId = ref.watch(
      captureFormProvider.select((form) => form.categorieId),
    );
    final peutEnregistrer = montant > 0 && categorieId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier'),
        actions: [
          IconButton(
            tooltip: 'Supprimer',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _supprimer(ref, context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(child: FormulaireTransaction()),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: ElevatedButton(
                onPressed: peutEnregistrer
                    ? () => _enregistrer(ref, context)
                    : null,
                child: const Text('Enregistrer les modifications'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
