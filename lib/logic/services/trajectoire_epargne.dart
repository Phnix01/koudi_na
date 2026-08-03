import '../../data/models/categorie.dart';
import '../../data/models/compte.dart';
import '../../data/models/pilier.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';

/// Un mois et l'épargne cumulée jusqu'à ce mois-là (inclus).
typedef PointEpargne = ({DateTime mois, int cumul});

/// L'épargne cumulée sur [nombreDeMois], et l'objectif à comparer
/// (section 5.1, graphique 6). `objectif` est la somme des
/// `objectifMontant` réglés sur les comptes de type Épargne (section 4,
/// écran D) — `0` si aucun compte n'a d'objectif fixé, auquel cas
/// l'appelant n'affiche pas de ligne de repère.
typedef TrajectoireEpargne = ({List<PointEpargne> points, int objectif});

/// Fonction pure — aucun accès à Hive ici. Le point de départ inclut le
/// solde initial des comptes Épargne, pour rester cohérent avec le
/// calcul de l'autonomie financière (indicateurs_analyse.dart).
TrajectoireEpargne calculerTrajectoireEpargne(
  List<Transaction> transactions,
  List<Categorie> categories,
  List<Compte> comptes, {
  DateTime? maintenant,
  int nombreDeMois = 12,
}) {
  final reference = maintenant ?? DateTime.now();
  final categorieParId = {for (final c in categories) c.id: c};
  final moisDeDepart = DateTime(
    reference.year,
    reference.month - (nombreDeMois - 1),
  );

  final epargneParMois = <DateTime, int>{
    for (var i = 0; i < nombreDeMois; i++)
      DateTime(moisDeDepart.year, moisDeDepart.month + i): 0,
  };

  for (final transaction in transactions) {
    if (transaction.type != TypeMouvement.depense) continue;
    if (categorieParId[transaction.categorieId]?.pilier != Pilier.epargne) {
      continue;
    }
    final mois = DateTime(transaction.date.year, transaction.date.month);
    if (!epargneParMois.containsKey(mois)) continue;
    epargneParMois[mois] = epargneParMois[mois]! + transaction.montant;
  }

  final comptesEpargne = comptes.where((c) => c.type == TypeCompte.epargne);
  var cumul = comptesEpargne.fold<int>(0, (somme, c) => somme + c.soldeInitial);

  final moisTries = epargneParMois.keys.toList()..sort();
  final points = <PointEpargne>[];
  for (final mois in moisTries) {
    cumul += epargneParMois[mois]!;
    points.add((mois: mois, cumul: cumul));
  }

  final objectif = comptesEpargne.fold<int>(
    0,
    (somme, c) => somme + (c.objectifMontant ?? 0),
  );

  return (points: points, objectif: objectif);
}
