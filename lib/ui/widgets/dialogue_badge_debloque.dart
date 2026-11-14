import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/badges.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/l10n.dart';
import 'medaille_badge.dart';

/// Déblocage d'un badge : le seul moment "récompense" de l'app, donc
/// la seule gamification à mériter plus qu'une SnackBar — une carte
/// qui s'ouvre au centre de l'écran avec un halo et un "pop" élastique,
/// jamais bloquante (un tap n'importe où, ou le bouton, la referme).
Future<void> afficherDeblocageBadge(
  BuildContext context,
  BadgeInfo badge,
  String langue,
) {
  HapticFeedback.mediumImpact();
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, _, _) =>
        _CarteDeblocageBadge(badge: badge, langue: langue),
  );
}

class _CarteDeblocageBadge extends StatelessWidget {
  const _CarteDeblocageBadge({required this.badge, required this.langue});

  final BadgeInfo badge;
  final String langue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.s24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 168,
                  height: 168,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.35),
                        AppColors.accent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: MedailleBadge(badge: badge, taille: 120)
                      .animate()
                      .scale(
                        begin: const Offset(0.4, 0.4),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      )
                      // Un seul reflet qui balaie la médaille, une fois posée.
                      .then(delay: 150.ms)
                      .shimmer(
                        duration: 900.ms,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                ),
                const SizedBox(height: AppSpacing.s16),
                Text(
                  l10n.badgesDeblocageTitre.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  titreBadge(badge, langue),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  descriptionBadge(badge, langue),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.badgesDeblocageBouton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 250.ms).scale(
        begin: const Offset(0.85, 0.85),
        curve: Curves.easeOutBack,
      ),
    );
  }
}
