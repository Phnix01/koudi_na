import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/koudi_tokens.dart';
import '../../data/models/type_mouvement.dart';
import '../../l10n/l10n.dart';
import '../../logic/providers/didacticiel_provider.dart';
import '../../logic/providers/langue_provider.dart';
import '../../logic/providers/navigation_provider.dart';
import '../../logic/providers/notifications_provider.dart';
import '../../logic/providers/repositories_providers.dart';
import '../../logic/services/alerte_depassement.dart';
import '../../logic/services/calcul_piliers.dart';
import '../navigation/saisie_navigation.dart';
import '../screens/accueil_screen.dart';
import '../screens/analyse_screen.dart';
import '../screens/journal_screen.dart';
import '../screens/reglages_screen.dart';
import '../widgets/didacticiel.dart';
import '../widgets/koudi/nouvelle_operation_sheet.dart';

/// Coquille de l'app (brief §3.1) : Accueil · Journal · [+] · Analyse ·
/// Réglages. Les onglets gardent leur état (défilement, filtres) quand on
/// passe de l'un à l'autre ; le + ouvre le sheet « Nouvelle opération »,
/// un appui long va droit à une dépense.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> with WidgetsBindingObserver {
  final _cleSolde = GlobalKey();
  final _cleSerie = GlobalKey();
  final _clePlus = GlobalKey();
  final _cleJournal = GlobalKey();
  final _cleAnalyse = GlobalKey();
  final _cleReglages = GlobalKey();
  bool _sheetOuvert = false;
  bool _didacticielEnCours = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verifierDepassements();
      if (!ref.read(reglagesRepositoryProvider).didacticielVu) _lancerDidacticiel();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _verifierDepassements();
  }

  /// À chaque retour au premier plan : un pilier qui dépasse sa cible du
  /// mois et ne l'a pas encore signalé déclenche une notification locale
  /// (aucun calcul en arrière-plan, l'app est 100 % hors ligne).
  Future<void> _verifierDepassements() async {
    final transactions = ref.read(transactionRepositoryProvider).tous();
    final categories = ref.read(categorieRepositoryProvider).tous();
    final gamification = ref.read(gamificationRepositoryProvider);
    final maintenant = DateTime.now();
    final enDepassement = piliersEnDepassementNonAlertes(
      calculerProgressionPiliers(transactions, categories, maintenant: maintenant),
      (pilier) => gamification.dejaAlertePourCeMois(pilier, maintenant),
    );
    if (enDepassement.isEmpty || !mounted) return;
    final l10n = context.l10n;
    final notifications = ref.read(notificationsServiceProvider);
    for (final pilier in enDepassement) {
      await gamification.marquerAlertePourCeMois(pilier, maintenant);
      await notifications.afficherAlerteDepassement(
        pilier,
        titre: l10n.notificationDepassementNotifTitre,
        corps: l10n.notificationDepassementNotifCorps(l10n.libellePilier(pilier)),
      );
    }
  }

  Future<void> _lancerDidacticiel() async {
    if (_didacticielEnCours) return;
    _didacticielEnCours = true;
    try {
      ref.read(ongletProvider.notifier).state = 0;
      // Laisse finir la transition qui amène ici (fin de l'onboarding,
      // retour depuis Réglages) : les cibles doivent être à leur place.
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      final l10n = context.l10n;
      await lancerDidacticiel(context, [
        EtapeDidacticiel(cible: _cleSolde, titre: l10n.didacticielSoldeTitre, texte: l10n.didacticielSoldeTexte),
        EtapeDidacticiel(cible: _cleSerie, titre: l10n.didacticielSerieTitre, texte: l10n.didacticielSerieTexte, ronde: true),
        EtapeDidacticiel(cible: _clePlus, titre: l10n.didacticielPlusTitre, texte: l10n.didacticielPlusTexte, ronde: true),
        EtapeDidacticiel(cible: _cleJournal, titre: l10n.didacticielMoisTitre, texte: l10n.didacticielMoisTexte, ronde: true),
        EtapeDidacticiel(cible: _cleAnalyse, titre: l10n.didacticielAnalyseTitre, texte: l10n.didacticielAnalyseTexte, ronde: true),
        EtapeDidacticiel(cible: _cleReglages, titre: l10n.didacticielReglagesTitre, texte: l10n.didacticielReglagesTexte, ronde: true),
      ]);
      await ref.read(reglagesRepositoryProvider).marquerDidacticielVu();
    } finally {
      _didacticielEnCours = false;
    }
  }

  Future<void> _ouvrirSheet() async {
    HapticFeedback.lightImpact();
    setState(() => _sheetOuvert = true);
    final resultat = await afficherNouvelleOperation(context);
    if (!mounted) return;
    setState(() => _sheetOuvert = false);
    if (resultat != null) await gererResultatSaisie(context, resultat);
  }

  Future<void> _depenseDirecte() async {
    HapticFeedback.mediumImpact();
    await ouvrirSaisie(context, TypeMouvement.depense);
  }

  @override
  Widget build(BuildContext context) {
    final onglet = ref.watch(ongletProvider);
    ref.listen(demandeDidacticielProvider, (_, _) => _lancerDidacticiel());

    return Scaffold(
      body: IndexedStack(
        index: onglet,
        children: [
          AccueilScreen(cleSolde: _cleSolde, cleSerie: _cleSerie),
          const JournalScreen(),
          const AnalyseScreen(),
          const ReglagesScreen(),
        ],
      ),
      bottomNavigationBar: _BarreOnglets(
        onglet: onglet,
        sheetOuvert: _sheetOuvert,
        clePlus: _clePlus,
        cles: [null, _cleJournal, _cleAnalyse, _cleReglages],
        onOnglet: (i) {
          if (i == onglet) return;
          HapticFeedback.selectionClick();
          ref.read(ongletProvider.notifier).state = i;
        },
        onPlus: _ouvrirSheet,
        onPlusLong: _depenseDirecte,
      ),
    );
  }
}

