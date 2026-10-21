import 'dart:ui';

import 'package:intl/intl.dart';

import 'app_localizations.dart';

/// Langue de repli : celle du cahier des charges, et celle qu'on prend
/// quand le téléphone est réglé sur une langue non supportée.
const Locale localeParDefaut = Locale('fr');

/// Résout la langue effective de l'application : celle choisie dans
/// Réglages si elle existe, sinon celle du téléphone si on la supporte,
/// sinon le français.
Locale resoudreLocale(String? codeChoisi) {
  if (codeChoisi != null) return Locale(codeChoisi);
  final systeme = PlatformDispatcher.instance.locale;
  final supportee = AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == systeme.languageCode,
  );
  return supportee ? Locale(systeme.languageCode) : localeParDefaut;
}

/// Aligne `intl` sur la langue de l'application : tous les
/// `DateFormat` et `NumberFormat` créés sans locale explicite (noms de
/// mois, séparateur de milliers...) suivent alors automatiquement le
/// choix de l'utilisateur, sans passer un paramètre de langue partout.
void appliquerLocaleIntl(Locale locale) {
  Intl.defaultLocale = locale.languageCode;
}
