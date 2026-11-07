import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/badges.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/l10n.dart';
import '../../logic/providers/repositories_providers.dart';

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
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.s16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.s12,
              crossAxisSpacing: AppSpacing.s12,
              childAspectRatio: 0.95,
            ),
            itemCount: badgesDisponibles.length,
            itemBuilder: (context, index) {
              final badge = badgesDisponibles[index];
              final debloque = debloques.contains(badge.id);
              return _CarteBadge(
                badge: badge,
                debloque: debloque,
                langue: langue,
              );
            },
          );
        },
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
    final couleur = debloque ? AppColors.accent : AppColors.textMuted;

    return Opacity(
      opacity: debloque ? 1 : 0.5,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: BorderSide(color: debloque ? AppColors.accent : Colors.transparent),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(badge.icone, color: couleur, size: 32),
              const SizedBox(height: AppSpacing.s8),
              Text(
                titreBadge(badge, langue),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                descriptionBadge(badge, langue),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
