import '../../data/models/categorie.dart';
import '../../data/models/pilier.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';

/// Cibles par défaut de la règle 40/25/35 (section 5.2). Deviendront
/// réglables dans l'écran Réglages (section 4, écran D) ; en attendant,
/// ce sont des constantes.
const Map<Pilier, double> pourcentagesCibles = {
  Pilier.epargne: 0.40,
  Pilier.famille: 0.25,
  Pilier.vie: 0.35,
};

/// Suivi d'un pilier pour le mois : dépenses réelles des catégories qui
/// lui sont rattachées, comparées à sa part cible des entrées du mois.
typedef ProgressionPilier = ({
  Pilier pilier,
  int montantReel,
  int objectifMontant,
  double progression,
});

/// Fonction pure — aucun accès à Hive ici — pour rester facilement
/// testable indépendamment du stockage.
List<ProgressionPilier> calculerProgressionPiliers(
  List<Transaction> transactions,
  List<Categorie> categories, {
  DateTime? maintenant,
}) {
  final reference = maintenant ?? DateTime.now();
  final categorieParId = {for (final c in categories) c.id: c};

  var totalEntrees = 0;
  final depensesParPilier = {for (final p in Pilier.values) p: 0};

  for (final transaction in transactions) {
    final memeMois =
        transaction.date.year == reference.year &&
        transaction.date.month == reference.month;
    if (!memeMois) continue;

    if (transaction.type == TypeMouvement.entree) {
      totalEntrees += transaction.montant;
      continue;
    }

    final pilier = categorieParId[transaction.categorieId]?.pilier;
    if (pilier != null) {
      depensesParPilier[pilier] =
          (depensesParPilier[pilier] ?? 0) + transaction.montant;
    }
  }

  return Pilier.values.map((pilier) {
    final cible = pourcentagesCibles[pilier]!;
    final objectifMontant = (totalEntrees * cible).round();
    final reel = depensesParPilier[pilier] ?? 0;
    // Sans entrées ce mois-ci, un objectif de 0 F rendrait la division
    // par zéro absurde : toute dépense est alors considérée "dépassée".
    final progression = objectifMontant > 0
        ? reel / objectifMontant
        : (reel > 0 ? 1.0 : 0.0);
    return (
      pilier: pilier,
      montantReel: reel,
      objectifMontant: objectifMontant,
      progression: progression,
    );
  }).toList();
}
