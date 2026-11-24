import 'package:flutter/material.dart';

import 'koudi_tokens.dart';

/// Alias hérités de l'ancien thème sombre, remappés sur la palette claire
/// de la refonte D (voir [KoudiTokens]) pour que les écrans pas encore
/// refondus restent cohérents. Le nouveau code lit `context.tokens`.
abstract final class AppColors {
  static const _t = KoudiTokens.clair;

  static const bg = Color(0xFFF5F5F2);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceHigh = Color(0xFFEAEAE5);

  /// L'ancien teal : devient l'accent unique de la refonte (vert).
  static const primary = Color(0xFF0E7A4F);

  /// L'ancien or : flamme de la série, badges, mises en avant chaudes.
  static const accent = Color(0xFFC2410C);
  static const accentRose = Color(0xFFBE3A78);
  static const accentBleu = Color(0xFF2F5BD3);

  static const positive = Color(0xFF0E7A4F);
  static const negative = Color(0xFFC2410C);
  static const avertissement = Color(0xFFC2410C);

  static const textPrimary = Color(0xFF111113);
  static const textMuted = Color(0xFF6E6E73);

  static Color get ink => _t.ink;
}
