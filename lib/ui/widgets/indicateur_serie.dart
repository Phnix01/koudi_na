import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/koudi_tokens.dart';
import '../../l10n/l10n.dart';
import '../../logic/providers/repositories_providers.dart';
import '../navigation/route_animee.dart';
import '../screens/badges_screen.dart';

/// Pastille de la série en haut de l'Accueil (brief §4.1) : flamme et
/// nombre de jours consécutifs avec au moins une saisie. Un toucher
/// ouvre les badges ; le nombre fait un petit « pop » quand il augmente.
class IndicateurSerie extends ConsumerWidget {
  const IndicateurSerie({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final gamification = ref.watch(gamificationRepositoryProvider);

    return ValueListenableBuilder(
      valueListenable: gamification.listenable(),
      builder: (context, _, _) {
        final serie = gamification.serieCourante;
        final active = serie > 0;
        return Semantics(
          button: true,
          label: active ? l10n.serieInfobulle(serie) : l10n.serieInfobulleVide,
          excludeSemantics: true,
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(routeAnimee(const BadgesScreen())),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 11),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: t.line),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    active ? PhosphorIconsFill.flame : PhosphorIconsRegular.flame,
                    size: 15,
                    color: active ? t.streak : t.muted,
                  ),
                  const SizedBox(width: 5),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    switchInCurve: Curves.easeOutBack,
                    transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                    child: Text(
                      l10n.serieJoursCourt(serie),
                      key: ValueKey(serie),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: active ? t.ink2 : t.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
