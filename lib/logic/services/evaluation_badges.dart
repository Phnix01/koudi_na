import '../../data/models/pilier.dart';
import 'calcul_piliers.dart';

/// Les données nécessaires pour vérifier si un nouveau badge vient
/// d'être débloqué, après une saisie active.
typedef ContexteBadges = ({
  int serieCourante,
  int totalTransactions,
  List<ProgressionPilier> progressionMoisCourant,
});

/// Fonction pure : renvoie les ids des badges qui viennent d'être
/// débloqués (c'est-à-dire dont la condition est remplie mais qui ne
/// sont pas encore dans [dejaDebloques]). Les conditions vivent ici,
/// pas dans la table statique `badges.dart` (un `const` Dart s'y
/// prêterait mal).
List<String> evaluerBadges(ContexteBadges contexte, Set<String> dejaDebloques) {
  final piliersRespectes = contexte.progressionMoisCourant.every(
    (p) => p.progression <= 1.0,
  );
  final epargneRespectee = contexte.progressionMoisCourant.any(
    (p) => p.pilier == Pilier.epargne && p.progression <= 1.0,
  );

  final candidats = <String, bool>{
    'premiere_transaction': contexte.totalTransactions >= 1,
    'serie_3': contexte.serieCourante >= 3,
    'serie_7': contexte.serieCourante >= 7,
    'serie_30': contexte.serieCourante >= 30,
    'serie_100': contexte.serieCourante >= 100,
    'transactions_50': contexte.totalTransactions >= 50,
    'transactions_200': contexte.totalTransactions >= 200,
    'mois_equilibre': piliersRespectes,
    'epargne_respectee': epargneRespectee,
  };

  return candidats.entries
      .where((entree) => entree.value && !dejaDebloques.contains(entree.key))
      .map((entree) => entree.key)
      .toList();
}
