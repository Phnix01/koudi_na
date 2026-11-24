import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/koudi_tokens.dart';
import '../../../l10n/l10n.dart';

/// Pavé 3×4 de la saisie (brief §3.8) : 1-9, 000, 0, ⌫. Touches blanches
/// avec un liseré bas, retour haptique léger. Un appui long sur ⌫ vide
/// le montant. La logique (zéros non significatifs, 9 chiffres max) reste
/// dans `CaptureFormNotifier`.
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onChiffre,
    required this.onEffacer,
    required this.onToutEffacer,
    this.hauteurTouche = 50,
  });

  final ValueChanged<String> onChiffre;
  final VoidCallback onEffacer;
  final VoidCallback onToutEffacer;
  final double hauteurTouche;

  static const _touches = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '000', '0', '⌫'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var ligne = 0; ligne < 4; ligne++) ...[
          if (ligne > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (var col = 0; col < 3; col++) ...[
                if (col > 0) const SizedBox(width: 8),
                Expanded(child: _touche(context, _touches[ligne * 3 + col])),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _touche(BuildContext context, String touche) {
    final effacer = touche == '⌫';
    return _Touche(
      hauteur: hauteurTouche,
      semantique: effacer ? context.l10n.saisieEffacer : touche,
      onTap: effacer ? onEffacer : () => onChiffre(touche),
      onLongPress: effacer ? onToutEffacer : null,
      child: effacer
          ? const Icon(PhosphorIconsRegular.backspace, size: 24)
          : Text(
              touche,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
    );
  }
}

class _Touche extends StatefulWidget {
  const _Touche({
    required this.hauteur,
    required this.semantique,
    required this.onTap,
    required this.child,
    this.onLongPress,
  });

  final double hauteur;
  final String semantique;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget child;

  @override
  State<_Touche> createState() => _ToucheState();
}

class _ToucheState extends State<_Touche> {
  bool _enfoncee = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      label: widget.semantique,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _enfoncee = true),
        onTapCancel: () => setState(() => _enfoncee = false),
        onTapUp: (_) => setState(() => _enfoncee = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        onLongPress: widget.onLongPress == null
            ? null
            : () {
                HapticFeedback.mediumImpact();
                widget.onLongPress!();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          height: widget.hauteur,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _enfoncee ? t.surfaceMuted : t.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: t.lineStrong, offset: const Offset(0, 1))],
          ),
          child: IconTheme.merge(data: IconThemeData(color: t.ink), child: widget.child),
        ),
      ),
    );
  }
}
