import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/koudi_tokens.dart';

/// Tuile de la grille de saisie (brief §4.3) : icône colorée + libellé
/// court. Sélectionnée : fond teinté, bordure 1,5 px de la couleur de la
/// catégorie, libellé en encre. Un léger enfoncement répond au toucher.
class CategoryTile extends StatefulWidget {
  const CategoryTile({
    super.key,
    required this.icone,
    required this.libelle,
    required this.couleur,
    required this.teinte,
    required this.selectionnee,
    required this.onTap,
    this.hauteur = 62,
  });

  final IconData icone;
  final String libelle;
  final Color couleur;
  final Color teinte;
  final bool selectionnee;
  final VoidCallback onTap;
  final double hauteur;

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool _enfoncee = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final sel = widget.selectionnee;
    final compacte = widget.hauteur < 58;

    return Semantics(
      button: true,
      selected: sel,
      label: widget.libelle,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _enfoncee = true),
        onTapCancel: () => setState(() => _enfoncee = false),
        onTapUp: (_) => setState(() => _enfoncee = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _enfoncee ? 0.95 : 1,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: widget.hauteur,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: sel ? widget.teinte : t.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: sel ? widget.couleur : t.surface, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icone, size: compacte ? 19 : 21, color: widget.couleur),
                SizedBox(height: compacte ? 3 : 5),
                Text(
                  widget.libelle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.15),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: sel ? t.ink : t.tileLabel,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
