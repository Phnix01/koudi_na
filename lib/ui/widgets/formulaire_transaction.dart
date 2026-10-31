import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/type_mouvement.dart';
import '../../logic/providers/capture_form_provider.dart';
import '../../l10n/l10n.dart';
import 'grille_categories.dart';
import 'note_et_date.dart';
import 'pave_numerique.dart';
import 'segmented_toggle.dart';
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
    final montant = ref.watch(
      captureFormProvider.select((form) => form.montant),
    );
    final type = ref.watch(captureFormProvider.select((form) => form.type));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 240,
              child: SegmentedToggle<TypeMouvement>(
                options: [
                  SegmentedToggleOption(
                    valeur: TypeMouvement.depense,
                    label: context.l10n.depense,
                  ),
                  SegmentedToggleOption(
                    valeur: TypeMouvement.entree,
                    label: context.l10n.entree,
                  ),
                ],
                selectionne: type,
                onChanged: (valeur) =>
                    ref.read(captureFormProvider.notifier).choisirType(valeur),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // FittedBox : au-delà de quelques millions de F, le montant
          // rétrécit pour tenir sur une ligne plutôt que de passer à
          // la ligne au milieu du chiffre.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formaterMontant(montant),
              style: Theme.of(context).textTheme.displayLarge,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 16),
          const PaveNumerique(),
          const SizedBox(height: 24),
          Text(
            context.l10n.categorie,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          const GrilleCategories(),
          const SizedBox(height: 24),
          Text(
            context.l10n.compte,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
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
