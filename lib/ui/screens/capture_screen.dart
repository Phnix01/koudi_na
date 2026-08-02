import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/transaction.dart';
import '../../logic/providers/capture_form_provider.dart';
import '../../logic/providers/repositories_providers.dart';
import '../widgets/formulaire_transaction.dart';
import '../widgets/solde_du_mois.dart';
import 'mois_screen.dart';
import 'reglages_screen.dart';

/// Écran A du cahier des charges : la capture, cœur de l'application.
/// Parcours cible (section 4) : ouvrir → taper le montant → taper la
/// catégorie → enregistré, trois gestes, moins de 10 secondes.
class CaptureScreen extends ConsumerWidget {
  const CaptureScreen({super.key});

  Future<void> _enregistrer(WidgetRef ref) async {
    final form = ref.read(captureFormProvider);
    final transaction = Transaction(
      id: const Uuid().v4(),
      date: form.date,
      type: form.type,
      montant: form.montant,
      categorieId: form.categorieId!,
      compteId: form.compteId,
      note: form.note.isEmpty ? null : form.note,
    );
    await ref.read(transactionRepositoryProvider).enregistrer(transaction);
    // Le retour haptique remplace un dialogue de confirmation (section 3.3) :
    // aucune étape supplémentaire ne doit retarder la saisie suivante.
    HapticFeedback.lightImpact();
    ref.read(captureFormProvider.notifier).reinitialiserApresEnregistrement();
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 96,
                  ), // équilibre visuellement les deux IconButton à droite
                  const Expanded(child: SoldeDuMois()),
                  IconButton(
                    tooltip: 'Voir le mois',
                    icon: const PhosphorIcon(PhosphorIconsFill.listBullets),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MoisScreen()),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Réglages',
                    icon: const PhosphorIcon(PhosphorIconsFill.gearSix),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ReglagesScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(child: FormulaireTransaction()),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: ElevatedButton(
                onPressed: peutEnregistrer ? () => _enregistrer(ref) : null,
                child: const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
