import '../../data/models/categorie.dart';
import '../../data/models/transaction.dart';

/// Fait remonter en tête les catégories les plus utilisées sur les 30
/// derniers jours (section 4, écran A) : à saisie répétée, les bonnes
/// icônes arrivent sous le pouce sans qu'il faille chercher.
List<Categorie> trierCategoriesParFrequence(
  List<Categorie> categories,
  List<Transaction> transactions, {
  DateTime? maintenant,
}) {
  final reference = maintenant ?? DateTime.now();
  final depuis = reference.subtract(const Duration(days: 30));

  final compteurs = <String, int>{};
  for (final transaction in transactions) {
    if (transaction.date.isAfter(depuis)) {
      compteurs[transaction.categorieId] =
          (compteurs[transaction.categorieId] ?? 0) + 1;
    }
  }

  final resultat = [...categories];
  resultat.sort((a, b) {
    final frequenceA = compteurs[a.id] ?? 0;
    final frequenceB = compteurs[b.id] ?? 0;
    if (frequenceA != frequenceB) return frequenceB.compareTo(frequenceA);
    return a.ordre.compareTo(b.ordre);
  });
  return resultat;
}
