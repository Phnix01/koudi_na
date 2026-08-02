import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';

/// Un jour du mois avec ses transactions et leur total signé
/// (entrées positives, dépenses négatives) — section 4, écran B.
typedef JourneeTransactions = ({
  DateTime jour,
  List<Transaction> transactions,
  int total,
});

/// Regroupe des transactions par jour, du plus récent au plus ancien.
/// Fonction pure — aucun accès à Hive ici — pour rester facilement
/// testable indépendamment du stockage.
List<JourneeTransactions> grouperParJour(List<Transaction> transactions) {
  final parJour = <DateTime, List<Transaction>>{};
  for (final transaction in transactions) {
    final jour = DateTime(
      transaction.date.year,
      transaction.date.month,
      transaction.date.day,
    );
    parJour.putIfAbsent(jour, () => []).add(transaction);
  }

  final jours = parJour.keys.toList()..sort((a, b) => b.compareTo(a));
  return jours.map((jour) {
    final transactionsDuJour = parJour[jour]!;
    final total = transactionsDuJour.fold<int>(0, (somme, t) {
      return somme + (t.type == TypeMouvement.entree ? t.montant : -t.montant);
    });
    return (jour: jour, transactions: transactionsDuJour, total: total);
  }).toList();
}
