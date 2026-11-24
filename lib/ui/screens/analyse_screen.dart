import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/astuces.dart';
import '../../core/theme/koudi_tokens.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/visuels.dart';
import '../../l10n/l10n.dart';
import '../../logic/providers/devise_provider.dart';
import '../../logic/providers/repositories_providers.dart';
import '../../logic/services/analyse_periode.dart';
import '../../logic/services/habitudes_hebdomadaires.dart';
import '../../logic/services/observations_automatiques.dart';
import '../../logic/services/tableau_de_bord.dart';
import '../../logic/services/trajectoire_epargne.dart';
import '../widgets/astuce_du_jour.dart';
import '../widgets/graphique_trajectoire_epargne.dart';
import '../widgets/heatmap_habitudes.dart';
import '../widgets/segmented_toggle.dart';

/// Analyse (brief §4.5) : la projection en une phrase, l'histogramme
/// entrées/dépenses, où va l'argent — puis les analyses déjà présentes
/// dans l'app, restylées (observations, trajectoire d'épargne, jours qui
/// coûtent) et l'astuce du jour.
class AnalyseScreen extends ConsumerStatefulWidget {
  const AnalyseScreen({super.key});

  @override
  ConsumerState<AnalyseScreen> createState() => _AnalyseScreenState();
}

