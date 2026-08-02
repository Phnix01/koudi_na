import 'package:intl/intl.dart';

/// Formate un montant en FCFA : entier, jamais de décimale, espace
/// insécable comme séparateur de milliers (section 1.3). La locale
/// `fr_FR` d'`intl` utilise déjà cet espace par défaut pour les milliers.
String formaterMontant(int montant) {
  return '${NumberFormat.decimalPattern('fr_FR').format(montant)} F';
}
