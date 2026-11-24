import 'package:flutter/material.dart';

import '../../../core/theme/koudi_tokens.dart';

/// Bouton rond 40 px à fond gris (fermer, calendrier : brief §4.3), avec
/// une zone tactile de 44 px.
class BoutonRond extends StatelessWidget {
  const BoutonRond({
    super.key,
    required this.icone,
    required this.semantique,
    required this.onTap,
    this.actif = false,
  });

  final IconData icone;
  final String semantique;
  final VoidCallback onTap;

  /// Variante encre (ex. une date autre qu'aujourd'hui est choisie).
  final bool actif;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      label: semantique,
      excludeSemantics: true,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Material(
            color: actif ? t.ink : t.surfaceMuted,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(icone, size: 18, color: actif ? t.onInk : t.ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
