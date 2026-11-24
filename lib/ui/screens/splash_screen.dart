import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../logic/providers/langue_provider.dart' show reglagesRepositoryProvider;
import '../navigation/route_animee.dart';
import '../shell/app_shell.dart';
import 'onboarding_screen.dart';

/// Taille du logo animé, en pixels logiques. Les coordonnées du K ci-
/// dessous viennent du viewBox 1024×1024 de `assets/icon/app_icon.svg`
/// et sont mises à l'échelle par rapport à cette taille — pas besoin
/// de `flutter_svg` pour trois formes aussi simples (un rectangle, deux
/// polygones).
const double _tailleLogo = 112;
const double _echelle = _tailleLogo / 1024;

/// Premier contact avec l'app (avant onboarding ou Capture) : le K du
/// logo s'assemble à partir de ses trois piliers (teal, rose, bleu —
/// mêmes couleurs que le monogramme), durée fixe et non interruptible
/// pour rester un vrai moment de marque plutôt qu'un écran de chargement
/// qu'on esquive. `initialiserHive()` et le chargement des locales sont
/// déjà terminés avant `runApp()` (voir main.dart) : ce délai n'attend
/// aucune donnée, il n'existe que pour ce ressenti.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controleur;

  @override
  void initState() {
    super.initState();
    _controleur = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) _continuer();
    });
    _controleur.forward();
  }

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  Animation<double> _intervalle(double debut, double fin, Curve courbe) =>
      CurvedAnimation(
        parent: _controleur,
        curve: Interval(debut, fin, curve: courbe),
      );

  Future<void> _continuer() async {
    if (!mounted) return;
    final onboardingTermine = ref
        .read(reglagesRepositoryProvider)
        .onboardingTermine;
    Navigator.of(context).pushReplacement(
      routeAnimee(
        onboardingTermine ? const AppShell() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pulsation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1, end: 1.06), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.06, end: 1), weight: 50),
        ]).animate(
          _intervalle(0.55, 0.85, Curves.easeInOut),
        );
    final motAnimation = _intervalle(0.5, 0.85, Curves.easeOut);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: pulsation,
              builder: (context, child) =>
                  Transform.scale(scale: pulsation.value, child: child),
              child: SizedBox(
                width: _tailleLogo,
                height: _tailleLogo,
                child: Stack(
                  children: [
                    _PieceLogo(
                      sommets: const [
                        Offset(299.2, 265.6),
                        Offset(422.4, 265.6),
                        Offset(422.4, 758.4),
                        Offset(299.2, 758.4),
                      ],
                      couleur: AppColors.primary,
                      depart: const Offset(0, 50),
                      opacite: _intervalle(0, 0.42, Curves.easeOut),
                      position: _intervalle(0, 0.45, Curves.easeOutBack),
                    ),
                    _PieceLogo(
                      sommets: const [
                        Offset(551.2, 265.6),
                        Offset(724.8, 265.6),
                        Offset(489.6, 498.6),
                        Offset(449.3, 498.6),
                        Offset(449.3, 367.5),
                      ],
                      couleur: AppColors.accentRose,
                      depart: const Offset(50, -40),
                      opacite: _intervalle(0.08, 0.5, Curves.easeOut),
                      position: _intervalle(0.08, 0.53, Curves.easeOutBack),
                    ),
                    _PieceLogo(
                      sommets: const [
                        Offset(449.3, 525.4),
                        Offset(489.6, 525.4),
                        Offset(724.8, 758.4),
                        Offset(551.2, 758.4),
                        Offset(449.3, 656.5),
                      ],
                      couleur: AppColors.accentBleu,
                      depart: const Offset(50, 40),
                      opacite: _intervalle(0.16, 0.58, Curves.easeOut),
                      position: _intervalle(0.16, 0.61, Curves.easeOutBack),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            AnimatedBuilder(
              animation: motAnimation,
              builder: (context, child) => Opacity(
                opacity: motAnimation.value.clamp(0, 1),
                child: Transform.translate(
                  offset: Offset(0, 12 * (1 - motAnimation.value)),
                  child: child,
                ),
              ),
              child: Text(
                'Koudi Na',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un des trois morceaux du K (rectangle ou polygone) qui glisse vers sa
/// position finale en s'assemblant avec les deux autres.
class _PieceLogo extends StatelessWidget {
  const _PieceLogo({
    required this.sommets,
    required this.couleur,
    required this.depart,
    required this.opacite,
    required this.position,
  });

  /// Coordonnées dans le viewBox 1024×1024 d'origine, mises à l'échelle
  /// dans [build].
  final List<Offset> sommets;
  final Color couleur;

  /// Décalage de départ (avant assemblage), à l'échelle de l'écran.
  final Offset depart;
  final Animation<double> opacite;
  final Animation<double> position;

  @override
  Widget build(BuildContext context) {
    final sommetsEchelle = sommets
        .map((p) => p * _echelle)
        .toList(growable: false);
    return AnimatedBuilder(
      animation: Listenable.merge([opacite, position]),
      builder: (context, child) => Opacity(
        opacity: opacite.value.clamp(0, 1),
        child: Transform.translate(
          offset: depart * (1 - position.value),
          child: child,
        ),
      ),
      child: CustomPaint(
        size: const Size.square(_tailleLogo),
        painter: _FormePainter(sommetsEchelle, couleur),
      ),
    );
  }
}

class _FormePainter extends CustomPainter {
  _FormePainter(this.sommets, this.couleur);

  final List<Offset> sommets;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final chemin = Path()..addPolygon(sommets, true);
    canvas.drawPath(chemin, Paint()..color = couleur);
  }

  @override
  bool shouldRepaint(covariant _FormePainter oldDelegate) =>
      oldDelegate.couleur != couleur || oldDelegate.sommets != sommets;
}
