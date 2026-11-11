import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/l10n.dart';

/// Un élément de l'écran à présenter pendant la visite guidée.
class EtapeDidacticiel {
  const EtapeDidacticiel({
    required this.cible,
    required this.titre,
    required this.texte,
    this.ronde = false,
  });

  final GlobalKey cible;
  final String titre;
  final String texte;

  /// Projecteur circulaire (boutons-icônes) plutôt que rectangle arrondi.
  final bool ronde;
}

/// Visite guidée : l'écran s'assombrit et un projecteur glisse d'un
/// élément à l'autre, avec une carte d'explication. Un toucher n'importe
/// où avance ; « Passer » ou le retour système arrêtent. Les étapes dont
/// la cible n'est pas affichée sont sautées. Se termine quand la visite
/// est finie ou abandonnée.
Future<void> lancerDidacticiel(
  BuildContext context,
  List<EtapeDidacticiel> etapes,
) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, _, _) => _Didacticiel(etapes: etapes),
    transitionBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

class _Didacticiel extends StatefulWidget {
  const _Didacticiel({required this.etapes});

  final List<EtapeDidacticiel> etapes;

  @override
  State<_Didacticiel> createState() => _DidacticielState();
}

class _DidacticielState extends State<_Didacticiel> {
  static const _marge = 8.0;

  int _index = -1;
  Rect? _cible;
  bool _enTransition = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _allerA(0));
  }

  Rect? _mesurer(int index) {
    final objet = widget.etapes[index].cible.currentContext?.findRenderObject();
    if (objet is! RenderBox || !objet.attached || !objet.hasSize) return null;
    return (objet.localToGlobal(Offset.zero) & objet.size).inflate(_marge);
  }

  Future<void> _allerA(int index) async {
    if (_enTransition) return;
    _enTransition = true;
    try {
      for (var i = index; i < widget.etapes.length; i++) {
        final contexteCible = widget.etapes[i].cible.currentContext;
        if (contexteCible == null) continue;
        // Cible hors de l'écran (bas du formulaire) : on fait défiler
        // jusqu'à elle avant d'y poser le projecteur.
        await Scrollable.ensureVisible(
          contexteCible,
          alignment: 0.3,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        if (!mounted) return;
        final rect = _mesurer(i);
        if (rect == null) continue;
        HapticFeedback.selectionClick();
        setState(() {
          _index = i;
          _cible = rect;
        });
        return;
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      _enTransition = false;
    }
  }

  void _suivant() => _allerA(_index + 1);

  @override
  Widget build(BuildContext context) {
    final cible = _cible;
    if (cible == null) return const SizedBox.expand();

    final etape = widget.etapes[_index];
    final taille = MediaQuery.sizeOf(context);
    final carteEnDessous = cible.center.dy < taille.height / 2;
    final derniere = _index == widget.etapes.length - 1;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _suivant,
      child: Stack(
        children: [
          Positioned.fill(
            child: TweenAnimationBuilder<Rect?>(
              tween: RectTween(begin: cible, end: cible),
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutCubic,
              builder: (_, rect, _) => CustomPaint(
                painter: _PeintreProjecteur(
                  trou: rect ?? cible,
                  ronde: etape.ronde,
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            left: AppSpacing.s16,
            right: AppSpacing.s16,
            top: carteEnDessous ? cible.bottom + AppSpacing.s16 : null,
            bottom: carteEnDessous
                ? null
                : taille.height - cible.top + AppSpacing.s16,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(
                    begin: Offset(0, carteEnDessous ? -0.08 : 0.08),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: _CarteEtape(
                key: ValueKey(_index),
                etape: etape,
                numero: _index + 1,
                total: widget.etapes.length,
                derniere: derniere,
                onSuivant: _suivant,
                onPasser: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteEtape extends StatelessWidget {
  const _CarteEtape({
    super.key,
    required this.etape,
    required this.numero,
    required this.total,
    required this.derniere,
    required this.onSuivant,
    required this.onPasser,
  });

  final EtapeDidacticiel etape;
  final int numero;
  final int total;
  final bool derniere;
  final VoidCallback onSuivant;
  final VoidCallback onPasser;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    // Material : la carte vit dans une route de dialogue, sans Scaffold
    // pour fournir les styles de texte et l'encre des boutons.
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.didacticielEtape(numero, total),
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(etape.titre, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s4),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                etape.texte,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Row(
              children: [
                _Progression(numero: numero, total: total),
                const Spacer(),
                if (!derniere)
                  TextButton(
                    onPressed: onPasser,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                    ),
                    child: Text(l10n.didacticielPasser),
                  ),
                TextButton(
                  onPressed: onSuivant,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(
                    derniere ? l10n.didacticielTerminer : l10n.didacticielSuivant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Petits points de progression : l'étape courante s'étire en pilule.
class _Progression extends StatelessWidget {
  const _Progression({required this.numero, required this.total});

  final int numero;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= total; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(right: 4),
            width: i == numero ? 14 : 5,
            height: 5,
            decoration: BoxDecoration(
              color: i <= numero
                  ? AppColors.accent
                  : AppColors.textMuted.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

class _PeintreProjecteur extends CustomPainter {
  _PeintreProjecteur({required this.trou, required this.ronde});

  final Rect trou;
  final bool ronde;

  // Ronde : cercle pour une cible carrée (bouton-icône), pilule sinon
  // (la série, plus large que haute), sans jamais rogner le contenu.
  RRect get _forme => RRect.fromRectAndRadius(
    trou,
    Radius.circular(ronde ? trou.shortestSide / 2 : 16),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final forme = _forme;
    final voile = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRRect(forme),
    );
    canvas.drawPath(voile, Paint()..color = Colors.black.withValues(alpha: 0.78));
    canvas.drawRRect(
      forme,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AppColors.accent.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(_PeintreProjecteur ancien) =>
      ancien.trou != trou || ancien.ronde != ronde;
}
