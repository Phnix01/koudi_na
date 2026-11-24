import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/koudi_tokens.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/visuels.dart';
import '../../data/models/categorie.dart';
import '../../data/models/compte.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';
import '../../l10n/l10n.dart';
import '../../logic/providers/devise_provider.dart';
import '../../logic/providers/navigation_provider.dart';
import '../../logic/providers/repositories_providers.dart';
import '../../logic/services/calcul_solde.dart';
import '../../logic/services/groupement_transactions.dart';
import '../navigation/saisie_navigation.dart';
import 'saisie_screen.dart' show comptesOrdonnes;
import '../widgets/koudi/transaction_row.dart';

/// Journal (brief §4.4) : toutes les opérations du mois, groupées par
/// jour, avec recherche plein texte, filtres et suppression par glissé.
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  TypeMouvement? _type;
  String? _categorieId;
  String? _compteId;
  bool _recherche = false;
  String _requete = '';
  final _champRecherche = TextEditingController();

  @override
  void dispose() {
    _champRecherche.dispose();
    super.dispose();
  }

  void _decalerMois(int delta) {
    HapticFeedback.selectionClick();
    final mois = ref.read(moisAfficheProvider);
    ref.read(moisAfficheProvider.notifier).state = DateTime(mois.year, mois.month + delta);
  }

  bool _correspond(Transaction t, Categorie? categorie, Compte? compte) {
    if (_type != null && t.type != _type) return false;
    if (_categorieId != null && t.categorieId != _categorieId) return false;
    if (_compteId != null && t.compteId != _compteId) return false;
    final q = _requete.trim().toLowerCase();
    if (q.isEmpty) return true;
    final chiffres = q.replaceAll(RegExp(r'[\s .,]'), '');
    return (t.note ?? '').toLowerCase().contains(q) ||
        (categorie?.nom.toLowerCase().contains(q) ?? false) ||
        (compte?.nom.toLowerCase().contains(q) ?? false) ||
        (chiffres.isNotEmpty && RegExp(r'^\d+$').hasMatch(chiffres) && '${t.montant}'.contains(chiffres));
  }

  Future<void> _ouvrirFiltres(List<Categorie> categories, List<Compte> comptes) async {
    final resultat = await showModalBottomSheet<({String? categorieId, String? compteId})>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FeuilleFiltres(
        categories: categories,
        comptes: comptes,
        categorieId: _categorieId,
        compteId: _compteId,
      ),
    );
    if (resultat != null) {
      setState(() {
        _categorieId = resultat.categorieId;
        _compteId = resultat.compteId;
      });
    }
  }

  Future<void> _supprimer(Transaction transaction) async {
    final repo = ref.read(transactionRepositoryProvider);
    await repo.supprimer(transaction.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.transactionSupprimee),
          action: SnackBarAction(label: context.l10n.annuler, onPressed: () => repo.enregistrer(transaction)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final texte = Theme.of(context).textTheme;
    final repo = ref.watch(transactionRepositoryProvider);
    final mois = ref.watch(moisAfficheProvider);
    ref.watch(deviseProvider);
    final categories = ref.watch(categorieRepositoryProvider).tous();
    final comptes = comptesOrdonnes(ref.watch(compteRepositoryProvider).tous());
    final categorieParId = {for (final c in categories) c.id: c};
    final compteParId = {for (final c in ref.watch(compteRepositoryProvider).tous()) c.id: c};
    final nbFiltres = (_categorieId != null ? 1 : 0) + (_compteId != null ? 1 : 0);

    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder(
        valueListenable: repo.listenable(),
        builder: (context, _, _) {
          final duMois = repo
              .tous()
              .where((x) => x.date.year == mois.year && x.date.month == mois.month)
              .toList();
          final filtrees = duMois
              .where((x) => _correspond(x, categorieParId[x.categorieId], compteParId[x.compteId]))
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          final totaux = calculerTotauxDuMois(filtrees, maintenant: mois);
          final journees = grouperParJour(filtrees);

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverList.list(
                  children: [
                    _enTete(context),
                    const SizedBox(height: 16),
                    _barreMois(context, mois),
                    const SizedBox(height: 16),
                    _totaux(context, totaux),
                    const SizedBox(height: 16),
                    _filtres(context, categories, comptes, nbFiltres),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              if (journees.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
                    child: Column(
                      children: [
                        Icon(PhosphorIconsRegular.receipt, size: 32, color: t.disabled),
                        const SizedBox(height: 10),
                        Text(
                          duMois.isEmpty ? l10n.journalVide : l10n.journalAucunResultat,
                          textAlign: TextAlign.center,
                          style: texte.bodyMedium?.copyWith(color: t.muted),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverList.builder(
                    itemCount: journees.length,
                    itemBuilder: (context, i) {
                      final j = journees[i];
                      return Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      libelleJourComplet(j.jour, l10n),
                                      style: texte.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Text(
                                    formaterSigne(j.total),
                                    style: texte.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            for (final x in j.transactions)
                              Dismissible(
                                key: ValueKey(x.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    color: t.streak.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(PhosphorIconsRegular.trash, color: t.streak),
                                ),
                                onDismissed: (_) => _supprimer(x),
                                child: TransactionRow(
                                  transaction: x,
                                  categorie: categorieParId[x.categorieId],
                                  compte: compteParId[x.compteId],
                                  onTap: () => ouvrirEdition(context, x),
                                ),
                              ),
                          ],
                        ),
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

  Widget _enTete(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    return SizedBox(
      height: 44,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _recherche
            ? Row(
                key: const ValueKey('recherche'),
                children: [
                  Expanded(
                    child: TextField(
                      controller: _champRecherche,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: (v) => setState(() => _requete = v),
                      decoration: InputDecoration(
                        hintText: l10n.journalRechercheIndice,
                        isDense: true,
                        prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass, size: 18, color: t.muted),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _recherche = false;
                      _requete = '';
                      _champRecherche.clear();
                    }),
                    child: Text(l10n.annuler),
                  ),
                ],
              )
            : Row(
                key: const ValueKey('titre'),
                children: [
                  Text(l10n.ongletJournal, style: Theme.of(context).textTheme.headlineMedium),
                  const Spacer(),
                  IconButton(
                    tooltip: l10n.journalRechercher,
                    onPressed: () => setState(() => _recherche = true),
                    icon: const Icon(PhosphorIconsRegular.magnifyingGlass, size: 21),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _barreMois(BuildContext context, DateTime mois) {
    final t = context.tokens;
    final l10n = context.l10n;
    final maintenant = DateTime.now();
    final estCourant = mois.year == maintenant.year && mois.month == maintenant.month;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.line),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.moisPrecedent,
            onPressed: () => _decalerMois(-1),
            icon: Icon(PhosphorIconsRegular.caretLeft, size: 18, color: t.muted),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Text(
                libelleMois(mois),
                key: ValueKey(mois),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.moisSuivant,
            onPressed: estCourant ? null : () => _decalerMois(1),
            icon: Icon(PhosphorIconsRegular.caretRight, size: 18, color: estCourant ? t.disabled : t.muted),
          ),
        ],
      ),
    );
  }

  Widget _totaux(BuildContext context, TotauxMois totaux) {
    final t = context.tokens;
    final l10n = context.l10n;
    final texte = Theme.of(context).textTheme;
    Widget colonne(String libelle, String valeur, Color couleur, {bool filet = true}) => Expanded(
      child: Container(
        padding: EdgeInsets.only(left: filet ? 14 : 0),
        decoration: filet ? BoxDecoration(border: Border(left: BorderSide(color: t.line))) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(libelle, style: texte.bodySmall),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(valeur, style: texte.titleMedium?.copyWith(fontSize: 16, color: couleur)),
            ),
          ],
        ),
      ),
    );
    return Row(
      children: [
        colonne(l10n.entrees, formaterSigne(totaux.entrees, forcerPlus: true), t.positive, filet: false),
        colonne(l10n.depenses, formaterSigne(-totaux.depenses), t.ink),
        colonne(l10n.solde, totaux.solde < 0 ? formaterSigne(totaux.solde) : formaterNombre(totaux.solde), t.ink),
      ],
    );
  }

  Widget _filtres(BuildContext context, List<Categorie> categories, List<Compte> comptes, int nbFiltres) {
    final t = context.tokens;
    final l10n = context.l10n;
    Widget pilule(String libelle, TypeMouvement? valeur) {
      final sel = _type == valeur;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _type = valeur);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sel ? t.ink : t.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: sel ? t.ink : t.line),
            ),
            child: Text(
              libelle,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: sel ? t.onInk : t.ink2,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        pilule(l10n.filtreTout, null),
        pilule(l10n.depenses, TypeMouvement.depense),
        pilule(l10n.entrees, TypeMouvement.entree),
        const Spacer(),
        GestureDetector(
          onTap: () => _ouvrirFiltres(categories, comptes),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: nbFiltres > 0 ? t.ink : t.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: nbFiltres > 0 ? t.ink : t.line),
            ),
            child: Row(
              children: [
                Text(
                  nbFiltres > 0 ? '${l10n.filtres} · $nbFiltres' : l10n.filtres,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: nbFiltres > 0 ? t.onInk : t.ink2,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(PhosphorIconsRegular.caretDown, size: 14, color: nbFiltres > 0 ? t.onInk : t.ink2),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FeuilleFiltres extends StatefulWidget {
  const _FeuilleFiltres({
    required this.categories,
    required this.comptes,
    required this.categorieId,
    required this.compteId,
  });

  final List<Categorie> categories;
  final List<Compte> comptes;
  final String? categorieId;
  final String? compteId;

  @override
  State<_FeuilleFiltres> createState() => _FeuilleFiltresState();
}

class _FeuilleFiltresState extends State<_FeuilleFiltres> {
  late String? _categorieId = widget.categorieId;
  late String? _compteId = widget.compteId;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final texte = Theme.of(context).textTheme;
    final categories = [...widget.categories]
      ..sort((a, b) => a.type == b.type ? a.ordre.compareTo(b.ordre) : a.type.index.compareTo(b.type.index));

    Widget puce(String libelle, bool sel, VoidCallback onTap, {Color? couleur}) => GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: sel ? t.ink : t.surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: sel ? t.ink : t.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (couleur != null) ...[
              Container(width: 8, height: 8, decoration: BoxDecoration(color: couleur, shape: BoxShape.circle)),
              const SizedBox(width: 6),
            ],
            Text(libelle, style: texte.labelMedium?.copyWith(color: sel ? t.onInk : t.ink2)),
          ],
        ),
      ),
    );

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: t.handle, borderRadius: BorderRadius.circular(3)),
                ),
              ),
              Text(l10n.filtres, style: texte.titleLarge),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.categorie, style: texte.bodySmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          puce(l10n.filtreTout, _categorieId == null, () => setState(() => _categorieId = null)),
                          for (final c in categories)
                            puce(c.nom, _categorieId == c.id, () => setState(() => _categorieId = c.id), couleur: c.couleur),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.compte, style: texte.bodySmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          puce(l10n.filtreTout, _compteId == null, () => setState(() => _compteId = null)),
                          for (final c in widget.comptes)
                            puce(c.nom, _compteId == c.id, () => setState(() => _compteId = c.id)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop((categorieId: _categorieId, compteId: _compteId)),
                child: Text(l10n.filtres),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
