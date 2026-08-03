import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';

/// Un montant qui défile de 0 à sa valeur en 600 ms (section 3.2),
/// factorisé ici pour ne pas répéter le même `TweenAnimationBuilder`
/// dans chaque carte de total (Mois, Analyse...). Rejoue l'animation à
/// chaque fois que [valeur] change, puisque `TweenAnimationBuilder`
/// anime automatiquement tout changement de son paramètre `end`.
class MontantAnime extends StatelessWidget {
  const MontantAnime({super.key, required this.valeur, this.style});

  final int valeur;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: valeur),
      duration: const Duration(milliseconds: 600),
      // FittedBox : si le montant est trop large pour l'espace
      // disponible (un gros chiffre dans une petite carte), il rétrécit
      // pour tenir sur une ligne plutôt que de passer à la ligne.
      builder: (context, valeurAnimee, _) => FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(formaterMontant(valeurAnimee), style: style, maxLines: 1),
      ),
    );
  }
}
