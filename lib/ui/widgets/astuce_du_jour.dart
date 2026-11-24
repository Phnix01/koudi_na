import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/koudi_tokens.dart';
import '../../l10n/l10n.dart';

/// Astuce financière du jour, en bas de l'Analyse (brief §4.5) : texte
/// simple sous un filet, icône ampoule, pas de carte colorée.
class AstuceDuJour extends StatelessWidget {
  const AstuceDuJour({super.key, required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final style = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: t.line))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(PhosphorIconsRegular.lightbulb, size: 18, color: t.muted),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.astuceDuJourEtiquette, style: style.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(texte, style: style.bodyMedium?.copyWith(color: t.ink2, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
