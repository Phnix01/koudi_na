import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../logic/providers/repositories_providers.dart';
import '../../logic/services/evolution_mensuelle.dart';
import '../../logic/services/indicateurs_analyse.dart';
import '../widgets/graphique_evolution_mensuelle.dart';

/// Écran C, en construction (section 5) : les indicateurs calculés
/// (section 5.2) et le premier des sept graphiques (évolution
/// mensuelle). Les six autres visualisations et les observations
/// automatiques arriveront dans les étapes suivantes.
class AnalyseScreen extends ConsumerWidget {
  const AnalyseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionRepo = ref.watch(transactionRepositoryProvider);
    final categories = ref.watch(categorieRepositoryProvider).tous();
    final comptes = ref.watch(compteRepositoryProvider).tous();

    return Scaffold(
      appBar: AppBar(title: const Text('Analyse')),
      body: ValueListenableBuilder(
        valueListenable: transactionRepo.listenable(),
        builder: (context, _, _) {
          final toutesLesTransactions = transactionRepo.tous();
          final indicateurs = calculerIndicateurs(
            toutesLesTransactions,
            categories,
            comptes,
          );
          final evolution = calculerEvolutionMensuelle(toutesLesTransactions);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          'Évolution sur 12 mois',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GraphiqueEvolutionMensuelle(points: evolution),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _CarteIndicateur(
                titre: 'Autonomie financière',
                valeur:
                    '${NumberFormat('0.0', 'fr_FR').format(indicateurs.autonomieFinanciereMois)} mois',
                description:
                    "Nombre de mois de dépenses moyennes que couvre ton épargne actuelle",
                accent: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _CarteIndicateur(
                      titre: "Taux d'épargne",
                      valeur: '${(indicateurs.tauxEpargne * 100).round()} %',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CarteIndicateur(
                      titre: 'Jours sans dépense',
                      valeur: '${indicateurs.joursSansDepense}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _CarteIndicateur(
                      titre: 'Dépense moy. / jour (ce mois)',
                      valeur: formaterMontant(
                        indicateurs.depenseMoyenneJournaliereMois,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CarteIndicateur(
                      titre: 'Dépense moy. / jour (historique)',
                      valeur: formaterMontant(
                        indicateurs.depenseMoyenneJournaliereHistorique,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _CarteIndicateur(
                titre: 'Projection fin de mois',
                valeur: formaterMontant(indicateurs.projectionFinDeMois),
                description: indicateurs.projectionDepasseEntrees
                    ? 'Au rythme actuel, tu dépasseras tes entrées ce mois-ci'
                    : null,
                alerte: indicateurs.projectionDepasseEntrees,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CarteIndicateur extends StatelessWidget {
  const _CarteIndicateur({
    required this.titre,
    required this.valeur,
    this.description,
    this.accent = false,
    this.alerte = false,
  });

  final String titre;
  final String valeur;
  final String? description;
  final bool accent;
  final bool alerte;

  @override
  Widget build(BuildContext context) {
    final couleurValeur = alerte
        ? AppColors.negative
        : (accent ? AppColors.accent : AppColors.textPrimary);
    return Card(
      shape: accent
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.accent),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titre,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 6),
            Text(
              valeur,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: couleurValeur,
                fontSize: accent ? 28 : 22,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 6),
              Text(
                description!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
