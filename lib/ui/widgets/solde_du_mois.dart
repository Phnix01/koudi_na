import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../logic/providers/repositories_providers.dart';
import '../../logic/services/calcul_solde.dart';
import '../../l10n/l10n.dart';
import 'montant_anime.dart';

/// Solde du mois, discret en haut de l'écran Capture (section 4). Ce
/// widget ne dépend que de la Box des transactions, jamais du
/// formulaire de saisie : taper un chiffre sur le pavé ne déclenche
/// donc jamais son animation d'entrée.
class SoldeDuMois extends ConsumerWidget {
  const SoldeDuMois({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionRepo = ref.watch(transactionRepositoryProvider);

    return ValueListenableBuilder(
      valueListenable: transactionRepo.listenable(),
      builder: (context, _, _) {
        final solde = calculerTotauxDuMois(transactionRepo.tous()).solde;
        return Column(
          children: [
            Text(
              context.l10n.soldeDuMois,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
            MontantAnime(
              valeur: solde,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: solde >= 0 ? AppColors.positive : AppColors.negative,
              ),
            ),
          ],
        );
      },
    );
  }
}
