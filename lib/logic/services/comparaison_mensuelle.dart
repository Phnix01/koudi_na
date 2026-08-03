import '../../data/models/categorie.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';

/// Dépenses d'une catégorie ce mois-ci et le mois précédent, avec la
/// variation en pourcentage (section 5.1 et 5.2). `variationPourcent`
/// est `null` quand la catégorie n'avait aucune dépense le mois
/// précédent : une variation en pourcentage depuis zéro n'a pas de sens.
typedef ComparaisonCategorie = ({
  Categorie categorie,
  int moisCourant,
  int moisPrecedent,
  double? variationPourcent,
});

/// Triée par dépense du mois courant, décroissante. Fonction pure —
/// aucun accès à Hive ici.
List<ComparaisonCategorie> calculerComparaisonMensuelle(
  List<Transaction> transactions,
  List<Categorie> categories, {
  DateTime? maintenant,
}) {
  final reference = maintenant ?? DateTime.now();
  final moisPrecedentRef = DateTime(reference.year, reference.month - 1);
  final categorieParId = {for (final c in categories) c.id: c};

  final moisCourantParCategorie = <String, int>{};
  final moisPrecedentParCategorie = <String, int>{};

  for (final transaction in transactions) {
    if (transaction.type != TypeMouvement.depense) continue;
    if (transaction.date.year == reference.year &&
        transaction.date.month == reference.month) {
      moisCourantParCategorie[transaction.categorieId] =
          (moisCourantParCategorie[transaction.categorieId] ?? 0) +
          transaction.montant;
    } else if (transaction.date.year == moisPrecedentRef.year &&
        transaction.date.month == moisPrecedentRef.month) {
      moisPrecedentParCategorie[transaction.categorieId] =
          (moisPrecedentParCategorie[transaction.categorieId] ?? 0) +
          transaction.montant;
    }
  }

  final idsCategories = {
    ...moisCourantParCategorie.keys,
    ...moisPrecedentParCategorie.keys,
  };
  final resultat = <ComparaisonCategorie>[];
  for (final id in idsCategories) {
    final categorie = categorieParId[id];
    if (categorie == null) continue; // catégorie introuvable : ignorée
    final courant = moisCourantParCategorie[id] ?? 0;
    final precedent = moisPrecedentParCategorie[id] ?? 0;
    final variation = precedent > 0
        ? ((courant - precedent) / precedent) * 100
        : null;
    resultat.add((
      categorie: categorie,
      moisCourant: courant,
      moisPrecedent: precedent,
      variationPourcent: variation,
    ));
  }
  resultat.sort((a, b) => b.moisCourant.compareTo(a.moisCourant));
  return resultat;
}
