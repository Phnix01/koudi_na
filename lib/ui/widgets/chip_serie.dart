import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/l10n.dart';
import '../../logic/providers/repositories_providers.dart';

/// Pastille « série » sous l'en-tête de l'écran de capture : flamme +
/// nombre de jours consécutifs. Masquée tant qu'aucune série n'est en
/// cours (pas de "0 jour" qui culpabilise au premier lancement). La
/// clé `ValueKey(serie)` ne fait rejouer le "pop" d'entrée que lorsque
/// le nombre change réellement — la Box gamification notifie aussi
/// pour les badges et les alertes de dépassement, qui ne doivent pas
/// relancer cette animation.
class ChipSerie extends ConsumerWidget {
  const ChipSerie({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationRepositoryProvider);

    return ValueListenableBuilder(
      valueListenable: gamification.listenable(),
      builder: (context, _, _) {
        final serie = gamification.serieCourante;
        if (serie == 0) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              switchInCurve: Curves.elasticOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Container(
                key: ValueKey(serie),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentRose],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PhosphorIcon(
                          PhosphorIconsFill.flame,
                          color: AppColors.bg,
                          size: 16,
                        )
                        .animate(onPlay: (controller) => controller.repeat(reverse: true))
                        .scale(
                          end: const Offset(1.18, 1.18),
                          duration: 700.ms,
                          curve: Curves.easeInOut,
                        ),
                    const SizedBox(width: AppSpacing.s8),
                    Text(
                      context.l10n.serieJoursChip(serie),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.bg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
