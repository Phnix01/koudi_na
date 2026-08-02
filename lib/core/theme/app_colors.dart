import 'package:flutter/material.dart';

/// Jetons de couleur de KUDI (section 3.1 du cahier des charges).
///
/// Regrouper les couleurs ici plutôt que de les écrire "en dur" dans
/// chaque écran permet de changer l'identité visuelle en un seul endroit.
abstract final class AppColors {
  static const bg = Color(0xFF0B0F14);
  static const surface = Color(0xFF151B23);
  static const surfaceHigh = Color(0xFF1E2732);

  static const primary = Color(0xFF00C2A8);
  static const accent = Color(0xFFC9971E);

  static const positive = Color(0xFF2ECC71);
  static const negative = Color(0xFFE74C3C);
  // Pas dans les tokens de la section 3.1 : ajouté pour l'état "proche
  // de la cible" des barres 40/25/35 (section 4, écran B), entre le vert
  // et le rouge.
  static const avertissement = Color(0xFFF2994A);

  static const textPrimary = Color(0xFFF2F5F8);
  static const textMuted = Color(0xFF8A97A6);
}
