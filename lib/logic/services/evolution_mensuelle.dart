import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';

/// Un mois et ses totaux, pour le graphique d'évolution (section 5.1).
typedef PointMensuel = ({DateTime mois, int entrees, int depenses});

/// Les [nombreDeMois] derniers mois (le mois courant inclus), du plus
/// ancien au plus récent — même les mois sans aucune transaction
/// apparaissent, avec des totaux à zéro, pour que la courbe ne saute
/// jamais un point. Fonction pure — aucun accès à Hive ici.
List<PointMensuel> calculerEvolutionMensuelle(
  List<Transaction> transactions, {
  DateTime? maintenant,
  int nombreDeMois = 12,
}) {
  final reference = maintenant ?? DateTime.now();
  final moisDeDepart = DateTime(
    reference.year,
    reference.month - (nombreDeMois - 1),
  );

  final totauxParMois = <DateTime, ({int entrees, int depenses})>{
    for (var i = 0; i < nombreDeMois; i++)
      DateTime(moisDeDepart.year, moisDeDepart.month + i): (
        entrees: 0,
        depenses: 0,
      ),
  };

  for (final transaction in transactions) {
    final mois = DateTime(transaction.date.year, transaction.date.month);
    final actuel = totauxParMois[mois];
    if (actuel == null) {
      continue; // hors de la fenêtre des nombreDeMois derniers mois
    }

    totauxParMois[mois] = transaction.type == TypeMouvement.entree
        ? (
            entrees: actuel.entrees + transaction.montant,
            depenses: actuel.depenses,
          )
        : (
            entrees: actuel.entrees,
            depenses: actuel.depenses + transaction.montant,
          );
  }

  return totauxParMois.entries
      .map(
        (entree) => (
          mois: entree.key,
          entrees: entree.value.entrees,
          depenses: entree.value.depenses,
        ),
      )
      .toList()
    ..sort((a, b) => a.mois.compareTo(b.mois));
}
