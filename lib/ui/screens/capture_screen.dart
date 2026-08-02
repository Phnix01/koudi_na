import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';
import '../../logic/providers/capture_form_provider.dart';
import '../../logic/providers/repositories_providers.dart';
import '../widgets/grille_categories.dart';
import '../widgets/note_et_date.dart';
import '../widgets/pave_numerique.dart';
import '../widgets/selecteur_compte.dart';
import '../widgets/solde_du_mois.dart';
import 'mois_screen.dart';

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
    await ref.read(transactionRepositoryProvider).ajouter(transaction);
    // Le retour haptique remplace un dialogue de confirmation (section 3.3) :
    // aucune étape supplémentaire ne doit retarder la saisie suivante.
    HapticFeedback.lightImpact();
    ref.read(captureFormProvider.notifier).reinitialiserApresEnregistrement();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final montant = ref.watch(captureFormProvider.select((form) => form.montant));
    final type = ref.watch(captureFormProvider.select((form) => form.type));
    final categorieId = ref.watch(captureFormProvider.select((form) => form.categorieId));
    final peutEnregistrer = montant > 0 && categorieId != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const SizedBox(width: 48), // équilibre visuellement l'IconButton à droite
                  const Expanded(child: SoldeDuMois()),
                  IconButton(
                    tooltip: 'Voir le mois',
                    icon: const PhosphorIcon(PhosphorIconsFill.listBullets),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoisScreen())),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    // SegmentedButton plutôt que deux boutons juxtaposés :
                    // c'est le widget Material 3 dédié à un choix unique
                    // parmi 2 à 4 options, avec l'accessibilité intégrée.
                    Center(
                      child: SegmentedButton<TypeMouvement>(
                        segments: const [
                          ButtonSegment(value: TypeMouvement.depense, label: Text('Dépense')),
                          ButtonSegment(value: TypeMouvement.entree, label: Text('Entrée')),
                        ],
                        selected: {type},
                        onSelectionChanged: (selection) {
                          ref.read(captureFormProvider.notifier).choisirType(selection.first);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(formaterMontant(montant), textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayLarge),
                    const SizedBox(height: 16),
                    const PaveNumerique(),
                    const SizedBox(height: 24),
                    Text('Catégorie', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    const GrilleCategories(),
                    const SizedBox(height: 24),
                    Text('Compte', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    const SelecteurCompte(),
                    const SizedBox(height: 16),
                    const NoteEtDate(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
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
