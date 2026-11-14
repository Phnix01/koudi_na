import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/badges.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/l10n.dart';
import '../../logic/providers/repositories_providers.dart';
import '../widgets/medaille_badge.dart';

/// Écran listant tous les badges disponibles (débloqués ou non),
/// accessible depuis Réglages. L'app de capture reste volontairement
/// minimale ; cet écran porte toute la gamification visible.
class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final gamification = ref.watch(gamificationRepositoryProvider);
    final langue = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.badgesTitre)),
      body: ValueListenableBuilder(
        valueListenable: gamification.listenable(),
        builder: (context, _, _) {
          final debloques = gamification.badgesDebloques;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _EnTeteProgression(
                  debloques: debloques.length,
                  total: badgesDisponibles.length,
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.s12,
                    crossAxisSpacing: AppSpacing.s12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: badgesDisponibles.length,
                  itemBuilder: (context, index) {
                    final badge = badgesDisponibles[index];
                    final debloque = debloques.contains(badge.id);
                    return _CarteBadge(
                          badge: badge,
                          debloque: debloque,
                          langue: langue,
                        )
                        .animate(delay: (index * 40).ms)
                        .fadeIn(duration: 300.ms)
                        .scale(
                          begin: const Offset(0.92, 0.92),
                          curve: Curves.easeOut,
                        );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EnTeteProgression extends StatelessWidget {
  const _EnTeteProgression({required this.debloques, required this.total});

  final int debloques;
  final int total;

  @override
  Widget build(BuildContext context) {
    final proportion = total == 0 ? 0.0 : debloques / total;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.surfaceHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PhosphorIcon(
                PhosphorIconsFill.trophy,
                color: AppColors.accent,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                context.l10n.badgesProgression(debloques, total),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: proportion,
              minHeight: 8,
              backgroundColor: AppColors.surfaceHigh,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteBadge extends StatelessWidget {
  const _CarteBadge({
    required this.badge,
    required this.debloque,
    required this.langue,
  });

  final BadgeInfo badge;
  final bool debloque;
  final String langue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: debloque ? AppColors.accent.withValues(alpha: 0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(
          color: debloque
              ? AppColors.accent.withValues(alpha: 0.5)
              : AppColors.surfaceHigh,
        ),
        boxShadow: debloque
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MedailleBadge(badge: badge, debloque: debloque, taille: 64),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  titreBadge(badge, langue),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  descriptionBadge(badge, langue),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            if (!debloque)
              const Positioned(
                top: 0,
                right: 0,
                child: PhosphorIcon(
                  PhosphorIconsFill.lockSimple,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
