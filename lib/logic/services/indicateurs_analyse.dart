import '../../data/models/categorie.dart';
import '../../data/models/compte.dart';
import '../../data/models/pilier.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';
import 'calcul_piliers.dart';

/// Les indicateurs de l'écran Analyse (section 5.2). Quelques formules
/// ne sont pas précisées telles quelles dans le cahier des charges ;
/// les choix faits ici sont documentés champ par champ.
typedef IndicateursAnalyse = ({
  /// Épargne du mois (dépenses de pilier épargne) ÷ entrées du mois.
  double tauxEpargne,

  /// Dépenses du mois en cours ÷ nombre de jours écoulés ce mois-ci.
  int depenseMoyenneJournaliereMois,

  /// Total des dépenses historiques ÷ nombre de jours depuis la
  /// première transaction connue.
  int depenseMoyenneJournaliereHistorique,

  /// Extrapolation du rythme actuel sur le mois entier.
  int projectionFinDeMois,

  /// Vrai si la projection dépasse les entrées du mois.
  bool projectionDepasseEntrees,

  /// Jours écoulés ce mois-ci sans aucune dépense enregistrée.
  int joursSansDepense,

  /// Nombre de mois de dépenses moyennes que couvre l'épargne
  /// accumulée (solde initial des comptes Épargne + toutes les
  /// dépenses passées de pilier épargne). L'indicateur le plus
  /// important de l'application (section 5.2) : il traduit l'argent
  /// en liberté.
  double autonomieFinanciereMois,
});

/// Fonction pure — aucun accès à Hive ici — pour rester facilement
/// testable indépendamment du stockage.
IndicateursAnalyse calculerIndicateurs(
  List<Transaction> transactions,
  List<Categorie> categories,
  List<Compte> comptes, {
  DateTime? maintenant,
}) {
  final reference = maintenant ?? DateTime.now();
  final categorieParId = {for (final c in categories) c.id: c};

  final transactionsDuMois = transactions.where((t) {
    return t.date.year == reference.year && t.date.month == reference.month;
  }).toList();

  final entreesMois = transactionsDuMois
      .where((t) => t.type == TypeMouvement.entree)
      .fold<int>(0, (somme, t) => somme + t.montant);
  final depensesMois = transactionsDuMois
      .where((t) => t.type == TypeMouvement.depense)
      .fold<int>(0, (somme, t) => somme + t.montant);

  final progressionPiliers = calculerProgressionPiliers(
    transactions,
    categories,
    maintenant: reference,
  );
  final epargneMois = progressionPiliers
      .firstWhere((p) => p.pilier == Pilier.epargne)
      .montantReel;
  final tauxEpargne = entreesMois > 0 ? epargneMois / entreesMois : 0.0;

  final jourCourant = reference.day;
  final depenseMoyenneJournaliereMois = jourCourant > 0
      ? (depensesMois / jourCourant).round()
      : 0;

  final dernierJourDuMois = DateTime(
    reference.year,
    reference.month + 1,
    0,
  ).day;
  final projectionFinDeMois = depenseMoyenneJournaliereMois * dernierJourDuMois;

  DateTime? datePremiereTransaction;
  var totalDepensesHistorique = 0;
  for (final transaction in transactions) {
    if (transaction.type == TypeMouvement.depense) {
      totalDepensesHistorique += transaction.montant;
    }
    if (datePremiereTransaction == null ||
        transaction.date.isBefore(datePremiereTransaction)) {
      datePremiereTransaction = transaction.date;
    }
  }
  final joursHistorique = datePremiereTransaction != null
      ? reference.difference(datePremiereTransaction).inDays + 1
      : 1;
  final depenseMoyenneJournaliereHistorique =
      (totalDepensesHistorique / joursHistorique).round();

  final joursAvecDepense = <int>{};
  for (final transaction in transactionsDuMois) {
    if (transaction.type == TypeMouvement.depense &&
        transaction.date.day <= jourCourant) {
      joursAvecDepense.add(transaction.date.day);
    }
  }
  final joursSansDepense = jourCourant - joursAvecDepense.length;

  final soldeInitialEpargne = comptes
      .where((c) => c.type == TypeCompte.epargne)
      .fold<int>(0, (somme, c) => somme + c.soldeInitial);
  final epargneAccumulee =
      soldeInitialEpargne + totalDepensesEpargne(transactions, categorieParId);
  final depenseMoyenneMensuelleHistorique =
      depenseMoyenneJournaliereHistorique * 30;
  final autonomieFinanciereMois = depenseMoyenneMensuelleHistorique > 0
      ? epargneAccumulee / depenseMoyenneMensuelleHistorique
      : 0.0;

  return (
    tauxEpargne: tauxEpargne,
    depenseMoyenneJournaliereMois: depenseMoyenneJournaliereMois,
    depenseMoyenneJournaliereHistorique: depenseMoyenneJournaliereHistorique,
    projectionFinDeMois: projectionFinDeMois,
    projectionDepasseEntrees: projectionFinDeMois > entreesMois,
    joursSansDepense: joursSansDepense,
    autonomieFinanciereMois: autonomieFinanciereMois,
  );
}

/// Somme, sur tout l'historique, des dépenses dans une catégorie de
/// pilier épargne — extraite pour être réutilisée sans dupliquer la
/// boucle de [calculerIndicateurs].
int totalDepensesEpargne(
  List<Transaction> transactions,
  Map<String, Categorie> categorieParId,
) {
  var total = 0;
  for (final transaction in transactions) {
    if (transaction.type != TypeMouvement.depense) continue;
    if (categorieParId[transaction.categorieId]?.pilier == Pilier.epargne) {
      total += transaction.montant;
    }
  }
  return total;
}
