import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/koudi_tokens.dart';
import '../../../data/models/type_mouvement.dart';
import '../../../l10n/l10n.dart';
import '../../screens/saisie_screen.dart';

/// Sheet « Nouvelle opération » (brief §3.2), ouvert par le + : deux
/// grandes lignes, Dépense et Entrée. La ligne touchée **s'agrandit**
/// jusqu'à devenir l'écran de saisie (container transform), et s'y
/// referme au retour. Renvoie le résultat de la saisie, s'il y en a un.
Future<ResultatSaisie?> afficherNouvelleOperation(BuildContext context) {
  return showModalBottomSheet<ResultatSaisie>(
    context: context,
    useRootNavigator: true,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 340),
      reverseDuration: Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    ),
    builder: (context) => const _NouvelleOperation(),
  );
}

class _NouvelleOperation extends StatelessWidget {
  const _NouvelleOperation();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final sansAnimation = MediaQuery.disableAnimationsOf(context);

    Widget ligne(int index, Widget enfant) => sansAnimation
        ? enfant
        : enfant
              .animate(delay: (60 + 50 * index).ms)
              .fadeIn(duration: 220.ms)
              .slideY(begin: 0.25, end: 0, duration: 280.ms, curve: Curves.easeOutCubic);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(color: t.handle, borderRadius: BorderRadius.circular(3)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(l10n.nouvelleOperation, style: Theme.of(context).textTheme.titleLarge),
            ),
            ligne(
              0,
              _LigneOperation(
                type: TypeMouvement.depense,
                titre: l10n.depense,
                sousTitre: l10n.operationDepenseSousTitre,
                icone: PhosphorIconsBold.minus,
                couleurPastille: t.ink,
              ),
            ),
            const SizedBox(height: 10),
            ligne(
              1,
              _LigneOperation(
                type: TypeMouvement.entree,
                titre: l10n.entree,
                sousTitre: l10n.operationEntreeSousTitre,
                icone: PhosphorIconsBold.plus,
                couleurPastille: t.positive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LigneOperation extends StatelessWidget {
  const _LigneOperation({
    required this.type,
    required this.titre,
    required this.sousTitre,
    required this.icone,
    required this.couleurPastille,
  });

  final TypeMouvement type;
  final String titre;
  final String sousTitre;
  final IconData icone;
  final Color couleurPastille;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final texte = Theme.of(context).textTheme;

    return OpenContainer<ResultatSaisie>(
      transitionDuration: const Duration(milliseconds: 420),
      transitionType: ContainerTransitionType.fadeThrough,
      closedElevation: 0,
      openElevation: 0,
      closedColor: t.bg,
      openColor: t.bg,
      middleColor: t.bg,
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      useRootNavigator: true,
      // Le sheet se referme avec le résultat une fois la saisie rentrée
      // dans sa ligne.
      onClosed: (resultat) {
        if (resultat != null && context.mounted) Navigator.of(context).pop(resultat);
      },
      openBuilder: (context, _) => SaisieScreen.nouvelle(type: type),
      closedBuilder: (context, ouvrir) => Semantics(
        button: true,
        label: '$titre. $sousTitre',
        excludeSemantics: true,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            ouvrir();
          },
          child: SizedBox(
            height: 72,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: couleurPastille,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icone, size: 20, color: t.onInk),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(titre, style: texte.labelLarge),
                        const SizedBox(height: 2),
                        Text(
                          sousTitre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: texte.labelMedium?.copyWith(color: t.muted, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  Icon(PhosphorIconsRegular.caretRight, size: 18, color: t.muted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
