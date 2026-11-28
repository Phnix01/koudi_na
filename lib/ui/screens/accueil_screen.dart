import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/koudi_tokens.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/visuels.dart';
import '../../data/models/pilier.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';
import '../../l10n/l10n.dart';
import '../../logic/providers/devise_provider.dart';
import '../../logic/providers/navigation_provider.dart';
import '../../logic/providers/repositories_providers.dart';
import '../../logic/services/calcul_solde.dart';
import '../../logic/services/tableau_de_bord.dart';
import '../navigation/saisie_navigation.dart';
import '../widgets/indicateur_serie.dart';
import '../widgets/koudi/amount_text.dart';
import '../widgets/koudi/progress_line.dart';
import '../widgets/koudi/transaction_row.dart';

/// Accueil (brief §4.1) : le mois en un coup d'œil, sans grille bento.
/// Solde, entrées/dépenses, rythme, fin de mois, enveloppes 40/25/35 et
/// dernières opérations. Défile sur petit écran, jamais de débordement.
class AccueilScreen extends ConsumerWidget {
  const AccueilScreen({super.key, required this.cleSolde, required this.cleSerie});

  /// Ancres de la visite guidée.
  final GlobalKey cleSolde;
  final GlobalKey cleSerie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(transactionRepositoryProvider);
    final categoriesRepo = ref.watch(categorieRepositoryProvider);
    final comptesRepo = ref.watch(compteRepositoryProvider);
    final mois = ref.watch(moisAfficheProvider);
    // Changer de devise redessine les montants.
    ref.watch(deviseProvider);

    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder(
        valueListenable: repo.listenable(),
        builder: (context, _, _) {
          final transactions = repo.tous();
          final categories = categoriesRepo.tous();
          final comptes = {for (final c in comptesRepo.tous()) c.id: c};
          final categorieParId = {for (final c in categories) c.id: c};
          final tableau = calculerTableauDeBord(transactions, categories, mois: mois);
          final duMois = transactions
              .where((t) => t.date.year == mois.year && t.date.month == mois.month)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              _EnTete(mois: mois, cleSerie: cleSerie, transactions: transactions),
              KeyedSubtree(key: cleSolde, child: _Solde(tableau: tableau)),
              const SizedBox(height: 12),
              _EntreesDepenses(tableau: tableau),
              if (tableau.rythme != null) ...[
                const SizedBox(height: 16),
                _Rythme(rythme: tableau.rythme!),
              ],
              const SizedBox(height: 16),
              _Cartes(tableau: tableau),
              const SizedBox(height: 18),
              _Enveloppes(tableau: tableau),
              const SizedBox(height: 14),
              _Recents(
                recents: duMois.take(2).toList(),
                ligne: (t, separateur) => TransactionRow(
                  transaction: t,
                  categorie: categorieParId[t.categorieId],
                  compte: comptes[t.compteId],
                  hauteur: 52,
                  taillePastille: 36,
                  separateur: separateur,
                  sousTitre: [
                    libelleJourCourt(t.date, context.l10n),
                    comptes[t.compteId]?.nom ?? '',
                  ].where((s) => s.isNotEmpty).join(' · '),
                  onTap: () => ouvrirEdition(context, t),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EnTete extends ConsumerWidget {
  const _EnTete({required this.mois, required this.cleSerie, required this.transactions});

  final DateTime mois;
  final GlobalKey cleSerie;
  final List<Transaction> transactions;

  Future<void> _choisirMois(BuildContext context, WidgetRef ref) async {
    final maintenant = DateTime.now();
    var premier = DateTime(maintenant.year, maintenant.month);
    for (final t in transactions) {
      final m = DateTime(t.date.year, t.date.month);
      if (m.isBefore(premier)) premier = m;
    }
    final moisDispo = <DateTime>[];
    for (var m = DateTime(maintenant.year, maintenant.month);
        !m.isBefore(premier) && moisDispo.length < 36;
        m = DateTime(m.year, m.month - 1)) {
      moisDispo.add(m);
    }
    final choisi = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FeuilleMois(mois: moisDispo, selection: mois, transactions: transactions),
    );
    if (choisi != null) ref.read(moisAfficheProvider.notifier).state = choisi;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Semantics(
            button: true,
            label: '${context.l10n.accueilChoisirMois}, ${libelleMois(mois)}',
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _choisirMois(context, ref),
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    Text(libelleMois(mois), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16)),
                    const SizedBox(width: 4),
                    Icon(PhosphorIconsRegular.caretDown, size: 16, color: t.muted),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          IndicateurSerie(key: cleSerie),
        ],
      ),
    );
  }
}

class _Solde extends StatelessWidget {
  const _Solde({required this.tableau});

