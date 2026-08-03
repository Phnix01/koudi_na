import '../../data/models/categorie.dart';
import '../../data/models/pilier.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';

/// Dépenses d'un mois, réparties par pilier (section 5.1, graphique 7).
typedef MoisPiliers = ({DateTime mois, int epargne, int famille, int vie});

/// Les [nombreDeMois] derniers mois, du plus ancien au plus récent —
/// même les mois sans dépense apparaissent, à zéro. Fonction pure —
/// aucun accès à Hive ici.
List<MoisPiliers> calculerEquilibrePiliers(
  List<Transaction> transactions,
  List<Categorie> categories, {
  DateTime? maintenant,
  int nombreDeMois = 6,
}) {
  final reference = maintenant ?? DateTime.now();
  final categorieParId = {for (final c in categories) c.id: c};
  final moisDeDepart = DateTime(
    reference.year,
    reference.month - (nombreDeMois - 1),
  );

  final parMois = <DateTime, Map<Pilier, int>>{
    for (var i = 0; i < nombreDeMois; i++)
      DateTime(moisDeDepart.year, moisDeDepart.month + i): {
        for (final pilier in Pilier.values) pilier: 0,
      },
  };

  for (final transaction in transactions) {
    if (transaction.type != TypeMouvement.depense) continue;
    final pilier = categorieParId[transaction.categorieId]?.pilier;
    if (pilier == null) continue;

    final mois = DateTime(transaction.date.year, transaction.date.month);
    final donneesDuMois = parMois[mois];
    if (donneesDuMois == null) {
      continue; // hors de la fenêtre des nombreDeMois derniers mois
    }

    donneesDuMois[pilier] = donneesDuMois[pilier]! + transaction.montant;
  }

  final moisTries = parMois.keys.toList()..sort();
  return [
    for (final mois in moisTries)
      (
        mois: mois,
        epargne: parMois[mois]![Pilier.epargne]!,
        famille: parMois[mois]![Pilier.famille]!,
        vie: parMois[mois]![Pilier.vie]!,
      ),
  ];
}
