import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/couleurs_piliers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/pilier.dart';
import '../../l10n/l10n.dart';
import '../../logic/providers/langue_provider.dart';
import '../navigation/route_animee.dart';
import 'capture_screen.dart';

/// Onboarding du tout premier lancement : quatre écrans, une promesse
/// par écran, puis l'application. Ne s'affiche plus jamais ensuite
/// (clé `onboarding_termine` dans la Box de réglages). Le choix de la
/// langue est accessible en haut à droite dès le premier écran : un
/// utilisateur anglophone ne doit pas lire trois écrans de français
/// avant de trouver le réglage.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controleur = PageController();
  int _page = 0;

  static const _nombreDePages = 4;

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  Future<void> _terminer() async {
    await ref.read(reglagesRepositoryProvider).marquerOnboardingTermine();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(routeAnimee(const CaptureScreen()));
  }

  void _suivant() {
    if (_page == _nombreDePages - 1) {
      _terminer();
      return;
    }
    _controleur.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final derniere = _page == _nombreDePages - 1;

    final pages = [
      _PageOnboarding(
        visuel: const _VisuelMarque(),
        titre: l10n.onboardingTitre1,
        corps: l10n.onboardingCorps1,
      ),
      _PageOnboarding(
        visuel: const _VisuelCapture(),
        titre: l10n.onboardingTitre2,
        corps: l10n.onboardingCorps2,
      ),
      _PageOnboarding(
        visuel: const _VisuelPiliers(),
        titre: l10n.onboardingTitre3,
        corps: l10n.onboardingCorps3,
      ),
      _PageOnboarding(
        visuel: const _VisuelConfidentialite(),
        titre: l10n.onboardingTitre4,
        corps: l10n.onboardingCorps4,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s8,
                AppSpacing.s16,
                0,
              ),
              child: Row(
                children: [
                  const _BasculeLangue(),
                  const Spacer(),
                  // « Passer » disparaît sur le dernier écran : il n'y a
                  // plus rien à sauter, seul « Commencer » a du sens.
                  if (!derniere)
                    TextButton(
                      onPressed: _terminer,
                      child: Text(l10n.onboardingPasser),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controleur,
                onPageChanged: (index) => setState(() => _page = index),
                children: pages,
              ),
            ),
            _IndicateurPages(total: _nombreDePages, courante: _page),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s24,
                AppSpacing.s16,
                AppSpacing.s24,
                AppSpacing.s24,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _suivant,
                  child: Text(
                    derniere
                        ? l10n.onboardingCommencer
                        : l10n.onboardingSuivant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Deux puces FR / EN. Le changement est immédiat : MaterialApp se
/// reconstruit avec la nouvelle locale et cet écran se retraduit sur
/// place, sans quitter l'onboarding.
class _BasculeLangue extends ConsumerWidget {
  const _BasculeLangue();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courante = ref.watch(localeProvider).languageCode;
    return SegmentedButton<String>(
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: 'fr', label: Text('FR')),
        ButtonSegment(value: 'en', label: Text('EN')),
      ],
      selected: {courante},
      onSelectionChanged: (selection) =>
          ref.read(langueProvider.notifier).choisir(selection.first),
    );
  }
}

class _PageOnboarding extends StatelessWidget {
  const _PageOnboarding({
    required this.visuel,
    required this.titre,
    required this.corps,
  });

  final Widget visuel;
  final String titre;
  final String corps;

  @override
  Widget build(BuildContext context) {
    final texte = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 180, child: Center(child: visuel)),
          const SizedBox(height: AppSpacing.s32),
          Text(titre, style: texte.displayMedium),
          const SizedBox(height: AppSpacing.s16),
          Text(
            corps,
            style: texte.bodyLarge?.copyWith(
              color: AppColors.textMuted,
              height: 1.45,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
    );
  }
}

class _IndicateurPages extends StatelessWidget {
  const _IndicateurPages({required this.total, required this.courante});

  final int total;
  final int courante;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == courante ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == courante ? AppColors.primary : AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

/// Écran 1 : le monogramme de l'icône, même image que sur l'écran
/// d'accueil du téléphone — l'utilisateur relie l'app à son icône.
class _VisuelMarque extends StatelessWidget {
  const _VisuelMarque();

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/icon/app_icon_fg.png', width: 220, height: 220);
  }
}

/// Écran 2 : un montant tel qu'il apparaît sur l'écran Capture, avec
/// trois pastilles de catégorie — la saisie en trois gestes, montrée
/// plutôt que décrite.
class _VisuelCapture extends StatelessWidget {
  const _VisuelCapture();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formaterMontant(2500),
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: AppSpacing.s16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _PastilleCategorie(
              icone: PhosphorIconsFill.bowlFood,
              couleur: Color(0xFFF5A623),
            ),
            SizedBox(width: AppSpacing.s12),
            // Transport sélectionné : c'est l'exemple que cite le texte.
            _PastilleCategorie(
              icone: PhosphorIconsFill.car,
              couleur: Color(0xFF4A90D9),
              selectionnee: true,
            ),
            SizedBox(width: AppSpacing.s12),
            _PastilleCategorie(
              icone: PhosphorIconsFill.deviceMobile,
              couleur: AppColors.accent,
            ),
          ],
        ),
      ],
    );
  }
}

class _PastilleCategorie extends StatelessWidget {
  const _PastilleCategorie({
    required this.icone,
    required this.couleur,
    this.selectionnee = false,
  });

  final PhosphorIconData icone;
  final Color couleur;
  final bool selectionnee;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: selectionnee ? couleur : couleur.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: PhosphorIcon(
          icone,
          color: selectionnee ? AppColors.bg : couleur,
          size: 24,
        ),
      ),
    );
  }
}

/// Écran 3 : les trois piliers en proportions réelles (40 / 25 / 35),
/// dans les couleurs du monogramme.
class _VisuelPiliers extends StatelessWidget {
  const _VisuelPiliers();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const parts = {Pilier.epargne: 40, Pilier.famille: 25, Pilier.vie: 35};
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final entree in parts.entries) ...[
          Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  l10n.libellePilier(entree.key),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: entree.value / 40,
                    child: Container(
                      height: 22,
                      decoration: BoxDecoration(
                        color: couleursPiliers[entree.key],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              SizedBox(
                width: 40,
                child: Text(
                  '${entree.value} %',
                  textAlign: TextAlign.right,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
        ],
      ],
    );
  }
}

/// Écran 4 : un cadenas dans un disque teal — le téléphone garde tout.
class _VisuelConfidentialite extends StatelessWidget {
  const _VisuelConfidentialite();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: PhosphorIcon(
          PhosphorIconsFill.lockKey,
          color: AppColors.primary,
          size: 64,
        ),
      ),
    );
  }
}
