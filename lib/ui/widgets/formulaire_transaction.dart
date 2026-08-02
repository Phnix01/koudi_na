import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/type_mouvement.dart';
import '../../logic/providers/capture_form_provider.dart';
import 'grille_categories.dart';
import 'note_et_date.dart';
import 'pave_numerique.dart';
import 'selecteur_compte.dart';

/// Corps de formulaire commun aux écrans Capture et Édition (section 4) :
/// type, montant, pavé numérique, catégorie, compte, note et date. Ce
/// widget ne sait pas s'il édite ou crée une transaction — il lit
/// simplement `captureFormProvider`, quelle que soit l'instance que lui
/// fournit le `ProviderScope` le plus proche (celui de l'écran Capture,
/// ou celui, pré-rempli, de l'écran Édition).
class FormulaireTransaction extends ConsumerWidget {
  const FormulaireTransaction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final montant = ref.watch(captureFormProvider.select((form) => form.montant));
    final type = ref.watch(captureFormProvider.select((form) => form.type));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // SegmentedButton plutôt que deux boutons juxtaposés : c'est
          // le widget Material 3 dédié à un choix unique parmi 2 à 4
          // options, avec l'accessibilité intégrée.
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
    );
  }
}
