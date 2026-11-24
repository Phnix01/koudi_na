import '../../data/models/categorie.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/gamification_repository.dart';
import 'calcul_piliers.dart';
import 'evaluation_badges.dart';
import 'serie_quotidienne.dart';

/// Après une saisie active (jamais une récurrence générée) : prolonge la
/// série, débloque les badges dont la condition vient d'être remplie et
/// renvoie leurs ids, pour que l'écran affiche la carte de déblocage.
Future<List<String>> enregistrerActiviteEtBadges({
  required GamificationRepository gamification,
  required List<Transaction> transactions,
  required List<Categorie> categories,
  DateTime? maintenant,
}) async {
  final reference = maintenant ?? DateTime.now();
  final nouvelleSerie = calculerNouvelleSerie(
    gamification.derniereActivite,
    reference,
    gamification.serieCourante,
  );
  await gamification.enregistrerActivite(reference, nouvelleSerie);

  final nouveauxBadges = evaluerBadges((
    serieCourante: nouvelleSerie,
    totalTransactions: transactions.length,
    progressionMoisCourant: calculerProgressionPiliers(
      transactions,
      categories,
      maintenant: reference,
    ),
  ), gamification.badgesDebloques);
  if (nouveauxBadges.isNotEmpty) {
    await gamification.debloquerBadges(nouveauxBadges);
  }
  return nouveauxBadges;
}
