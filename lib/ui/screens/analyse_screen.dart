import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/couleur_utils.dart';
import '../../core/utils/formatters.dart';
import '../../logic/providers/repositories_providers.dart';
import '../../logic/services/comparaison_mensuelle.dart';
import '../../logic/services/evolution_mensuelle.dart';
import '../../logic/services/indicateurs_analyse.dart';
import '../../logic/services/repartition_categories.dart';
import '../widgets/graphique_comparaison.dart';
import '../widgets/graphique_evolution_mensuelle.dart';
import '../widgets/graphique_repartition.dart';

/// Écran C, en construction (section 5) : les indicateurs calculés
/// (section 5.2) et trois des sept graphiques (évolution mensuelle,
/// répartition des dépenses, comparaison mensuelle + Top 5). Les
/// quatre autres visualisations et les observations automatiques
/// arriveront dans les étapes suivantes.
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
          final repartition = calculerRepartitionDepenses(
            toutesLesTransactions,
            categories,
          );
          final comparaison = calculerComparaisonMensuelle(
            toutesLesTransactions,
            categories,
          );
          final top5 = comparaison.take(5).toList();

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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Répartition des dépenses (ce mois)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      GraphiqueRepartition(parts: repartition),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top 5 des catégories (ce mois vs le mois dernier)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const _PastilleLegende(
                            couleur: AppColors.textMuted,
                            libelle: 'Mois dernier',
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Ce mois : couleur de la catégorie',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GraphiqueComparaison(comparaisons: top5),
                      const SizedBox(height: 12),
                      for (final ligne in top5) _LigneTop5(comparaison: ligne),
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

class _PastilleLegende extends StatelessWidget {
  const _PastilleLegende({required this.couleur, required this.libelle});

  final Color couleur;
  final String libelle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          libelle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _LigneTop5 extends StatelessWidget {
  const _LigneTop5({required this.comparaison});

  final ComparaisonCategorie comparaison;

  @override
  Widget build(BuildContext context) {
    final couleurCategorie = depuisHex(comparaison.categorie.couleurHex);
    final variation = comparaison.variationPourcent;
    // Pour une dépense, une hausse est un signal négatif (rouge), une
    // baisse un signal positif (vert) — l'inverse de ce qu'on ferait
    // pour une entrée.
    final couleurVariation = variation == null
        ? AppColors.textMuted
        : (variation > 0 ? AppColors.negative : AppColors.positive);
    final texteVariation = variation == null
        ? 'Nouveau'
        : '${variation > 0 ? '+' : ''}${variation.round()} %';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: couleurCategorie,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(comparaison.categorie.libelle)),
          Text(formaterMontant(comparaison.moisCourant)),
          const SizedBox(width: 12),
          Text(
            texteVariation,
            style: TextStyle(
              color: couleurVariation,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
