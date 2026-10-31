import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Bascule à options exclusives (2 à 4), en remplacement du
/// `SegmentedButton` Material 3 par défaut : celui-ci répartit la
/// largeur entre segments sans jamais empêcher le retour à la ligne, et
/// un libellé comme « Dépense » se coupe dès qu'une échelle de police
/// système plus grande est active. Ici chaque segment force une seule
/// ligne (`maxLines: 1` + ellipsis en dernier recours) quelle que soit
/// la taille de texte choisie par l'utilisateur.
class SegmentedToggle<T> extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    required this.options,
    required this.selectionne,
    required this.onChanged,
  });

  final List<SegmentedToggleOption<T>> options;
  final T selectionne;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            Expanded(
              child: _Segment(
                label: option.label,
                active: option.valeur == selectionne,
                onTap: () => onChanged(option.valeur),
                style: style,
              ),
            ),
        ],
      ),
    );
  }
}

class SegmentedToggleOption<T> {
  const SegmentedToggleOption({required this.valeur, required this.label});

  final T valeur;
  final String label;
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.active,
    required this.onTap,
    required this.style,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.s12,
            horizontal: AppSpacing.s8,
          ),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: style?.copyWith(
              color: active ? AppColors.bg : AppColors.textMuted,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
