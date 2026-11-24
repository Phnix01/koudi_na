import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/koudi_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/visuels.dart';
import '../../data/models/categorie.dart';
import '../../data/models/compte.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';
import '../../l10n/l10n.dart';
import '../../logic/providers/capture_form_provider.dart';
import '../../logic/providers/repositories_providers.dart';
import '../../logic/services/calcul_solde.dart';
import '../../logic/services/progression_utilisateur.dart';
import '../../logic/services/tableau_de_bord.dart';
import '../widgets/koudi/bouton_rond.dart';
import '../widgets/koudi/category_tile.dart';
import '../widgets/koudi/numeric_keypad.dart';
import '../widgets/segmented_toggle.dart';

/// Ce que la Saisie renvoie à l'écran qui l'a ouverte, pour la SnackBar
/// « Annuler » et la carte de déblocage de badge.
class ResultatSaisie {
  const ResultatSaisie({
    required this.transaction,
    this.modification = false,
    this.suppression = false,
    this.nouveauxBadges = const [],
  });

  final Transaction transaction;
  final bool modification;
  final bool suppression;
  final List<String> nouveauxBadges;
}

/// Ordre des comptes dans la saisie (brief §4.3) : Banque, Mobile money,
/// Espèces, Coffre, puis les comptes créés par l'utilisateur.
const _ordreTypesComptes = [TypeCompte.banque, TypeCompte.mobileMoney, TypeCompte.especes, TypeCompte.epargne];

List<Compte> comptesOrdonnes(List<Compte> comptes) =>
    comptes.where((c) => c.actif).toList()
      ..sort((a, b) => _ordreTypesComptes.indexOf(a.type).compareTo(_ordreTypesComptes.indexOf(b.type)));

List<Categorie> categoriesDuType(List<Categorie> categories, TypeMouvement type) =>
    categories.where((c) => c.active && c.type == type).toList()..sort((a, b) => a.ordre.compareTo(b.ordre));

/// Écran de saisie plein écran (brief §4.3) — **zéro défilement** :
/// montant, grille de catégories, comptes, pavé et bouton tiennent sur un
/// iPhone SE comme sur un 17 Pro (tailles réduites si la hauteur manque).
/// Sert aussi à modifier une opération existante.
class SaisieScreen extends ConsumerWidget {
  const SaisieScreen.nouvelle({super.key, required this.type}) : aModifier = null;

  SaisieScreen.modifier({super.key, required Transaction transaction})
    : aModifier = transaction,
      type = transaction.type;

  final TypeMouvement type;
  final Transaction? aModifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        captureFormProvider.overrideWith((ref) {
          final existante = aModifier;
          if (existante != null) return CaptureFormNotifier.depuisTransaction(existante);
          final transactions = ref.read(transactionRepositoryProvider).tous();
          final categories = categoriesDuType(ref.read(categorieRepositoryProvider).tous(), type);
          final comptes = comptesOrdonnes(ref.read(compteRepositoryProvider).tous());
          final dernier = dernierChoix(transactions, type);
          final categorie = categories.any((c) => c.id == dernier.categorieId)
              ? dernier.categorieId
              : (categories.isEmpty ? null : categories.first.id);
          final compte = comptes.any((c) => c.id == dernier.compteId)
              ? dernier.compteId!
              : (comptes.isEmpty ? '' : comptes.first.id);
          return CaptureFormNotifier.nouvelle(type: type, categorieId: categorie, compteId: compte);
        }),
      ],
      child: _CorpsSaisie(aModifier: aModifier),
    );
  }
}

class _CorpsSaisie extends ConsumerStatefulWidget {
  const _CorpsSaisie({required this.aModifier});

  final Transaction? aModifier;

  @override
  ConsumerState<_CorpsSaisie> createState() => _CorpsSaisieState();
}

class _CorpsSaisieState extends ConsumerState<_CorpsSaisie> {
  bool _enregistrement = false;

  CaptureFormNotifier get _form => ref.read(captureFormProvider.notifier);

  void _changerType(TypeMouvement type) {
    final transactions = ref.read(transactionRepositoryProvider).tous();
    final categories = categoriesDuType(ref.read(categorieRepositoryProvider).tous(), type);
    final dernier = dernierChoix(transactions, type).categorieId;
    final choix = categories.any((c) => c.id == dernier)
        ? dernier
        : (categories.isEmpty ? null : categories.first.id);
    _form.changerType(type, choix);
  }

