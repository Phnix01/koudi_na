import 'package:flutter/painting.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../data/models/categorie.dart';
import '../../data/models/compte.dart';
import '../../data/seed/libelles_seed.dart';
import '../constants/icones.dart';
import 'couleur_utils.dart';

/// Fonds teintés des couleurs de la palette du brief (§2). Une couleur
/// choisie hors palette par l'utilisateur reçoit une teinte calculée.
const Map<String, int> _teintes = {
  '#B45309': 0xFFFDF1DF,
  '#2F5BD3': 0xFFE6EDFB,
  '#7C4DCC': 0xFFF0E9FB,
  '#C2410C': 0xFFFCEAE2,
  '#BE3A78': 0xFFFBE7F0,
  '#0E7A4F': 0xFFE0F1E8,
  '#0F766E': 0xFFDEF2EF,
  '#1D4ED8': 0xFFE4ECFC,
  '#BE123C': 0xFFFBE4E9,
  '#A16207': 0xFFFBF1D9,
  '#8A6A2F': 0xFFF3ECDF,
  '#5F5F66': 0xFFECECE8,
};

Color teinteDe(String hex) {
  final connue = _teintes[hex.toUpperCase()];
  if (connue != null) return Color(connue);
  return Color.alphaBlend(depuisHex(hex).withValues(alpha: 0.12), const Color(0xFFFFFFFF));
}

PhosphorIconData iconeDe(String code) => icones[code] ?? PhosphorIconsRegular.dotsThree;

extension VisuelCategorie on Categorie {
  String get nom => libelleAffiche(id, libelle);

  /// Nom dans une langue donnée (exports CSV, Excel, PDF).
  String nomDans(String langue) => libelleAffiche(id, libelle, langue: langue);

  /// Pour les tuiles de la grille de saisie (« Repas », « Logement »…).
  String get nomCourt => libelleAffiche(id, libelle, court: true);
  Color get couleur => depuisHex(couleurHex);
  Color get teinte => teinteDe(couleurHex);
  PhosphorIconData get icone => iconeDe(iconeCode);
}

extension VisuelCompte on Compte {
  String get nom => libelleAffiche(id, libelle);
  String nomDans(String langue) => libelleAffiche(id, libelle, langue: langue);
  PhosphorIconData get icone => iconeDe(iconeCode);
}