  final TableauDeBord tableau;

  @override
  Widget build(BuildContext context) {
    final texte = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.soldeDuMois, style: texte.labelMedium?.copyWith(color: context.tokens.muted)),
          const SizedBox(height: 2),
          TweenAnimationBuilder<double>(
            tween: Tween(end: tableau.solde.toDouble()),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => AmountText(
              v.round(),
              style: texte.displayMedium,
              tailleUnite: 18,
              ajuster: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntreesDepenses extends StatelessWidget {
  const _EntreesDepenses({required this.tableau});

  final TableauDeBord tableau;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final texte = Theme.of(context).textTheme;
    final valeur = texte.titleMedium?.copyWith(fontSize: 17);
    Widget colonne(String libelle, String montant, Color couleur) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(libelle, style: texte.bodySmall),
        const SizedBox(height: 1),
        FittedBox(fit: BoxFit.scaleDown, child: Text(montant, style: valeur?.copyWith(color: couleur))),
      ],
    );
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: colonne(l10n.entrees, formaterSigne(tableau.entrees), t.positive)),
          VerticalDivider(width: 1, thickness: 1, color: t.lineStrong),
          const SizedBox(width: 16),
          Expanded(child: colonne(l10n.depenses, formaterSigne(-tableau.depenses), t.ink)),
        ],
      ),
    );
  }
}

class _Rythme extends StatelessWidget {
  const _Rythme({required this.rythme});

  final RythmeDepenses rythme;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final petit = Theme.of(context).textTheme.bodySmall;
    final termine = rythme.jour >= rythme.joursDuMois;
    final droite = termine
        ? l10n.accueilMoisTermine
        : '${l10n.accueilRythmeJour(rythme.jour, rythme.joursDuMois)} · '
              '${rythme.enAvance ? l10n.accueilEnAvance : l10n.accueilAttentionRythme}';
    final couleurDroite = termine ? t.muted : (rythme.enAvance ? t.positive : t.streak);