  Future<void> _choisirDate() async {
    final actuelle = ref.read(captureFormProvider).date;
    final choisie = await showDatePicker(
      context: context,
      initialDate: actuelle,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (choisie == null) return;
    final maintenant = DateTime.now();
    // Garder l'heure courante : l'ordre des opérations d'un même jour reste juste.
    _form.changerDate(DateTime(choisie.year, choisie.month, choisie.day, maintenant.hour, maintenant.minute));
  }

  Future<void> _editerNote() async {
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FeuilleNote(initiale: ref.read(captureFormProvider).note),
    );
    if (note != null) _form.changerNote(note.trim());
  }

  Future<void> _toutesLesCategories(List<Categorie> categories) async {
    final id = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FeuilleCategories(
        categories: categories,
        selection: ref.read(captureFormProvider).categorieId,
      ),
    );
    if (id != null) _form.choisirCategorie(id);
  }

  Future<void> _enregistrer() async {
    final form = ref.read(captureFormProvider);
    if (_enregistrement || form.montant <= 0 || form.categorieId == null) return;
    setState(() => _enregistrement = true);
    final repo = ref.read(transactionRepositoryProvider);
    final existante = widget.aModifier;
    final transaction = Transaction(
      id: existante?.id ?? const Uuid().v4(),
      date: form.date,
      type: form.type,
      montant: form.montant,
      categorieId: form.categorieId!,
      compteId: form.compteId,
      note: form.note.isEmpty ? null : form.note,
      recurrenteId: existante?.recurrenteId,
    );
    await repo.enregistrer(transaction);
    HapticFeedback.mediumImpact();

    // Seule une saisie active compte pour la série et les badges.
    final badges = existante != null
        ? const <String>[]
        : await enregistrerActiviteEtBadges(
            gamification: ref.read(gamificationRepositoryProvider),
            transactions: repo.tous(),
            categories: ref.read(categorieRepositoryProvider).tous(),
          );
    if (!mounted) return;
    Navigator.of(context).pop(ResultatSaisie(
      transaction: transaction,
      modification: existante != null,
      nouveauxBadges: badges,
    ));
  }

  Future<void> _supprimer() async {
    final existante = widget.aModifier!;
    final l10n = context.l10n;
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.supprimerTransactionTitre),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.annuler)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.supprimer)),
        ],
      ),
    );
    if (confirme != true) return;
    await ref.read(transactionRepositoryProvider).supprimer(existante.id);
    if (!mounted) return;
    Navigator.of(context).pop(ResultatSaisie(transaction: existante, suppression: true));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final form = ref.watch(captureFormProvider);
    final depense = form.type == TypeMouvement.depense;
    final categories = categoriesDuType(ref.watch(categorieRepositoryProvider).tous(), form.type);
    final comptes = comptesOrdonnes(ref.watch(compteRepositoryProvider).tous());
    final transactions = ref
        .watch(transactionRepositoryProvider)
        .tous()
        .where((x) => x.id != widget.aModifier?.id)
        .toList();
    final solde = calculerTotauxDuMois(transactions, maintenant: form.date).solde;
    final reste = solde + (depense ? -form.montant : form.montant);
    final categorieChoisie = categories.where((c) => c.id == form.categorieId).firstOrNull;
    final peutEnregistrer = form.montant > 0 && categorieChoisie != null && form.compteId.isNotEmpty;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, contraintes) {
            // iPhone SE (≈ 647 px utiles) : tuiles 54, touches 44, écarts 8.
            final h = contraintes.maxHeight;
            final compact = h < 720;
            final tresCompact = h < 620;
            final hTuile = tresCompact ? 48.0 : (compact ? 54.0 : 62.0);
            final hTouche = tresCompact ? 40.0 : (compact ? 44.0 : 50.0);
            final ecart = compact ? 8.0 : 12.0;

            return Padding(
              padding: EdgeInsets.fromLTRB(16, compact ? 4 : 10, 16, compact ? 8 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _barre(context, form, depense),
                  SizedBox(height: ecart),
                  _montant(context, form, depense, categorieChoisie, reste, compact),
                  SizedBox(height: ecart),
                  _grille(categories, form.categorieId, hTuile),
                  SizedBox(height: ecart),
                  _comptes(context, comptes, form),
                  const Spacer(),
                  SizedBox(height: ecart),
                  NumericKeypad(
                    hauteurTouche: hTouche,
                    onChiffre: _form.ajouterChiffre,
                    onEffacer: _form.effacerDernierChiffre,
                    onToutEffacer: _form.effacerMontant,
                  ),
                  SizedBox(height: ecart),
                  _boutonEnregistrer(context, form, depense, peutEnregistrer),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _barre(BuildContext context, CaptureFormState form, bool depense) {
    final l10n = context.l10n;
    final aujourdhui = DateUtils.isSameDay(form.date, DateTime.now());
    final libelleDate = aujourdhui ? l10n.aujourdhui : DateFormat.yMMMd().format(form.date);
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          BoutonRond(
            icone: PhosphorIconsRegular.x,
            semantique: l10n.fermer,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          SegmentedToggle<TypeMouvement>(
            largeurSegment: 96,
            hauteur: 34,
            options: [
              SegmentedToggleOption(valeur: TypeMouvement.depense, label: l10n.depense),
              SegmentedToggleOption(valeur: TypeMouvement.entree, label: l10n.entree),
            ],
            selectionne: form.type,
            onChanged: _changerType,
          ),
          const Spacer(),
          if (widget.aModifier != null)
            BoutonRond(
              icone: PhosphorIconsRegular.trash,
              semantique: l10n.supprimer,
              onTap: _supprimer,
            ),
          BoutonRond(
            icone: PhosphorIconsRegular.calendarBlank,
            semantique: l10n.saisieDate(libelleDate),
            actif: !aujourdhui,
            onTap: _choisirDate,
          ),
        ],
      ),
    );
  }

  Widget _montant(
    BuildContext context,
    CaptureFormState form,
    bool depense,
    Categorie? categorie,
    int reste,
    bool compact,
  ) {
    final t = context.tokens;
    final texte = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final devise = deviseCourante;
    final vide = form.montant == 0;
    final styleNombre = texte.displayLarge?.copyWith(
      fontSize: compact ? 52 : 60,
      color: vide ? t.disabled : t.ink,
    );
    final styleUnite = texte.bodyLarge?.copyWith(fontSize: 17, color: t.muted, letterSpacing: 0);
    final aujourdhui = DateUtils.isSameDay(form.date, DateTime.now());

    return Column(
      children: [
        SizedBox(
          height: compact ? 56 : 64,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  depense ? signeMoins : '+',
                  style: texte.bodyLarge?.copyWith(
                    fontSize: 18,
                    color: depense ? t.muted : t.positive,
                  ),
                ),
                const SizedBox(width: 8),
                if (devise.avantLeMontant) ...[
                  Text(devise.symbole, style: styleUnite),
                  const SizedBox(width: 4),
                ],
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 120),
                  transitionBuilder: (child, a) => FadeTransition(opacity: a, child: child),
                  child: Text(
                    formaterNombre(form.montant),
                    key: ValueKey(form.montant),
                    style: styleNombre,
                  ),
                ),
                if (!devise.avantLeMontant) ...[
                  const SizedBox(width: 8),
                  Text(devise.symbole, style: styleUnite),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (categorie != null)
          Text.rich(
            TextSpan(
              style: texte.labelMedium?.copyWith(color: t.muted, fontWeight: FontWeight.w400),
              children: [
                if (!aujourdhui) TextSpan(text: '${DateFormat.MMMd().format(form.date)} · '),
                TextSpan(text: '${categorie.nom} · ${l10n.saisieResteAvant}'),
                TextSpan(
                  text: reste >= 0 ? formaterNombre(reste) : formaterSigne(reste),
                  style: TextStyle(
                    color: reste >= 0 ? t.positive : t.streak,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: l10n.saisieResteApres),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _grille(List<Categorie> categories, String? selection, double hauteurTuile) {
    // 12 tuiles au plus (3 rangées) ; au-delà, une tuile « Plus » ouvre la
    // liste complète, et la catégorie choisie y reste visible.
    var visibles = categories;
    final debordement = categories.length > 12;
    if (debordement) {
      visibles = categories.take(11).toList();
      final choisie = categories.where((c) => c.id == selection).firstOrNull;
      if (choisie != null && !visibles.contains(choisie)) visibles[10] = choisie;
    }
    final t = context.tokens;
    final tuiles = <Widget>[
      for (final c in visibles)
        CategoryTile(
          icone: c.icone,
          libelle: c.nomCourt,
          couleur: c.couleur,
          teinte: c.teinte,
          selectionnee: c.id == selection,
          hauteur: hauteurTuile,
          onTap: () => _form.choisirCategorie(c.id),
        ),
      if (debordement)
        CategoryTile(
          icone: PhosphorIconsRegular.squaresFour,
          libelle: context.l10n.saisiePlus,
          couleur: t.ink2,
          teinte: t.surfaceMuted,
          selectionnee: false,
          hauteur: hauteurTuile,
          onTap: () => _toutesLesCategories(categories),
        ),
    ];

    return Column(
      children: [
        for (var debut = 0; debut < tuiles.length; debut += 4) ...[
          if (debut > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (var i = debut; i < debut + 4; i++) ...[
                if (i > debut) const SizedBox(width: 8),
                Expanded(child: i < tuiles.length ? tuiles[i] : const SizedBox.shrink()),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _comptes(BuildContext context, List<Compte> comptes, CaptureFormState form) {
    final t = context.tokens;
    final l10n = context.l10n;
    final aNote = form.note.isNotEmpty;

    Widget puce(Compte c, {bool etirer = true}) {
      final sel = c.id == form.compteId;
      final bouton = Semantics(
        button: true,
        selected: sel,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            _form.choisirCompte(c.id);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            constraints: etirer ? null : const BoxConstraints(minWidth: 84),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sel ? t.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: sel ? t.ink : t.lineStrong),
            ),
            // « Mobile money » rétrécit un peu plutôt que d'être coupé.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                c.nom,
                maxLines: 1,
                textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.15),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: sel ? t.onInk : t.ink2,
                ),
              ),
            ),
          ),
        ),
      );
      return etirer ? Expanded(child: bouton) : bouton;
    }

    final boutonNote = Semantics(
      button: true,
      label: aNote ? '${l10n.saisieNote} : ${form.note}' : l10n.saisieNoteAjouter,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: _editerNote,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: aNote ? t.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: aNote ? t.ink : t.lineStrong),
          ),
          child: Icon(PhosphorIconsRegular.pencilSimple, size: 16, color: aNote ? t.onInk : t.muted),
        ),
      ),
    );

    // Jusqu'à 4 comptes : puces de même largeur (maquette). Au-delà, la
    // rangée défile horizontalement — l'écran, lui, ne défile jamais.
    final rangee = comptes.length <= 4
        ? Row(children: [for (final c in comptes) ...[puce(c), const SizedBox(width: 6)]])
        : SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: comptes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, i) => puce(comptes[i], etirer: false),
            ),
          );

    return Row(
      children: [
        Expanded(child: rangee),
        if (comptes.length > 4) const SizedBox(width: 6),
        boutonNote,
      ],
    );
  }

  Widget _boutonEnregistrer(BuildContext context, CaptureFormState form, bool depense, bool actif) {
    final t = context.tokens;
    final l10n = context.l10n;
    final montant = formaterMontant(form.montant);
    final libelle = form.montant == 0
        ? l10n.saisieMontantVide
        : widget.aModifier != null
        ? l10n.saisieEnregistrerModifs
        : l10n.saisieEnregistrerMontant('${depense ? signeMoins : '+'}$montant');
    final fond = !actif ? t.ctaDisabled : (depense ? t.ink : t.positive);

    return Semantics(
      button: true,
      enabled: actif,
      child: GestureDetector(
        onTap: actif ? _enregistrer : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: fond, borderRadius: BorderRadius.circular(16)),
          child: _enregistrement
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: t.onInk),
                )
              : Text(
                  libelle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: actif ? t.onInk : t.muted,
                  ),
                ),
        ),
      ),
    );
  }
}

