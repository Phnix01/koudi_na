import 'package:flutter/material.dart';

import '../../../core/theme/koudi_tokens.dart';
import '../../../core/utils/formatters.dart';

/// Un montant + son unité, plus petite et grise (brief §2 : « FCFA »
/// toujours plus petit que le nombre). Suit la devise des Réglages :
/// unité après le nombre (FCFA, CHF, MAD…) ou symbole avant ($, £, R$…).
class AmountText extends StatelessWidget {
  const AmountText(
    this.valeur, {
    super.key,
    required this.style,
    this.couleur,
    this.tailleUnite,
    this.signe = false,
    this.avecUnite = true,
    this.ajuster = false,
    this.prefixe,
  });

  final int valeur;
  final TextStyle? style;
  final Color? couleur;
  final double? tailleUnite;

  /// Afficher « + » devant un montant positif (le « − » est toujours là).
  final bool signe;
  final bool avecUnite;

  /// Réduire le texte plutôt que le couper (gros montants en VND, UGX…).
  final bool ajuster;

  /// Texte avant le nombre, au style du nombre (ex. « ≈ »).
  final String? prefixe;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final base = (style ?? DefaultTextStyle.of(context).style).copyWith(color: couleur);
    final taille = base.fontSize ?? 14;
    final styleUnite = base.copyWith(
      fontSize: tailleUnite ?? (taille * 0.33).clamp(11.0, 18.0),
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      color: t.muted,
    );
    final devise = deviseCourante;
    final texteSigne = valeur < 0 ? signeMoins : (signe && valeur > 0 ? '+' : '');
    final nombre = formaterNombre(valeur);

    final spans = <InlineSpan>[
      if (prefixe != null) TextSpan(text: '$prefixe '),
      TextSpan(text: texteSigne),
      if (avecUnite && devise.avantLeMontant) TextSpan(text: devise.symbole, style: styleUnite),
      TextSpan(text: nombre),
      if (avecUnite && !devise.avantLeMontant) ...[
        const TextSpan(text: ' '),
        TextSpan(text: devise.symbole, style: styleUnite),
      ],
    ];

    final texte = Text.rich(
      TextSpan(style: base, children: spans),
      maxLines: 1,
      softWrap: false,
      semanticsLabel: '$texteSigne${formaterMontant(valeur.abs())}',
    );
    if (!ajuster) return texte;
    return FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: texte);
  }
}
