import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../logic/providers/repositories_providers.dart';
import '../../logic/services/calcul_solde.dart';

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
              'Solde du mois',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
            // Le compteur défile de 0 à sa valeur en 600 ms (section 3.2) :
            // TweenAnimationBuilder rejoue cette interpolation à chaque
            // rebuild déclenché par une nouvelle transaction.
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: solde),
              duration: const Duration(milliseconds: 600),
              builder: (context, valeur, _) {
                return Text(
                  formaterMontant(valeur),
                  style: Theme.of(
                    context,
                  ).textTheme.displaySmall?.copyWith(color: solde >= 0 ? AppColors.positive : AppColors.negative),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
