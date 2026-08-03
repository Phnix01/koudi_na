import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';

/// Une grille 7 (jours) × 4 (moments de la journée) des montants
/// dépensés, plus le montant maximal d'une cellule — pour normaliser
/// l'intensité de couleur au moment de dessiner (section 5.1, graphique 5).
typedef GrilleHabitudes = ({List<List<int>> montants, int maxMontant});

/// Fenêtre glissante de 90 jours plutôt que tout l'historique : on
/// veut des habitudes *actuelles*, pas biaisées par un mode de vie
/// d'il y a deux ans. Fonction pure — aucun accès à Hive ici.
GrilleHabitudes calculerHabitudesHebdomadaires(
  List<Transaction> transactions, {
  DateTime? maintenant,
  int nombreDeJours = 90,
}) {
  final reference = maintenant ?? DateTime.now();
  final depuis = reference.subtract(Duration(days: nombreDeJours));

  // Lignes : lundi (0) à dimanche (6). Colonnes : matin/après-midi/soir/nuit.
  final montants = List.generate(7, (_) => List.filled(4, 0));

  for (final transaction in transactions) {
    if (transaction.type != TypeMouvement.depense) continue;
    if (transaction.date.isBefore(depuis) ||
        transaction.date.isAfter(reference)) {
      continue;
    }

    final jour =
        transaction.date.weekday - 1; // DateTime.weekday : 1=lundi..7=dimanche
    final moment = _moment(transaction.date.hour);
    montants[jour][moment] += transaction.montant;
  }

  var maxMontant = 0;
  for (final ligne in montants) {
    for (final valeur in ligne) {
      if (valeur > maxMontant) maxMontant = valeur;
    }
  }

  return (montants: montants, maxMontant: maxMontant);
}

/// 0=matin (6h-12h), 1=après-midi (12h-18h), 2=soir (18h-24h), 3=nuit (0h-6h).
int _moment(int heure) {
  if (heure < 6) return 3;
  if (heure < 12) return 0;
  if (heure < 18) return 1;
  return 2;
}
