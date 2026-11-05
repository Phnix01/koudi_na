import 'package:flutter/foundation.dart';

import '../../l10n/app_localizations.dart';

/// Devises proposées à l'onboarding et dans Réglages. XOF reste la
/// devise par défaut (comportement historique de l'app, zone UEMOA) ;
/// les autres couvrent les cibles à l'international : francophones hors
/// zone UEMOA (XAF, EUR, CHF, CAD), Maghreb (MAD, DZD, TND), puis
/// anglophones (GBP, USD, NGN, GHS).
enum Devise { xof, xaf, eur, chf, cad, mad, dzd, tnd, gbp, usd, ngn, ghs }

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
  // XAF (zone CEMAC) partage le même nom d'usage « FCFA » que le XOF
  // (zone UEMOA) dans le langage courant, malgré deux monnaies
  // distinctes : seule la liste de sélection les distingue (par le nom
  // de la zone), pas l'affichage d'un montant au quotidien.
  Devise.xaf: DeviseInfo(code: 'XAF', symbole: 'FCFA', avantLeMontant: false),
  Devise.eur: DeviseInfo(code: 'EUR', symbole: '€', avantLeMontant: false),
  Devise.chf: DeviseInfo(code: 'CHF', symbole: 'CHF', avantLeMontant: true),
  // "C$" plutôt que "$" seul : évite la confusion avec le dollar
  // américain, qui garde le symbole "$" nu (le plus répandu des deux).
  Devise.cad: DeviseInfo(code: 'CAD', symbole: 'C\$', avantLeMontant: true),
  Devise.mad: DeviseInfo(code: 'MAD', symbole: 'DH', avantLeMontant: false),
  Devise.dzd: DeviseInfo(code: 'DZD', symbole: 'DA', avantLeMontant: false),
  Devise.tnd: DeviseInfo(code: 'TND', symbole: 'DT', avantLeMontant: false),
  Devise.gbp: DeviseInfo(code: 'GBP', symbole: '£', avantLeMontant: true),
  Devise.usd: DeviseInfo(code: 'USD', symbole: '\$', avantLeMontant: true),
  Devise.ngn: DeviseInfo(code: 'NGN', symbole: '₦', avantLeMontant: true),
  Devise.ghs: DeviseInfo(code: 'GHS', symbole: 'GH₵', avantLeMontant: true),
};

/// Devise avant l'introduction du choix : les installations existantes
/// ne doivent rien voir changer tant que l'utilisateur ne choisit pas
/// explicitement autre chose.
const deviseParDefaut = Devise.xof;

Devise deviseDepuisCode(String? code) => Devise.values.firstWhere(
  (d) => devisesDisponibles[d]!.code == code,
  orElse: () => deviseParDefaut,
);

/// Nom localisé d'une devise, pour la liste de sélection (onboarding
/// et Réglages) — le symbole seul ne suffit pas à distinguer XOF et
/// XAF, tous deux affichés "FCFA".
String libelleDevise(AppLocalizations l10n, Devise devise) {
  switch (devise) {
    case Devise.xof:
      return l10n.deviseXof;
    case Devise.xaf:
      return l10n.deviseXaf;
    case Devise.eur:
      return l10n.deviseEur;
    case Devise.chf:
      return l10n.deviseChf;
    case Devise.cad:
      return l10n.deviseCad;
    case Devise.mad:
      return l10n.deviseMad;
    case Devise.dzd:
      return l10n.deviseDzd;
    case Devise.tnd:
      return l10n.deviseTnd;
    case Devise.gbp:
      return l10n.deviseGbp;
    case Devise.usd:
      return l10n.deviseUsd;
    case Devise.ngn:
      return l10n.deviseNgn;
    case Devise.ghs:
      return l10n.deviseGhs;
  }
}
