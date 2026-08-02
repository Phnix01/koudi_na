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
import '../../logic/services/calcul_solde.dart';
import '../../logic/services/groupement_transactions.dart';
import 'edition_transaction_screen.dart';

/// Écran B en version simple (Phase 2, étape 1, section 6) : liste des
/// transactions du mois groupées par jour, avec édition et suppression.
/// La navigation entre les mois, les filtres et les barres 40/25/35
/// arriveront dans les étapes suivantes.
class MoisScreen extends ConsumerWidget {
  const MoisScreen({super.key});

  String _libelleJour(DateTime jour) {
    final maintenant = DateTime.now();
    final aujourdHui = DateTime(maintenant.year, maintenant.month, maintenant.day);
    final hier = aujourdHui.subtract(const Duration(days: 1));
    if (jour == aujourdHui) return "Aujourd'hui";
    if (jour == hier) return 'Hier';
    return DateFormat('EEEE d MMMM', 'fr_FR').format(jour);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionRepo = ref.watch(transactionRepositoryProvider);
    // Catégories et comptes changent rarement pendant qu'on regarde
    // cette liste : un Map construit une fois par build suffit, pas
    // besoin de les envelopper dans leur propre ValueListenableBuilder.
    final categoriesParId = {for (final c in ref.watch(categorieRepositoryProvider).tous()) c.id: c};
    final comptesParId = {for (final c in ref.watch(compteRepositoryProvider).tous()) c.id: c};

    return Scaffold(
      appBar: AppBar(title: Text(DateFormat('MMMM y', 'fr_FR').format(DateTime.now()))),
      body: ValueListenableBuilder(
        valueListenable: transactionRepo.listenable(),
        builder: (context, _, _) {
          final maintenant = DateTime.now();
          final transactionsDuMois = transactionRepo.tous().where((t) {
            return t.date.year == maintenant.year && t.date.month == maintenant.month;
          }).toList()..sort((a, b) => b.date.compareTo(a.date));

          final totaux = calculerTotauxDuMois(transactionsDuMois);
          final journees = grouperParJour(transactionsDuMois);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: _TuileTotal(libelle: 'Entrées', valeur: totaux.entrees, couleur: AppColors.positive)),
                    const SizedBox(width: 12),
                    Expanded(child: _TuileTotal(libelle: 'Dépenses', valeur: totaux.depenses, couleur: AppColors.negative)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TuileTotal(
                        libelle: 'Solde',
                        valeur: totaux.solde,
                        couleur: totaux.solde >= 0 ? AppColors.positive : AppColors.negative,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: journees.isEmpty
                    ? Center(
                        child: Text(
                          'Aucune transaction ce mois-ci',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
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
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _libelleJour(journee.jour),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                                    ),
                                    Text(
                                      formaterMontant(journee.total),
                                      style: TextStyle(color: journee.total >= 0 ? AppColors.positive : AppColors.negative),
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
                                    child: const Icon(Icons.delete_outline, color: Colors.white),
                                  ),
                                  onDismissed: (_) async {
                                    await ref.read(transactionRepositoryProvider).supprimer(transaction.id);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Transaction supprimée'),
                                        action: SnackBarAction(
                                          label: 'Annuler',
                                          onPressed: () {
                                            ref.read(transactionRepositoryProvider).enregistrer(transaction);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  child: InkWell(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => EditionTransactionScreen(transaction: transaction)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: _LigneTransaction(
                                        transaction: transaction,
                                        categorie: categoriesParId[transaction.categorieId],
                                        compte: comptesParId[transaction.compteId],
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
          );
        },
      ),
    );
  }
}

class _TuileTotal extends StatelessWidget {
  const _TuileTotal({required this.libelle, required this.valeur, required this.couleur});

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
            Text(libelle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(
              formaterMontant(valeur),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: couleur, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _LigneTransaction extends StatelessWidget {
  const _LigneTransaction({required this.transaction, required this.categorie, required this.compte});

  final Transaction transaction;
  final Categorie? categorie;
  final Compte? compte;

  @override
  Widget build(BuildContext context) {
    final estEntree = transaction.type == TypeMouvement.entree;
    final couleurCategorie = categorie != null ? depuisHex(categorie!.couleurHex) : AppColors.textMuted;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: couleurCategorie.withValues(alpha: 0.18),
        child: PhosphorIcon(
          categorie != null ? (icones[categorie!.iconeCode] ?? PhosphorIconsFill.question) : PhosphorIconsFill.question,
          color: couleurCategorie,
          size: 20,
        ),
      ),
      title: Text(categorie?.libelle ?? 'Catégorie supprimée'),
      subtitle: Text(compte?.libelle ?? 'Compte supprimé'),
      trailing: Text(
        '${estEntree ? '+' : '-'}${formaterMontant(transaction.montant)}',
        style: TextStyle(color: estEntree ? AppColors.positive : AppColors.negative, fontWeight: FontWeight.w600),
      ),
    );
  }
}
