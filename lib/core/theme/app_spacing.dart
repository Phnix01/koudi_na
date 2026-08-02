/// Échelle d'espacement (section 3.1) : toujours un multiple de 4.
///
/// Utiliser ces constantes plutôt que des nombres arbitraires garantit
/// que les marges restent cohérentes d'un écran à l'autre.
abstract final class AppSpacing {
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s24 = 24.0;
  static const s32 = 32.0;

  /// Rayon standard des cartes et des feuilles modales.
  static const radius = 20.0;
}
