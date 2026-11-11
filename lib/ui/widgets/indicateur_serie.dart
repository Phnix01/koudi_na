import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/l10n.dart';
import '../../logic/providers/repositories_providers.dart';

/// Série de jours actifs, discrète dans l'en-tête de l'écran Capture :
/// flamme grise au repos, dorée avec le nombre de jours dès qu'une
/// série existe. Rien d'imposé : un toucher explique ce qu'elle compte.
class IndicateurSerie extends ConsumerWidget {
  const IndicateurSerie({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationRepositoryProvider);
    final l10n = context.l10n;

    return ValueListenableBuilder(
      valueListenable: gamification.listenable(),
      builder: (context, _, _) {
        final serie = gamification.serieCourante;
        final active = serie > 0;

        return Tooltip(
          message: active ? l10n.serieInfobulle(serie) : l10n.serieInfobulleVide,
          triggerMode: TooltipTriggerMode.tap,
          showDuration: const Duration(seconds: 3),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhosphorIcon(
                  active ? PhosphorIconsFill.flame : PhosphorIconsRegular.flame,
                  size: 20,
                  color: active
                      ? AppColors.accent
                      : AppColors.textMuted.withValues(alpha: 0.6),
                ),
                if (active) ...[
                  const SizedBox(width: 4),
                  // La clé ne fait rejouer le "pop" que quand le nombre
                  // change, pas à chaque notification de la Box (badges,
                  // alertes de dépassement y sont aussi stockés).
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    switchInCurve: Curves.elasticOut,
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Text(
                      '$serie',
                      key: ValueKey(serie),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
