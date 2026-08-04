import 'package:uuid/uuid.dart';

import '../models/transaction.dart';
import '../repositories/recurrence_repository.dart';
import '../repositories/transaction_repository.dart';

/// Génère les transactions du mois pour chaque récurrence active dont
/// le jour est arrivé — appelée une fois au démarrage (comme le seed).
/// Idempotent : une récurrence qui a déjà généré sa transaction ce
/// mois-ci (retrouvée via `recurrenteId`) n'en recrée pas une seconde.
Future<void> genererTransactionsRecurrentesSiNecessaire({
  required RecurrenceRepository recurrences,
  required TransactionRepository transactions,
  DateTime? maintenant,
}) async {
  final reference = maintenant ?? DateTime.now();
  final toutesLesTransactions = transactions.tous();
  final recurrencesDejaGenereesCeMoisCi = toutesLesTransactions
      .where(
        (t) =>
            t.recurrenteId != null &&
            t.date.year == reference.year &&
            t.date.month == reference.month,
      )
      .map((t) => t.recurrenteId)
      .toSet();

  final dernierJourDuMois = DateTime(
    reference.year,
    reference.month + 1,
    0,
  ).day;

  for (final recurrence in recurrences.tous()) {
    if (!recurrence.active) continue;
    if (recurrencesDejaGenereesCeMoisCi.contains(recurrence.id)) continue;

    final jour = recurrence.jourDuMois.clamp(1, dernierJourDuMois);
    if (jour > reference.day) {
      continue; // le jour n'est pas encore arrivé ce mois-ci
    }

    await transactions.enregistrer(
      Transaction(
        id: const Uuid().v4(),
        date: DateTime(reference.year, reference.month, jour),
        type: recurrence.type,
        montant: recurrence.montant,
        categorieId: recurrence.categorieId,
        compteId: recurrence.compteId,
        recurrenteId: recurrence.id,
      ),
    );
  }
}
