import '../../data/models/categorie.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';
import 'evolution_mensuelle.dart';

/// Période de l'écran Analyse (brief §4.5).
enum PeriodeAnalyse { mois, sixMois, annee }

/// Une barre de l'histogramme : une semaine (période « Mois ») ou un mois.
typedef BarrePeriode = ({
  DateTime debut,

  /// Numéro de semaine (1 à 5) pour la période « Mois », sinon 0.
  int semaine,
  int entrees,
  int depenses,
  bool courante,
});

typedef PartPeriode = ({Categorie categorie, int montant, double part});

/// Bornes [début, fin[ de la période qui se termine au mois de [maintenant].
(DateTime, DateTime) bornesPeriode(PeriodeAnalyse periode, DateTime maintenant) {
  final fin = DateTime(maintenant.year, maintenant.month + 1);
  final debut = switch (periode) {
    PeriodeAnalyse.mois => DateTime(maintenant.year, maintenant.month),
    PeriodeAnalyse.sixMois => DateTime(maintenant.year, maintenant.month - 5),
    PeriodeAnalyse.annee => DateTime(maintenant.year, maintenant.month - 11),
  };
  return (debut, fin);
}

List<BarrePeriode> calculerBarres(
  List<Transaction> transactions,
  PeriodeAnalyse periode, {
  DateTime? maintenant,
}) {
  final reference = maintenant ?? DateTime.now();
  if (periode != PeriodeAnalyse.mois) {
    final points = calculerEvolutionMensuelle(
      transactions,
      maintenant: reference,
      nombreDeMois: periode == PeriodeAnalyse.sixMois ? 6 : 12,
    );
    return [
      for (var i = 0; i < points.length; i++)
        (
          debut: points[i].mois,
          semaine: 0,
          entrees: points[i].entrees,
          depenses: points[i].depenses,
          courante: i == points.length - 1,
        ),
    ];
  }

  // Semaines du mois : 1-7, 8-14, 15-21, 22-28, 29-fin.
  final dernierJour = DateTime(reference.year, reference.month + 1, 0).day;
  final nbSemaines = ((dernierJour - 1) ~/ 7) + 1;
  final entrees = List.filled(nbSemaines, 0);
  final depenses = List.filled(nbSemaines, 0);
  for (final t in transactions) {
    if (t.date.year != reference.year || t.date.month != reference.month) continue;
    final s = (t.date.day - 1) ~/ 7;
    if (t.type == TypeMouvement.entree) {
      entrees[s] += t.montant;
    } else {
      depenses[s] += t.montant;
    }
  }
  final semaineCourante = (reference.day - 1) ~/ 7;
  return [
    for (var s = 0; s < nbSemaines; s++)
      (
        debut: DateTime(reference.year, reference.month, s * 7 + 1),
        semaine: s + 1,
        entrees: entrees[s],
        depenses: depenses[s],
        courante: s == semaineCourante,
      ),
  ];
}

/// Dépenses par catégorie sur la période, de la plus grosse à la plus
/// petite, avec leur part du total.
List<PartPeriode> calculerRepartitionPeriode(
  List<Transaction> transactions,
  List<Categorie> categories,
  PeriodeAnalyse periode, {
  DateTime? maintenant,
}) {
  final (debut, fin) = bornesPeriode(periode, maintenant ?? DateTime.now());
  final parId = {for (final c in categories) c.id: c};
  final montants = <String, int>{};
  var total = 0;
  for (final t in transactions) {
    if (t.type != TypeMouvement.depense) continue;
    if (t.date.isBefore(debut) || !t.date.isBefore(fin)) continue;
    if (!parId.containsKey(t.categorieId)) continue;
    montants[t.categorieId] = (montants[t.categorieId] ?? 0) + t.montant;
    total += t.montant;
  }
  final parts = [
    for (final e in montants.entries)
      (categorie: parId[e.key]!, montant: e.value, part: total == 0 ? 0.0 : e.value / total),
  ]..sort((a, b) => b.montant.compareTo(a.montant));
  return parts;
}
