import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/couleurs_piliers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/couleur_utils.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/pilier.dart';
import '../../logic/providers/repositories_providers.dart';
import '../../logic/services/comparaison_mensuelle.dart';
import '../../logic/services/equilibre_piliers.dart';
import '../../logic/services/evolution_mensuelle.dart';
import '../../logic/services/habitudes_hebdomadaires.dart';
import '../../logic/services/indicateurs_analyse.dart';
import '../../logic/services/observations_automatiques.dart';
import '../../logic/services/repartition_categories.dart';
import '../../logic/services/rythme_mois.dart';
import '../../logic/services/trajectoire_epargne.dart';
import '../widgets/graphique_comparaison.dart';
import '../widgets/graphique_equilibre_piliers.dart';
import '../widgets/graphique_evolution_mensuelle.dart';
import '../widgets/graphique_repartition.dart';
import '../widgets/graphique_rythme.dart';
import '../widgets/graphique_trajectoire_epargne.dart';
import '../widgets/heatmap_habitudes.dart';
import '../widgets/montant_anime.dart';
import '../widgets/observations_automatiques.dart';
import '../../l10n/l10n.dart';

/// Écran C (section 5) : les indicateurs calculés (section 5.2), les
/// sept graphiques (section 5.1) et les observations automatiques
/// (section 5.3). Le polissage visuel général arrivera dans la
/// dernière étape de la Phase 3.
class AnalyseScreen extends ConsumerWidget {
  const AnalyseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionRepo = ref.watch(transactionRepositoryProvider);
    final categories = ref.watch(categorieRepositoryProvider).tous();
    final comptes = ref.watch(compteRepositoryProvider).tous();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.analyse)),
      body: ValueListenableBuilder(
        valueListenable: transactionRepo.listenable(),
        builder: (context, _, _) {
          final l10n = context.l10n;
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
          final rythme = calculerRythmeMois(toutesLesTransactions);
          final habitudes = calculerHabitudesHebdomadaires(
            toutesLesTransactions,
          );
          final trajectoire = calculerTrajectoireEpargne(
            toutesLesTransactions,
            categories,
            comptes,
          );
          final equilibre = calculerEquilibrePiliers(
            toutesLesTransactions,
            categories,
          );
          final observations = genererObservations(
            toutesLesTransactions,
            categories,
            comptes,
            l10n,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children:
                [
                      if (observations.isNotEmpty) ...[
                        ObservationsAutomatiques(observations: observations),
                        const SizedBox(height: 12),
                      ],
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  l10n.evolution12Mois,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
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
                                l10n.repartitionDepensesMois,
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
                                l10n.top5Titre,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _PastilleLegende(
                                    couleur: AppColors.textMuted,
                                    libelle: l10n.moisDernier,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    l10n.ceMoisCouleurCategorie,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              GraphiqueComparaison(comparaisons: top5),
                              const SizedBox(height: 12),
                              for (final ligne in top5)
                                _LigneTop5(comparaison: ligne),
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
                                l10n.rythmeDuMois,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              GraphiqueRythme(rythme: rythme),
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
                                l10n.habitudesHebdo90,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              HeatmapHabitudes(grille: habitudes),
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
                                l10n.trajectoireEpargne,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              GraphiqueTrajectoireEpargne(
                                trajectoire: trajectoire,
                              ),
                              if (trajectoire.objectif == 0) ...[
                                const SizedBox(height: 8),
                                Text(
                                  l10n.aucunObjectifRegle,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.textMuted),
                                ),
                              ],
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
                                l10n.equilibrePiliers6Mois,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _PastilleLegende(
                                    couleur: couleursPiliers[Pilier.epargne]!,
                                    libelle: l10n.pilierEpargne,
                                  ),
                                  const SizedBox(width: 12),
                                  _PastilleLegende(
                                    couleur: couleursPiliers[Pilier.famille]!,
                                    libelle: l10n.pilierFamille,
                                  ),
                                  const SizedBox(width: 12),
                                  _PastilleLegende(
                                    couleur: couleursPiliers[Pilier.vie]!,
                                    libelle: l10n.pilierVie,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              GraphiqueEquilibrePiliers(mois: equilibre),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _CarteIndicateur(
                        titre: l10n.autonomieFinanciere,
                        valeur: l10n.autonomieValeur(
                          formaterDecimal(indicateurs.autonomieFinanciereMois),
                        ),
                        description: l10n.autonomieDescription,
                        accent: true,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _CarteIndicateur(
                              titre: l10n.tauxEpargne,
                              valeur:
                                  '${(indicateurs.tauxEpargne * 100).round()} %',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CarteIndicateur(
                              titre: l10n.joursSansDepense,
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
                              titre: l10n.depenseMoyJourMois,
                              valeurMontant:
                                  indicateurs.depenseMoyenneJournaliereMois,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CarteIndicateur(
                              titre: l10n.depenseMoyJourHistorique,
                              valeurMontant: indicateurs
                                  .depenseMoyenneJournaliereHistorique,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _CarteIndicateur(
                        titre: l10n.projectionFinDeMois,
                        valeurMontant: indicateurs.projectionFinDeMois,
                        description: indicateurs.projectionDepasseEntrees
                            ? l10n.projectionDepasseEntrees
                            : null,
                        alerte: indicateurs.projectionDepasseEntrees,
                      ),
                      // Cascade d'entrée (section 3.2) : chaque carte apparaît
                      // 40 ms après la précédente plutôt que toutes en même
                      // temps — .animate(interval:) répète la même chaîne
                      // d'effets sur chaque enfant de la liste, en décalant
                      // son départ à chaque fois.
                    ]
                    .animate(interval: 40.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
          );
        },
      ),
    );
  }
}

class _CarteIndicateur extends StatelessWidget {
  const _CarteIndicateur({
    required this.titre,
    this.valeur,
    this.valeurMontant,
    this.description,
    this.accent = false,
    this.alerte = false,
  }) : assert(
         valeur != null || valeurMontant != null,
         'fournir valeur ou valeurMontant',
       );

  final String titre;

  /// Pour un texte déjà formaté (pourcentage, "X mois", nombre de jours).
  final String? valeur;

  /// Pour un montant FCFA brut : passe par [MontantAnime], qui défile de
  /// 0 à sa valeur (section 3.2) — réservé aux "montants agrégés",
  /// contrairement à [valeur] qui peut représenter autre chose qu'une
  /// somme d'argent.
  final int? valeurMontant;
  final String? description;
  final bool accent;
  final bool alerte;

  @override
  Widget build(BuildContext context) {
    final couleurValeur = alerte
        ? AppColors.negative
        : (accent ? AppColors.accent : AppColors.textPrimary);
    final styleValeur = Theme.of(context).textTheme.displaySmall?.copyWith(
      color: couleurValeur,
      fontSize: accent ? 28 : 22,
    );
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
            valeurMontant != null
                ? MontantAnime(valeur: valeurMontant!, style: styleValeur)
                : Text(valeur!, style: styleValeur),
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
        ? context.l10n.nouveau
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
