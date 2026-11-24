import '../../core/utils/formatters.dart';
import '../../data/models/categorie.dart';
import '../../data/models/pilier.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';
import 'calcul_piliers.dart';
import 'calcul_solde.dart';

/// Comparaison du rythme des dépenses au temps écoulé dans le mois
/// (brief §5.3) : « en avance » quand on a dépensé une part des entrées
/// inférieure ou égale à la part du mois écoulée.
typedef RythmeDepenses = ({
  double ratioDepense,
  double ratioTemps,
  int jour,
  int joursDuMois,
  bool enAvance,
});

typedef Enveloppe = ({
  Pilier pilier,
  int budget,
  int consomme,

  /// Négatif quand l'enveloppe est dépassée.
  int reste,
  double progression,
});

typedef TableauDeBord = ({
  int entrees,
  int depenses,
  int solde,

  /// Nul sans entrée ce mois-là ou pour un mois pas encore commencé.
  RythmeDepenses? rythme,

  /// Dépenses attendues en fin de mois, arrondies à 3 chiffres
  /// significatifs ; pour un mois terminé, le total réel.
  int projectionFinDeMois,
  int moyenneParJour,
  int moyenneParJourHorsEpargne,
  List<Enveloppe> enveloppes,
});

int joursDansLeMois(DateTime mois) => DateTime(mois.year, mois.month + 1, 0).day;

/// Jours du mois [mois] déjà écoulés à la date [maintenant] : tous pour un
/// mois passé, aucun pour un mois futur, le jour courant sinon.
int joursEcoules(DateTime mois, DateTime maintenant) {
  final debut = DateTime(mois.year, mois.month);
  final debutCourant = DateTime(maintenant.year, maintenant.month);
  if (debut.isBefore(debutCourant)) return joursDansLeMois(mois);
  if (debut.isAfter(debutCourant)) return 0;
  return maintenant.day;
}

TableauDeBord calculerTableauDeBord(
  List<Transaction> transactions,
  List<Categorie> categories, {
  required DateTime mois,
  DateTime? maintenant,
}) {
  final reference = maintenant ?? DateTime.now();
  final totaux = calculerTotauxDuMois(transactions, maintenant: mois);
  final jours = joursDansLeMois(mois);
  final ecoules = joursEcoules(mois, reference);

  final pilierParCategorie = {for (final c in categories) c.id: c.pilier};
  var depensesEpargne = 0;
  for (final t in transactions) {
    if (t.type != TypeMouvement.depense) continue;
    if (t.date.year != mois.year || t.date.month != mois.month) continue;
    if (pilierParCategorie[t.categorieId] == Pilier.epargne) {
      depensesEpargne += t.montant;
    }
  }

  final RythmeDepenses? rythme;
  if (totaux.entrees > 0 && ecoules > 0) {
    final ratioDepense = totaux.depenses / totaux.entrees;
    final ratioTemps = ecoules / jours;
    rythme = (
      ratioDepense: ratioDepense,
      ratioTemps: ratioTemps,
      jour: ecoules,
      joursDuMois: jours,
      enAvance: ratioDepense <= ratioTemps,
    );
  } else {
    rythme = null;
  }

  final projection = ecoules == 0
      ? 0
      : ecoules >= jours
      ? totaux.depenses
      : arrondiSignificatif(totaux.depenses / ecoules * jours);

  final enveloppes = calculerProgressionPiliers(
    transactions,
    categories,
    maintenant: mois,
  ).map((p) => (
    pilier: p.pilier,
    budget: p.objectifMontant,
    consomme: p.montantReel,
    reste: p.objectifMontant - p.montantReel,
    progression: p.progression,
  )).toList();

  return (
    entrees: totaux.entrees,
    depenses: totaux.depenses,
    solde: totaux.solde,
    rythme: rythme,
    projectionFinDeMois: projection,
    moyenneParJour: ecoules == 0 ? 0 : (totaux.depenses / ecoules).round(),
    moyenneParJourHorsEpargne: ecoules == 0
        ? 0
        : ((totaux.depenses - depensesEpargne) / ecoules).round(),
    enveloppes: enveloppes,
  );
}

/// Dernière catégorie et dernier compte utilisés pour ce type
/// d'opération, pour présélectionner la saisie (brief §4.3) : une
/// dépense répétée se fait alors en 3 gestes.
({String? categorieId, String? compteId}) dernierChoix(
  List<Transaction> transactions,
  TypeMouvement type,
) {
  Transaction? derniere;
  for (final t in transactions) {
    if (t.type != type) continue;
    if (derniere == null || t.date.isAfter(derniere.date)) derniere = t;
  }
  return (categorieId: derniere?.categorieId, compteId: derniere?.compteId);
}
