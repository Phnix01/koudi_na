import 'package:flutter/foundation.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Un badge à débloquer (écran Badges, section gamification). Nommé
/// `BadgeInfo` et non `Badge` : ce dernier nom est déjà pris par le
/// widget `Badge` de Material, que l'écran des badges devra aussi
/// importer. Les noms et descriptions sont des champs Dart simples
/// plutôt que des clés ARB, même principe que `devises.dart` : à cette
/// échelle, passer par `AppLocalizations` n'apporterait rien et
/// alourdirait les fichiers de traduction pour rien.
@immutable
class BadgeInfo {
  const BadgeInfo({
    required this.id,
    required this.icone,
    required this.titreFr,
    required this.titreEn,
    required this.descriptionFr,
    required this.descriptionEn,
  });

  final String id;
  final PhosphorIconData icone;
  final String titreFr;
  final String titreEn;
  final String descriptionFr;
  final String descriptionEn;
}

/// Les conditions de déblocage ne sont pas ici : elles vivent dans
/// `evaluation_badges.dart`, la seule à savoir lire une série, un
/// nombre de transactions ou une progression de pilier.
const List<BadgeInfo> badgesDisponibles = [
  BadgeInfo(
    id: 'premiere_transaction',
    icone: PhosphorIconsFill.star,
    titreFr: 'Premier pas',
    titreEn: 'First step',
    descriptionFr: 'Enregistrer une première transaction.',
    descriptionEn: 'Record your first transaction.',
  ),
  BadgeInfo(
    id: 'serie_3',
    icone: PhosphorIconsFill.flame,
    titreFr: '3 jours de suite',
    titreEn: '3 days in a row',
    descriptionFr: 'Enregistrer une transaction 3 jours consécutifs.',
    descriptionEn: 'Record a transaction on 3 consecutive days.',
  ),
  BadgeInfo(
    id: 'serie_7',
    icone: PhosphorIconsFill.flame,
    titreFr: 'Une semaine',
    titreEn: 'One week',
    descriptionFr: 'Enregistrer une transaction 7 jours consécutifs.',
    descriptionEn: 'Record a transaction on 7 consecutive days.',
  ),
  BadgeInfo(
    id: 'serie_30',
    icone: PhosphorIconsFill.flame,
    titreFr: 'Un mois entier',
    titreEn: 'A full month',
    descriptionFr: 'Enregistrer une transaction 30 jours consécutifs.',
    descriptionEn: 'Record a transaction on 30 consecutive days.',
  ),
  BadgeInfo(
    id: 'serie_100',
    icone: PhosphorIconsFill.fire,
    titreFr: '100 jours de suite',
    titreEn: '100 days in a row',
    descriptionFr: 'Enregistrer une transaction 100 jours consécutifs.',
    descriptionEn: 'Record a transaction on 100 consecutive days.',
  ),
  BadgeInfo(
    id: 'transactions_50',
    icone: PhosphorIconsFill.notebook,
    titreFr: '50 transactions',
    titreEn: '50 transactions',
    descriptionFr: 'Enregistrer 50 transactions au total.',
    descriptionEn: 'Record 50 transactions in total.',
  ),
  BadgeInfo(
    id: 'transactions_200',
    icone: PhosphorIconsFill.notebook,
    titreFr: '200 transactions',
    titreEn: '200 transactions',
    descriptionFr: 'Enregistrer 200 transactions au total.',
    descriptionEn: 'Record 200 transactions in total.',
  ),
  BadgeInfo(
    id: 'mois_equilibre',
    icone: PhosphorIconsFill.scales,
    titreFr: 'Mois équilibré',
    titreEn: 'Balanced month',
    descriptionFr: 'Respecter les 3 piliers 40/25/35 sur un mois.',
    descriptionEn:
        'Stay within all 3 pillars of the 40/25/35 rule for a month.',
  ),
  BadgeInfo(
    id: 'epargne_respectee',
    icone: PhosphorIconsFill.piggyBank,
    titreFr: 'Épargne respectée',
    titreEn: 'Savings on track',
    descriptionFr: "Respecter l'objectif d'épargne du mois.",
    descriptionEn: "Stay within this month's savings target.",
  ),
];

String titreBadge(BadgeInfo badge, String langue) =>
    langue == 'en' ? badge.titreEn : badge.titreFr;

String descriptionBadge(BadgeInfo badge, String langue) =>
    langue == 'en' ? badge.descriptionEn : badge.descriptionFr;
