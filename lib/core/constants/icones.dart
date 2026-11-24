import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Associe une clé stable (celle stockée dans Hive via `iconeCode`) à
/// une icône Phosphor. On stocke une clé texte plutôt que le code
/// Unicode brut de l'icône : Phosphor réutilise les mêmes codes entre
/// ses styles (thin/regular/fill...), un entier seul ne suffirait pas
/// à identifier l'icône sans ambiguïté.
///
/// Refonte D : un seul jeu, linéaire (*regular*). Les clés des versions
/// précédentes restent, des catégories créées par l'utilisateur peuvent
/// encore s'en servir.
const Map<String, PhosphorIconData> icones = {
  // Catégories de dépenses
  'bowlFood': PhosphorIconsRegular.bowlFood,
  'car': PhosphorIconsRegular.car,
  'wifiHigh': PhosphorIconsRegular.wifiHigh,
  'house': PhosphorIconsRegular.house,
  'users': PhosphorIconsRegular.users,
  'piggyBank': PhosphorIconsRegular.piggyBank,
  'trendUp': PhosphorIconsRegular.trendUp,
  'bookOpen': PhosphorIconsRegular.bookOpen,
  'heart': PhosphorIconsRegular.heart,
  'tShirt': PhosphorIconsRegular.tShirt,
  'moon': PhosphorIconsRegular.moon,
  'dotsThree': PhosphorIconsRegular.dotsThree,

  // Catégories d'entrées
  'handshake': PhosphorIconsRegular.handshake,
  'laptop': PhosphorIconsRegular.laptop,
  'storefront': PhosphorIconsRegular.storefront,
  'gift': PhosphorIconsRegular.gift,

  // Comptes
  'coins': PhosphorIconsRegular.coins,
  'bank': PhosphorIconsRegular.bank,
  'deviceMobile': PhosphorIconsRegular.deviceMobile,
  'vault': PhosphorIconsRegular.vault,

  // Clés des versions précédentes
  'usersThree': PhosphorIconsRegular.usersThree,
  'rocketLaunch': PhosphorIconsRegular.rocketLaunch,
  'heartbeat': PhosphorIconsRegular.heartbeat,
  'mosque': PhosphorIconsRegular.mosque,
  'dotsThreeOutline': PhosphorIconsRegular.dotsThreeOutline,
  'wallet': PhosphorIconsRegular.wallet,
  'fileText': PhosphorIconsRegular.fileText,
  'plusCircle': PhosphorIconsRegular.plusCircle,
};
