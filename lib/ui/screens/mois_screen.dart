import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/icones.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/couleur_utils.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/categorie.dart';
import '../../data/models/compte.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';
import '../../logic/providers/repositories_providers.dart';
import '../../logic/services/calcul_piliers.dart';
import '../../logic/services/calcul_solde.dart';
import '../../logic/services/groupement_transactions.dart';
import '../navigation/route_animee.dart';
import '../widgets/barres_piliers.dart';
import '../widgets/filtres_mois.dart';
import '../widgets/montant_anime.dart';
import '../../l10n/l10n.dart';
import 'edition_transaction_screen.dart';

/// Écran B en version simple (Phase 2, étape 1-4, section 6) : liste des
/// transactions du mois groupées par jour, avec édition, suppression,
/// navigation entre les mois, filtres rapides et barres 40/25/35.
class MoisScreen extends ConsumerStatefulWidget {
  const MoisScreen({super.key});

  @override
  ConsumerState<MoisScreen> createState() => _MoisScreenState();
}

class _MoisScreenState extends ConsumerState<MoisScreen> {
  // Le mois affiché est un état purement local à cet écran (comme le
  // repli de la note en Capture) : aucun autre écran n'a besoin de le
  // connaître, donc setState suffit, pas de provider Riverpod.
  late DateTime _moisAffiche = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  // Les filtres aussi : ils ne pilotent que l'affichage de cet écran.
  TypeMouvement? _filtreType;
  String? _filtreCategorieId;
  String? _filtreCompteId;

  void _moisPrecedent() => setState(
    () => _moisAffiche = DateTime(_moisAffiche.year, _moisAffiche.month - 1),
  );

  void _moisSuivant() => setState(
    () => _moisAffiche = DateTime(_moisAffiche.year, _moisAffiche.month + 1),
  );

  String _libelleJour(BuildContext context, DateTime jour) {
    final maintenant = DateTime.now();
    final aujourdHui = DateTime(
      maintenant.year,
      maintenant.month,
      maintenant.day,
    );
    final hier = aujourdHui.subtract(const Duration(days: 1));
    if (jour == aujourdHui) return context.l10n.aujourdHui;
    if (jour == hier) return context.l10n.hier;
    return DateFormat.MMMMEEEEd().format(jour);
  }

