import 'package:flutter/material.dart';

/// Jetons de la refonte « D · Fusion » (koudina-refonte-D/BRIEF_REFONTE_D.md
/// §2). Les écrans les lisent via `context.tokens`, jamais en dur : la
/// variante sombre est déjà déclarée et n'aura qu'à être branchée.
@immutable
class KoudiTokens extends ThemeExtension<KoudiTokens> {
  const KoudiTokens({
    required this.bg,
    required this.surface,
    required this.surfaceMuted,
    required this.track,
    required this.line,
    required this.lineStrong,
    required this.ink,
    required this.onInk,
    required this.ink2,
    required this.muted,
    required this.tileLabel,
    required this.disabled,
    required this.ctaDisabled,
    required this.handle,
    required this.positive,
    required this.positiveTint,
    required this.family,
    required this.streak,
    required this.scrim,
  });

  final Color bg;
  final Color surface;
  final Color surfaceMuted;
  final Color track;
  final Color line;
  final Color lineStrong;

  /// Texte principal, CTA, bouton +, élément sélectionné.
  final Color ink;

  /// Texte et icônes posés sur [ink].
  final Color onInk;
  final Color ink2;

  /// Libellés et sous-titres (contraste ≥ 4,5:1 sur [bg]).
  final Color muted;

  /// Libellé d'une tuile de catégorie non sélectionnée.
  final Color tileLabel;

  /// Montant à 0.
  final Color disabled;
  final Color ctaDisabled;

  /// Poignée de bottom sheet, barres « entrées » de l'histogramme.
  final Color handle;
  final Color positive;
  final Color positiveTint;

  /// Enveloppe Famille.
  final Color family;

  /// Flamme de la série, avertissements (rythme, dépassement).
  final Color streak;
  final Color scrim;

  static const clair = KoudiTokens(
    bg: Color(0xFFF5F5F2),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEAEAE5),
    track: Color(0xFFE4E4DF),
    line: Color(0xFFE6E6E1),
    lineStrong: Color(0xFFE0E0DA),
    ink: Color(0xFF111113),
    onInk: Color(0xFFFFFFFF),
    ink2: Color(0xFF3A3A3F),
    muted: Color(0xFF6E6E73),
    tileLabel: Color(0xFF55555B),
    disabled: Color(0xFFB5B5B0),
    ctaDisabled: Color(0xFFE3E3DE),
    handle: Color(0xFFD6D6D0),
    positive: Color(0xFF0E7A4F),
    positiveTint: Color(0xFFDDEFE5),
    family: Color(0xFF2F5BD3),
    streak: Color(0xFFC2410C),
    scrim: Color(0x66111113),
  );

  /// Préparé pour une itération future, non activé (brief §2).
  static const sombre = KoudiTokens(
    bg: Color(0xFF09090B),
    surface: Color(0xFF141417),
    surfaceMuted: Color(0xFF1C1C21),
    track: Color(0xFF26262C),
    line: Color(0xFF26262C),
    lineStrong: Color(0xFF2E2E35),
    ink: Color(0xFFF5F5F4),
    onInk: Color(0xFF09090B),
    ink2: Color(0xFFD4D4D8),
    muted: Color(0xFF9A9AA3),
    tileLabel: Color(0xFFB4B4BC),
    disabled: Color(0xFF55555C),
    ctaDisabled: Color(0xFF26262C),
    handle: Color(0xFF3A3A42),
    positive: Color(0xFF5EE08F),
    positiveTint: Color(0xFF12301F),
    family: Color(0xFF7EA2FF),
    streak: Color(0xFFFB923C),
    scrim: Color(0x99000000),
  );

  @override
  KoudiTokens copyWith() => this;

  @override
  KoudiTokens lerp(KoudiTokens? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return KoudiTokens(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surfaceMuted: l(surfaceMuted, other.surfaceMuted),
      track: l(track, other.track),
      line: l(line, other.line),
      lineStrong: l(lineStrong, other.lineStrong),
      ink: l(ink, other.ink),
      onInk: l(onInk, other.onInk),
      ink2: l(ink2, other.ink2),
      muted: l(muted, other.muted),
      tileLabel: l(tileLabel, other.tileLabel),
      disabled: l(disabled, other.disabled),
      ctaDisabled: l(ctaDisabled, other.ctaDisabled),
      handle: l(handle, other.handle),
      positive: l(positive, other.positive),
      positiveTint: l(positiveTint, other.positiveTint),
      family: l(family, other.family),
      streak: l(streak, other.streak),
      scrim: l(scrim, other.scrim),
    );
  }
}

extension KoudiTokensContexte on BuildContext {
  KoudiTokens get tokens => Theme.of(this).extension<KoudiTokens>()!;
}