class _BarreOnglets extends StatelessWidget {
  const _BarreOnglets({
    required this.onglet,
    required this.sheetOuvert,
    required this.clePlus,
    required this.cles,
    required this.onOnglet,
    required this.onPlus,
    required this.onPlusLong,
  });

  final int onglet;
  final bool sheetOuvert;
  final GlobalKey clePlus;
  final List<GlobalKey?> cles;
  final ValueChanged<int> onOnglet;
  final VoidCallback onPlus;
  final VoidCallback onPlusLong;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final items = [
      (PhosphorIconsRegular.house, l10n.ongletAccueil),
      (PhosphorIconsRegular.listBullets, l10n.ongletJournal),
      (PhosphorIconsRegular.chartBar, l10n.analyse),
      (PhosphorIconsRegular.slidersHorizontal, l10n.reglages),
    ];

    Widget item(int i) => Expanded(
      child: _ItemOnglet(
        key: cles[i],
        icone: items[i].$1,
        libelle: items[i].$2,
        actif: onglet == i,
        onTap: () => onOnglet(i),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.bg,
        border: Border(top: BorderSide(color: t.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: SizedBox(
            height: 46,
            child: Row(
              children: [
                item(0),
                item(1),
                Expanded(
                  child: Center(
                    child: _BoutonPlus(
                      key: clePlus,
                      ouvert: sheetOuvert,
                      semantique: l10n.boutonAjouterSemantique,
                      onTap: onPlus,
                      onLongPress: onPlusLong,
                    ),
                  ),
                ),
                item(2),
                item(3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemOnglet extends StatelessWidget {
  const _ItemOnglet({
    super.key,
    required this.icone,
    required this.libelle,
    required this.actif,
    required this.onTap,
  });

  final IconData icone;
  final String libelle;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final couleur = actif ? t.ink : t.muted;
    return Semantics(
      button: true,
      selected: actif,
      label: libelle,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: actif ? 1.06 : 1,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(icone, size: 22, color: couleur),
            ),
            const SizedBox(height: 3),
            Text(
              libelle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.1),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: couleur,
                fontWeight: actif ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Le + central : se compresse sous le doigt, pivote en × pendant que le
/// sheet est ouvert ; appui long = dépense directe.
class _BoutonPlus extends StatefulWidget {
  const _BoutonPlus({
    super.key,
    required this.ouvert,
    required this.semantique,
    required this.onTap,
    required this.onLongPress,
  });

  final bool ouvert;
  final String semantique;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  State<_BoutonPlus> createState() => _BoutonPlusState();
}

class _BoutonPlusState extends State<_BoutonPlus> {
  bool _enfonce = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      label: widget.semantique,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _enfonce = true),
        onTapCancel: () => setState(() => _enfonce = false),
        onTapUp: (_) => setState(() => _enfonce = false),
        onTap: widget.onTap,
        onLongPress: () {
          setState(() => _enfonce = false);
          widget.onLongPress();
        },
        child: AnimatedScale(
          scale: _enfonce ? 0.92 : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: Container(
            width: 56,
            height: 46,
            decoration: BoxDecoration(color: t.ink, borderRadius: BorderRadius.circular(16)),
            child: AnimatedRotation(
              turns: widget.ouvert ? 0.125 : 0,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              child: Icon(PhosphorIconsBold.plus, size: 22, color: t.onInk),
            ),
          ),
        ),
      ),
    );
  }
}
