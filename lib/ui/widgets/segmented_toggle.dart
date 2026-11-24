import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/koudi_tokens.dart';

/// Bascule à options exclusives (2 à 4), style « pill » de la refonte D :
/// fond gris, segment actif blanc avec une ombre légère qui **glisse**
/// d'une option à l'autre. Remplace le `SegmentedButton` Material 3, qui
/// laissait un libellé comme « Dépense » se couper avec une grande échelle
/// de police : ici chaque segment force une seule ligne.
class SegmentedToggle<T> extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    required this.options,
    required this.selectionne,
    required this.onChanged,
    this.hauteur = 40,
    this.largeurSegment,
    this.taillePolice = 14,
  });

  final List<SegmentedToggleOption<T>> options;
  final T selectionne;
  final ValueChanged<T> onChanged;

  /// Hauteur d'un segment (hors marge intérieure de 3 px).
  final double hauteur;

  /// Largeur fixe d'un segment ; sinon les segments se partagent la place.
  final double? largeurSegment;
  final double taillePolice;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final index = options.indexWhere((o) => o.valeur == selectionne);
    final rayon = hauteur * 0.27;
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
      fontSize: taillePolice,
      fontWeight: FontWeight.w600,
    );

    Widget piste(double largeur) {
      final largeurSeg = largeur / options.length;
      return SizedBox(
        width: largeur,
        height: hauteur,
        child: Stack(
          children: [
            if (index >= 0)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                left: index * largeurSeg,
                top: 0,
                bottom: 0,
                width: largeurSeg,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(rayon),
                    boxShadow: const [
                      BoxShadow(color: Color(0x14000000), blurRadius: 2, offset: Offset(0, 1)),
                    ],
                  ),
                ),
              ),
            Row(
              children: [
                for (final option in options)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: option.valeur == selectionne,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (option.valeur == selectionne) return;
                          HapticFeedback.selectionClick();
                          onChanged(option.valeur);
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: style!.copyWith(
                                color: option.valeur == selectionne ? t.ink : t.muted,
                              ),
                              child: Text(
                                option.label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: t.surfaceMuted,
        borderRadius: BorderRadius.circular(rayon + 3),
      ),
      child: largeurSegment != null
          ? piste(largeurSegment! * options.length)
          // Dans une Row (largeur non bornée), chaque segment prend 72 px.
          : LayoutBuilder(
              builder: (context, c) => piste(
                c.maxWidth.isFinite ? c.maxWidth : options.length * 72.0,
              ),
            ),
    );
  }
}

class SegmentedToggleOption<T> {
  const SegmentedToggleOption({required this.valeur, required this.label});

  final T valeur;
  final String label;
}