    return Column(
      children: [
        ProgressLine(
          valeur: rythme.ratioDepense,
          couleur: rythme.ratioDepense > 1 ? t.streak : t.ink,
          hauteur: 8,
          marqueur: termine ? null : rythme.ratioTemps,
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.accueilRythmeDepense((rythme.ratioDepense * 100).round()),
                style: petit,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(droite, style: petit?.copyWith(color: couleurDroite, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}

class _Cartes extends ConsumerWidget {
  const _Cartes({required this.tableau});

  final TableauDeBord tableau;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final ecart = tableau.entrees - tableau.projectionFinDeMois;
    final (sousTitreFin, couleurFin) = tableau.entrees == 0
        ? (l10n.accueilSansEntree, t.muted)
        : ecart >= 0
        ? (l10n.accueilSousEntrees(formaterNombre(ecart)), t.positive)
        : (l10n.accueilAuDessusEntrees(formaterNombre(ecart)), t.streak);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _Carte(
              titre: l10n.accueilFinDeMois,
              icone: PhosphorIconsRegular.arrowUpRight,
              onTap: () => ref.read(ongletProvider.notifier).state = 2,
              valeur: AmountText(
                tableau.projectionFinDeMois,
                prefixe: '≈',
                avecUnite: false,
                ajuster: true,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              sousTitre: sousTitreFin,
              couleurSousTitre: couleurFin,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Carte(
              titre: l10n.accueilMoyenneJour,
              valeur: AmountText(
                tableau.moyenneParJour,
                avecUnite: false,
                ajuster: true,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              sousTitre: l10n.accueilHorsEpargne(formaterNombre(tableau.moyenneParJourHorsEpargne)),
              couleurSousTitre: t.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _Carte extends StatelessWidget {
  const _Carte({
    required this.titre,
    required this.valeur,
    required this.sousTitre,
    required this.couleurSousTitre,
    this.icone,
    this.onTap,
  });

  final String titre;
  final Widget valeur;
  final String sousTitre;
  final Color couleurSousTitre;
  final IconData? icone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final texte = Theme.of(context).textTheme;
    return Material(
      color: t.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: t.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      titre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: texte.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (icone != null) Icon(icone, size: 14, color: t.muted),
                ],
              ),
              const SizedBox(height: 3),
              valeur,
              const SizedBox(height: 3),
              Text(
                sousTitre,
                maxLines: 2,
                style: texte.bodySmall?.copyWith(color: couleurSousTitre, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Enveloppes extends StatelessWidget {
  const _Enveloppes({required this.tableau});

  final TableauDeBord tableau;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final texte = Theme.of(context).textTheme;
    final couleurs = {Pilier.epargne: t.positive, Pilier.famille: t.family, Pilier.vie: t.ink};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(l10n.accueilEnveloppes, style: texte.titleMedium),
            const Spacer(),
            Text('40 · 25 · 35', style: texte.bodySmall),
          ],
        ),
        const SizedBox(height: 2),
        if (tableau.entrees == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.accueilEnveloppesVide, style: texte.bodyMedium?.copyWith(color: t.ink2)),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => ouvrirSaisie(context, TypeMouvement.entree),
                  icon: Icon(PhosphorIconsBold.plus, size: 14, color: t.positive),
                  label: Text(l10n.accueilAjouterEntree),
                ),
              ],
            ),
          )
        else
          for (final e in tableau.enveloppes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text.rich(
                        TextSpan(
                          style: texte.labelMedium,
                          children: [
                            TextSpan(text: l10n.libellePilier(e.pilier)),
                            TextSpan(
                              text: ' · ${formaterPourcent((e.progression * 100).round())}',
                              style: TextStyle(color: t.muted, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text.rich(
                        TextSpan(
                          style: texte.labelMedium?.copyWith(color: e.reste < 0 ? t.streak : t.muted, fontWeight: FontWeight.w400),
                          children: [
                            TextSpan(text: '${e.reste < 0 ? l10n.accueilDepasseDe : l10n.accueilReste} '),
                            TextSpan(
                              text: formaterNombre(e.reste),
                              style: TextStyle(
                                color: e.reste < 0 ? t.streak : t.ink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ProgressLine(
                    valeur: e.progression,
                    couleur: e.reste < 0 ? t.streak : couleurs[e.pilier]!,
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

class _Recents extends ConsumerWidget {
  const _Recents({required this.recents, required this.ligne});

  final List<Transaction> recents;
  final Widget Function(Transaction, bool separateur) ligne;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final texte = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(l10n.accueilRecents, style: texte.titleMedium),
            const Spacer(),
            TextButton(
              onPressed: () => ref.read(ongletProvider.notifier).state = 1,
              child: Text(l10n.toutVoir),
            ),
          ],
        ),
        if (recents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l10n.accueilRecentsVide, style: texte.bodyMedium?.copyWith(color: t.muted)),
          )
        else
          for (var i = 0; i < recents.length; i++) ligne(recents[i], i < recents.length - 1),
      ],
    );
  }
}

class _FeuilleMois extends StatelessWidget {
  const _FeuilleMois({required this.mois, required this.selection, required this.transactions});

  final List<DateTime> mois;
  final DateTime selection;
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final texte = Theme.of(context).textTheme;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 16),
                decoration: BoxDecoration(color: t.handle, borderRadius: BorderRadius.circular(3)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(context.l10n.accueilChoisirMois, style: texte.titleLarge),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: mois.length,
                itemBuilder: (context, i) {
                  final m = mois[i];
                  final sel = m.year == selection.year && m.month == selection.month;
                  final solde = calculerTotauxDuMois(transactions, maintenant: m).solde;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    title: Text(
                      libelleMois(m),
                      style: texte.bodyLarge?.copyWith(fontWeight: sel ? FontWeight.w600 : FontWeight.w500),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(formaterSigne(solde), style: texte.bodyMedium?.copyWith(color: t.muted)),
                        if (sel) ...[
                          const SizedBox(width: 10),
                          Icon(PhosphorIconsBold.check, size: 16, color: t.positive),
                        ],
                      ],
                    ),
                    onTap: () => Navigator.of(context).pop(m),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