class _FeuilleNote extends StatefulWidget {
  const _FeuilleNote({required this.initiale});

  final String initiale;

  @override
  State<_FeuilleNote> createState() => _FeuilleNoteState();
}

class _FeuilleNoteState extends State<_FeuilleNote> {
  late final _controleur = TextEditingController(text: widget.initiale);

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Poignee(),
          Text(l10n.saisieNote, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _controleur,
            autofocus: true,
            maxLength: 80,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: l10n.saisieNoteIndice, counterText: ''),
            onSubmitted: (v) => Navigator.of(context).pop(v),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(_controleur.text),
            child: Text(l10n.enregistrer),
          ),
        ],
      ),
    );
  }
}

class _FeuilleCategories extends StatelessWidget {
  const _FeuilleCategories({required this.categories, required this.selection});

  final List<Categorie> categories;
  final String? selection;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Poignee(),
            Text(context.l10n.saisieToutesCategories, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Flexible(
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.25,
                children: [
                  for (final c in categories)
                    CategoryTile(
                      icone: c.icone,
                      libelle: c.nomCourt,
                      couleur: c.couleur,
                      teinte: c.teinte,
                      selectionnee: c.id == selection,
                      onTap: () => Navigator.of(context).pop(c.id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Poignee extends StatelessWidget {
  const _Poignee();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 5,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: context.tokens.handle,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
