import '../../data/models/categorie.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';

/// Le poids d'une catégorie dans les dépenses du mois (section 5.1).
typedef PartCategorie = ({Categorie categorie, int montant, double part});

/// Dépenses du mois groupées par catégorie, triées de la plus grosse à
/// la plus petite. Fonction pure — aucun accès à Hive ici.
List<PartCategorie> calculerRepartitionDepenses(
  List<Transaction> transactions,
  List<Categorie> categories, {
  DateTime? maintenant,
}) {
  final reference = maintenant ?? DateTime.now();
  final categorieParId = {for (final c in categories) c.id: c};

  final montantsParCategorie = <String, int>{};
  var total = 0;
  for (final transaction in transactions) {
    final memeMois =
        transaction.date.year == reference.year &&
        transaction.date.month == reference.month;
    if (!memeMois || transaction.type != TypeMouvement.depense) continue;
    montantsParCategorie[transaction.categorieId] =
        (montantsParCategorie[transaction.categorieId] ?? 0) +
        transaction.montant;
    total += transaction.montant;
  }

  final resultat = <PartCategorie>[];
  montantsParCategorie.forEach((categorieId, montant) {
    final categorie = categorieParId[categorieId];
    if (categorie == null) {
      return; // catégorie introuvable : ignorée du graphique
    }
    resultat.add((
      categorie: categorie,
      montant: montant,
      part: total > 0 ? montant / total : 0,
    ));
  });
  resultat.sort((a, b) => b.montant.compareTo(a.montant));
  return resultat;
}
