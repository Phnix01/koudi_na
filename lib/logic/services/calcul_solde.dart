import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';

/// Un "record" Dart (pas de classe à déclarer) pour regrouper les trois
/// totaux du mois : léger, immuable, et auto-documenté par les noms de
/// champs (`totaux.entrees` plutôt qu'un `Map` avec des clés magiques).
typedef TotauxMois = ({int entrees, int depenses, int solde});

/// Totaux du mois en cours : entrées, dépenses, solde (sections 4 et 6).
/// Fonction pure — aucun accès à Hive ici — pour rester facilement
/// testable indépendamment du stockage.
TotauxMois calculerTotauxDuMois(
  List<Transaction> transactions, {
  DateTime? maintenant,
}) {
  final reference = maintenant ?? DateTime.now();
  var entrees = 0;
  var depenses = 0;
  for (final transaction in transactions) {
    final memeAnnee = transaction.date.year == reference.year;
    final memeMois = transaction.date.month == reference.month;
    if (memeAnnee && memeMois) {
      if (transaction.type == TypeMouvement.entree) {
        entrees += transaction.montant;
      } else {
        depenses += transaction.montant;
      }
    }
  }
  return (entrees: entrees, depenses: depenses, solde: entrees - depenses);
}
