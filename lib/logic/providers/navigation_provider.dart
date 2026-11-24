import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onglet affiché par la barre du bas : 0 Accueil, 1 Journal, 2 Analyse,
/// 3 Réglages (le + central n'est pas un onglet).
final ongletProvider = StateProvider<int>((ref) => 0);

/// Mois consulté, partagé par l'Accueil et le Journal : choisir octobre
/// sur l'un le montre aussi sur l'autre.
final moisAfficheProvider = StateProvider<DateTime>((ref) {
  final maintenant = DateTime.now();
  return DateTime(maintenant.year, maintenant.month);
});