class _AnalyseScreenState extends ConsumerState<AnalyseScreen> {
  PeriodeAnalyse _periode = PeriodeAnalyse.sixMois;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final texte = Theme.of(context).textTheme;
    final repo = ref.watch(transactionRepositoryProvider);
    final categoriesRepo = ref.watch(categorieRepositoryProvider);
    final comptesRepo = ref.watch(compteRepositoryProvider);
    ref.watch(deviseProvider);

    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder(
        valueListenable: repo.listenable(),
        builder: (context, _, _) {
          final maintenant = DateTime.now();
          final moisCourant = DateTime(maintenant.year, maintenant.month);
          final transactions = repo.tous();
          final categories = categoriesRepo.tous();
          final comptes = comptesRepo.tous();
          final tableau = calculerTableauDeBord(transactions, categories, mois: moisCourant);
          final barres = calculerBarres(transactions, _periode);
          final parts = calculerRepartitionPeriode(transactions, categories, _periode);
          final observations = genererObservations(transactions, categories, comptes, l10n);
          final trajectoire = calculerTrajectoireEpargne(transactions, categories, comptes);
          final habitudes = calculerHabitudesHebdomadaires(transactions);
          final vide = transactions.isEmpty;

          final libellePeriode = switch (_periode) {
            PeriodeAnalyse.mois => nomMois(moisCourant),
            PeriodeAnalyse.sixMois => l10n.periode6Mois,
            PeriodeAnalyse.annee => l10n.periodeAnnee.toLowerCase(),
          };

          final blocs = <Widget>[
            _Projection(tableau: tableau, mois: moisCourant),
            _CarteHistogramme(barres: barres, periode: _periode),
            _OuVaLArgent(parts: parts, titre: l10n.ouVaLArgent(libellePeriode)),
            if (observations.isNotEmpty) _Observations(observations: observations),
            if (trajectoire.points.any((p) => p.cumul > 0))
              _Section(
                titre: l10n.trajectoireEpargne,
                enfant: GraphiqueTrajectoireEpargne(trajectoire: trajectoire),
              ),
            if (habitudes.maxMontant > 0)
              _Section(
                titre: l10n.analyseJoursCouteux,
                enfant: HeatmapHabitudes(grille: habitudes),
              ),
            AstuceDuJour(texte: astuceDuJour(maintenant, Localizations.localeOf(context).languageCode)),
          ];

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    Expanded(child: Text(l10n.analyse, style: texte.headlineMedium)),
                    SegmentedToggle<PeriodeAnalyse>(
                      hauteur: 30,
                      taillePolice: 13,
                      largeurSegment: 62,
                      options: [
                        SegmentedToggleOption(valeur: PeriodeAnalyse.mois, label: l10n.periodeMois),
                        SegmentedToggleOption(valeur: PeriodeAnalyse.sixMois, label: l10n.periode6Mois),
                        SegmentedToggleOption(valeur: PeriodeAnalyse.annee, label: l10n.periodeAnnee),
                      ],
                      selectionne: _periode,
                      onChanged: (p) => setState(() => _periode = p),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (vide)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(PhosphorIconsRegular.chartBar, size: 32, color: context.tokens.disabled),
                      const SizedBox(height: 10),
                      Text(
                        l10n.analyseVide,
                        textAlign: TextAlign.center,
                        style: texte.bodyMedium?.copyWith(color: context.tokens.muted),
                      ),
                    ],
                  ),
                )
              else
                for (var i = 0; i < blocs.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: blocs[i]
                        .animate(delay: (40 * i).ms)
                        .fadeIn(duration: 260.ms)
                        .slideY(begin: 0.04, end: 0, curve: Curves.easeOut),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _Projection extends StatelessWidget {
  const _Projection({required this.tableau, required this.mois});

  final TableauDeBord tableau;
  final DateTime mois;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final texte = Theme.of(context).textTheme;
    final montant = formaterMontant(tableau.projectionFinDeMois);
    final ecart = tableau.entrees - tableau.projectionFinDeMois;
    final phrase = texte.headlineSmall?.copyWith(
      fontWeight: FontWeight.w500,
      height: 1.35,
      letterSpacing: -0.3,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(PhosphorIconsBold.trendUp, size: 14, color: t.positive),
            const SizedBox(width: 6),
            Text(
              l10n.projectionSurtitre.toUpperCase(),
              style: texte.bodySmall?.copyWith(
                color: t.positive,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (tableau.depenses == 0)
          Text(l10n.projectionSansDepense(nomMois(mois)), style: phrase)
        else
          Text.rich(
            TextSpan(
              style: phrase,
              children: [
                TextSpan(text: l10n.projectionEnCours(nomMois(mois))),
                TextSpan(text: montant, style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: l10n.projectionDeDepenses),
                if (tableau.entrees > 0) ...[
                  TextSpan(text: l10n.projectionSoit),
                  TextSpan(
                    text: ecart >= 0
                        ? l10n.accueilSousEntrees(formaterNombre(ecart))
                        : l10n.accueilAuDessusEntrees(formaterNombre(ecart)),
                    style: TextStyle(
                      color: ecart >= 0 ? t.positive : t.streak,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const TextSpan(text: '.'),
              ],
            ),
          ),
      ],
    );
  }
}

/// Histogramme groupé (brief §4.5, remplace la courbe 12 mois qui passait
/// sous zéro) : entrées en gris clair, dépenses en encre, période courante
/// en vert. Toucher une barre affiche ses montants.
class _CarteHistogramme extends StatefulWidget {
  const _CarteHistogramme({required this.barres, required this.periode});

  final List<BarrePeriode> barres;
  final PeriodeAnalyse periode;

  @override
  State<_CarteHistogramme> createState() => _CarteHistogrammeState();
}

class _CarteHistogrammeState extends State<_CarteHistogramme> {
  int? _selection;

  @override
  void didUpdateWidget(_CarteHistogramme ancien) {
    super.didUpdateWidget(ancien);
    if (ancien.periode != widget.periode) _selection = null;
  }

  String _libelle(BuildContext context, BarrePeriode b) => b.semaine > 0
      ? context.l10n.semaineCourte(b.semaine)
      : (widget.barres.length > 6
            ? DateFormat.MMM().format(b.debut).substring(0, 1).toUpperCase()
            : _capitaliser(DateFormat.MMM().format(b.debut)));

  static String _capitaliser(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final texte = Theme.of(context).textTheme;
    final barres = widget.barres;
    final max = barres.fold<int>(1, (m, b) => [m, b.entrees, b.depenses].reduce((a, c) => a > c ? a : c));
    final largeurBarre = barres.length > 6 ? 8.0 : 14.0;
    final sel = _selection == null ? null : barres[_selection!];

    Widget legende(Color c, String l) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 5),
        Text(l, style: texte.bodySmall),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.entreesEtDepenses, style: texte.titleMedium)),
              legende(t.handle, l10n.entrees),
              const SizedBox(width: 12),
              legende(t.ink, l10n.depenses),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 20,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: sel == null
                  ? const SizedBox.shrink()
                  : Text(
                      '${_libelle(context, sel)} · ${formaterSigne(sel.entrees, forcerPlus: true)} / ${formaterSigne(-sel.depenses)}',
                      key: ValueKey(_selection),
                      style: texte.bodySmall?.copyWith(color: t.ink2, fontWeight: FontWeight.w500),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 140,
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.line))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < barres.length; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selection = _selection == i ? null : i);
                      },
                      child: Opacity(
                        opacity: _selection == null || _selection == i ? 1 : 0.45,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _Barre(hauteur: 130 * barres[i].entrees / max, largeur: largeurBarre, couleur: t.handle),
                            SizedBox(width: largeurBarre > 10 ? 4 : 2),
                            _Barre(
                              hauteur: 130 * barres[i].depenses / max,
                              largeur: largeurBarre,
                              couleur: barres[i].courante ? t.positive : t.ink,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final b in barres)
                Expanded(
                  child: Text(
                    _libelle(context, b),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: texte.bodySmall?.copyWith(
                      color: b.courante ? t.ink : t.muted,
                      fontWeight: b.courante ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Barre extends StatelessWidget {
  const _Barre({required this.hauteur, required this.largeur, required this.couleur});

  final double hauteur;
  final double largeur;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: hauteur),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, h, _) => Container(
        width: largeur,
        height: h,
        decoration: BoxDecoration(
          color: couleur,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ),
    );
  }
}

class _OuVaLArgent extends StatelessWidget {
  const _OuVaLArgent({required this.parts, required this.titre});

  final List<PartPeriode> parts;
  final String titre;

  void _toutVoir(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            children: [
              Text(titre, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final p in parts) _LignePart(part: p, max: parts.first.montant),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final texte = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(titre, style: texte.titleMedium)),
            if (parts.length > 4)
              TextButton(onPressed: () => _toutVoir(context), child: Text(l10n.toutVoir)),
          ],
        ),
        if (parts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l10n.pasAssezDonneesComparer, style: texte.bodyMedium?.copyWith(color: context.tokens.muted)),
          ),
        for (final p in parts.take(4)) _LignePart(part: p, max: parts.first.montant),
      ],
    );
  }
}

class _LignePart extends StatelessWidget {
  const _LignePart({required this.part, required this.max});

  final PartPeriode part;
  final int max;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final texte = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(part.categorie.nom, maxLines: 1, overflow: TextOverflow.ellipsis, style: texte.bodyMedium),
              ),
              Text.rich(
                TextSpan(
                  style: texte.bodyMedium,
                  children: [
                    TextSpan(text: formaterNombre(part.montant), style: const TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(text: ' · ${(part.part * 100).round()} %', style: TextStyle(color: t.muted, fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(color: const Color(0xFFE8E8E3)),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: max == 0 ? 0 : part.montant / max),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => FractionallySizedBox(
                      widthFactor: v,
                      child: Container(
                        decoration: BoxDecoration(color: t.ink, borderRadius: BorderRadius.circular(3)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Observations extends StatelessWidget {
  const _Observations({required this.observations});

  final List<String> observations;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final texte = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final o in observations)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(PhosphorIconsRegular.sparkle, size: 16, color: t.positive),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(o, style: texte.bodyMedium?.copyWith(color: t.ink2, height: 1.4))),
              ],
            ),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.titre, required this.enfant});

  final String titre;
  final Widget enfant;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(titre, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          enfant,
        ],
      ),
    );
  }
}