  @override
  Widget build(BuildContext context) {
    final transactionRepo = ref.watch(transactionRepositoryProvider);
    // Catégories et comptes changent rarement pendant qu'on regarde
    // cette liste : une seule lecture par build suffit, pas besoin de
    // les envelopper dans leur propre ValueListenableBuilder.
    final categories = ref.watch(categorieRepositoryProvider).tous();
    final comptes = ref.watch(compteRepositoryProvider).tous();
    final categoriesParId = {for (final c in categories) c.id: c};
    final comptesParId = {for (final c in comptes) c.id: c};
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.chevron_left),
              onPressed: _moisPrecedent,
            ),
            Text(DateFormat.yMMMM().format(_moisAffiche)),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.chevron_right),
              onPressed: _moisSuivant,
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: transactionRepo.listenable(),
        builder: (context, _, _) {
          final transactionsDuMoisComplet = transactionRepo.tous().where((t) {
            return t.date.year == _moisAffiche.year &&
                t.date.month == _moisAffiche.month;
          }).toList();

          final transactionsFiltrees = transactionsDuMoisComplet.where((t) {
            if (_filtreType != null && t.type != _filtreType) return false;
            if (_filtreCategorieId != null &&
                t.categorieId != _filtreCategorieId) {
              return false;
            }
            if (_filtreCompteId != null && t.compteId != _filtreCompteId) {
              return false;
            }
            return true;
          }).toList()..sort((a, b) => b.date.compareTo(a.date));

          // Les totaux et la liste reflètent les filtres actifs (filtrer
          // par compte ne montre que le solde de ce compte) ; les barres
          // 40/25/35, elles, portent toujours sur le mois entier — un
          // filtre de navigation ne doit pas déformer l'image du budget.
          final totaux = calculerTotauxDuMois(
            transactionsFiltrees,
            maintenant: _moisAffiche,
          );
          final journees = grouperParJour(transactionsFiltrees);
          final progressionsPiliers = calculerProgressionPiliers(
            transactionsDuMoisComplet,
            categories,
            maintenant: _moisAffiche,
          );

          // Glissé vers la gauche → mois suivant, vers la droite → mois
          // précédent (comme tourner les pages d'un calendrier).
          return GestureDetector(
            onHorizontalDragEnd: (details) {
              final vitesse = details.primaryVelocity ?? 0;
              if (vitesse < -200) _moisSuivant();
              if (vitesse > 200) _moisPrecedent();
            },
            child: Column(
              children: [
                const SizedBox(height: 8),
                FiltresMois(
                  type: _filtreType,
                  categorieSelectionnee: categoriesParId[_filtreCategorieId],
                  compteSelectionne: comptesParId[_filtreCompteId],
                  categories: categories,
                  comptes: comptes,
                  onTypeChange: (t) => setState(() => _filtreType = t),
                  onCategorieChange: (c) =>
                      setState(() => _filtreCategorieId = c?.id),
                  onCompteChange: (c) =>
                      setState(() => _filtreCompteId = c?.id),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TuileTotal(
                          libelle: l10n.entrees,
                          valeur: totaux.entrees,
                          couleur: AppColors.positive,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TuileTotal(
                          libelle: l10n.depenses,
                          valeur: totaux.depenses,
                          couleur: AppColors.negative,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TuileTotal(
                          libelle: l10n.solde,
                          valeur: totaux.solde,
                          couleur: totaux.solde >= 0
                              ? AppColors.positive
                              : AppColors.negative,
                        ),
                      ),
                    ],
                  ),
                ),
                BarresPiliers(progressions: progressionsPiliers),
                const SizedBox(height: 8),
                Expanded(
                  child: journees.isEmpty
                      ? Center(
                          child: Text(
                            _filtreType != null ||
                                    _filtreCategorieId != null ||
                                    _filtreCompteId != null
                                ? l10n.aucuneTransactionFiltres
                                : l10n.aucuneTransactionMois,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.builder(
                          itemCount: journees.length,
                          itemBuilder: (context, index) {
                            final journee = journees[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _libelleJour(context, journee.jour),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.textMuted,
                                            ),
                                      ),
                                      Text(
                                        formaterMontant(journee.total),
                                        style: TextStyle(
                                          color: journee.total >= 0
                                              ? AppColors.positive
                                              : AppColors.negative,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...journee.transactions.map((transaction) {
                                  return Dismissible(
                                    key: ValueKey(transaction.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      color: AppColors.negative,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      child: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onDismissed: (_) async {
                                      await ref
                                          .read(transactionRepositoryProvider)
                                          .supprimer(transaction.id);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            l10n.transactionSupprimee,
                                          ),
                                          action: SnackBarAction(
                                            label: l10n.annuler,
                                            onPressed: () {
                                              ref
                                                  .read(
                                                    transactionRepositoryProvider,
                                                  )
                                                  .enregistrer(transaction);
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: InkWell(
                                      onTap: () => Navigator.of(context).push(
                                        routeAnimee(
                                          EditionTransactionScreen(
                                            transaction: transaction,
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: _LigneTransaction(
                                          transaction: transaction,
                                          categorie:
                                              categoriesParId[transaction
                                                  .categorieId],
                                          compte:
                                              comptesParId[transaction
                                                  .compteId],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                const Divider(height: 1),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TuileTotal extends StatelessWidget {
  const _TuileTotal({
    required this.libelle,
    required this.valeur,
    required this.couleur,
  });

  final String libelle;
  final int valeur;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              libelle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 4),
            MontantAnime(
              valeur: valeur,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: couleur,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LigneTransaction extends StatelessWidget {
  const _LigneTransaction({
    required this.transaction,
    required this.categorie,
    required this.compte,
  });

  final Transaction transaction;
  final Categorie? categorie;
  final Compte? compte;

  @override
  Widget build(BuildContext context) {
    final estEntree = transaction.type == TypeMouvement.entree;
    final couleurCategorie = categorie != null
        ? depuisHex(categorie!.couleurHex)
        : AppColors.textMuted;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: couleurCategorie.withValues(alpha: 0.18),
        child: PhosphorIcon(
          categorie != null
              ? (icones[categorie!.iconeCode] ?? PhosphorIconsFill.question)
              : PhosphorIconsFill.question,
          color: couleurCategorie,
          size: 20,
        ),
      ),
      title: Text(categorie?.libelle ?? context.l10n.categorieSupprimee),
      subtitle: Text(compte?.libelle ?? context.l10n.compteSupprime),
      trailing: Text(
        '${estEntree ? '+' : '-'}${formaterMontant(transaction.montant)}',
        style: TextStyle(
          color: estEntree ? AppColors.positive : AppColors.negative,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
