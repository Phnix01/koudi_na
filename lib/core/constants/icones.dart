import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Associe une clé stable (celle stockée dans Hive via `iconeCode`) à
/// une icône Phosphor. On stocke une clé texte plutôt que le code
/// Unicode brut de l'icône : Phosphor réutilise les mêmes codes entre
/// ses styles (thin/regular/fill...), un entier seul ne suffirait pas
/// à identifier l'icône sans ambiguïté.
const Map<String, PhosphorIconData> icones = {
  // Catégories de dépenses
  'bowlFood': PhosphorIconsFill.bowlFood,
  'car': PhosphorIconsFill.car,
  'wifiHigh': PhosphorIconsFill.wifiHigh,
  'house': PhosphorIconsFill.house,
  'usersThree': PhosphorIconsFill.usersThree,
  'piggyBank': PhosphorIconsFill.piggyBank,
  'rocketLaunch': PhosphorIconsFill.rocketLaunch,
  'bookOpen': PhosphorIconsFill.bookOpen,
  'heartbeat': PhosphorIconsFill.heartbeat,
  'tShirt': PhosphorIconsFill.tShirt,
  'mosque': PhosphorIconsFill.mosque,
  'dotsThreeOutline': PhosphorIconsFill.dotsThreeOutline,

  // Catégories d'entrées
  'wallet': PhosphorIconsFill.wallet,
  'fileText': PhosphorIconsFill.fileText,
  'laptop': PhosphorIconsFill.laptop,
  'storefront': PhosphorIconsFill.storefront,
  'plusCircle': PhosphorIconsFill.plusCircle,

  // Comptes
  'coins': PhosphorIconsFill.coins,
  'bank': PhosphorIconsFill.bank,
  'deviceMobile': PhosphorIconsFill.deviceMobile,
  'vault': PhosphorIconsFill.vault,
};
