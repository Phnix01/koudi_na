import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';

/// Un jour du mois et le cumul des dépenses jusqu'à ce jour-là.
typedef PointCumul = ({int jour, int montant});

/// Rythme du mois : dépenses cumulées jour par jour jusqu'à aujourd'hui
/// ([reel]), puis une extrapolation du rythme actuel jusqu'à la fin du
/// mois ([projection]) — section 5.1, graphique 4. [projection]
/// commence au même point que la fin de [reel], pour que les deux
/// courbes se rejoignent sans saut visuel.
typedef RythmeMois = ({
  List<PointCumul> reel,
  List<PointCumul> projection,
  int dernierJourDuMois,
  int entreesMois,
});

/// Fonction pure — aucun accès à Hive ici.
RythmeMois calculerRythmeMois(
  List<Transaction> transactions, {
  DateTime? maintenant,
}) {
  final reference = maintenant ?? DateTime.now();
  final dernierJourDuMois = DateTime(
    reference.year,
    reference.month + 1,
    0,
  ).day;
  final jourCourant = reference.day;

  final depensesParJour = <int, int>{};
  var entreesMois = 0;
  for (final transaction in transactions) {
    final memeMois =
        transaction.date.year == reference.year &&
        transaction.date.month == reference.month;
    if (!memeMois) continue;
    if (transaction.type == TypeMouvement.depense) {
      depensesParJour[transaction.date.day] =
          (depensesParJour[transaction.date.day] ?? 0) + transaction.montant;
    } else {
      entreesMois += transaction.montant;
    }
  }

  final reel = <PointCumul>[];
  var cumul = 0;
  for (var jour = 1; jour <= jourCourant; jour++) {
    cumul += depensesParJour[jour] ?? 0;
    reel.add((jour: jour, montant: cumul));
  }

  final moyenneJournaliere = jourCourant > 0 ? cumul / jourCourant : 0.0;
  final projection = <PointCumul>[
    for (var jour = jourCourant; jour <= dernierJourDuMois; jour++)
      (jour: jour, montant: (moyenneJournaliere * jour).round()),
  ];

  return (
    reel: reel,
    projection: projection,
    dernierJourDuMois: dernierJourDuMois,
    entreesMois: entreesMois,
  );
}
