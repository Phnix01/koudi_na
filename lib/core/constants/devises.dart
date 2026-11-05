import 'package:flutter/foundation.dart';

/// Devises proposées à l'onboarding et dans Réglages. XOF reste la
/// devise par défaut (comportement historique de l'app, zone UEMOA) ;
/// EUR/USD/GBP couvrent les deux premières cibles à l'international :
/// francophones hors zone CFA, puis anglophones.
enum Devise { xof, eur, usd, gbp }

@immutable
class DeviseInfo {
  const DeviseInfo({
    required this.code,
    required this.symbole,
    required this.avantLeMontant,
  });

  /// Code ISO 4217 : clé de stockage dans Réglages (Hive), stable même
  /// si l'ordre de l'enum change.
  final String code;

  /// Signe ou abréviation affiché à côté du montant.
  final String symbole;

  /// `true` pour « $ 2 500 », `false` pour « 2 500 FCFA » — convention
  /// d'affichage usuelle de chaque devise.
  final bool avantLeMontant;
}

const devisesDisponibles = {
  Devise.xof: DeviseInfo(code: 'XOF', symbole: 'FCFA', avantLeMontant: false),
  Devise.eur: DeviseInfo(code: 'EUR', symbole: '€', avantLeMontant: false),
  Devise.usd: DeviseInfo(code: 'USD', symbole: '\$', avantLeMontant: true),
  Devise.gbp: DeviseInfo(code: 'GBP', symbole: '£', avantLeMontant: true),
};

/// Devise avant l'introduction du choix : les installations existantes
/// ne doivent rien voir changer tant que l'utilisateur ne choisit pas
/// explicitement autre chose.
const deviseParDefaut = Devise.xof;

Devise deviseDepuisCode(String? code) => Devise.values.firstWhere(
  (d) => devisesDisponibles[d]!.code == code,
  orElse: () => deviseParDefaut,
);
