import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';

/// Solde du mois en cours : entrées moins dépenses (section 4, écran A).
/// Fonction pure — aucun accès à Hive ici — pour rester facilement
/// testable indépendamment du stockage.
int calculerSoldeDuMois(List<Transaction> transactions, {DateTime? maintenant}) {
  final reference = maintenant ?? DateTime.now();
  var solde = 0;
  for (final transaction in transactions) {
    final memeAnnee = transaction.date.year == reference.year;
    final memeMois = transaction.date.month == reference.month;
    if (memeAnnee && memeMois) {
      solde += transaction.type == TypeMouvement.entree ? transaction.montant : -transaction.montant;
    }
  }
  return solde;
}
