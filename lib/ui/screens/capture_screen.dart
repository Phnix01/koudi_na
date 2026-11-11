import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/badges.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../logic/providers/capture_form_provider.dart';
import '../../logic/providers/notifications_provider.dart';
import '../../logic/providers/repositories_providers.dart';
import '../../logic/services/alerte_depassement.dart';
import '../../logic/services/calcul_piliers.dart';
import '../../logic/services/evaluation_badges.dart';
import '../../logic/services/serie_quotidienne.dart';
import '../navigation/route_animee.dart';
import '../../logic/providers/didacticiel_provider.dart';
import '../../logic/providers/langue_provider.dart';
import '../widgets/dialogue_badge_debloque.dart';
import '../widgets/didacticiel.dart';
import '../widgets/formulaire_transaction.dart';
import '../widgets/indicateur_serie.dart';
import '../widgets/solde_du_mois.dart';
import '../../l10n/l10n.dart';
import 'analyse_screen.dart';
import 'mois_screen.dart';
import 'reglages_screen.dart';

/// Écran A du cahier des charges : la capture, cœur de l'application.
/// Parcours cible (section 4) : ouvrir → taper le montant → taper la
/// catégorie → enregistré, trois gestes, moins de 10 secondes.
class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen>
    with WidgetsBindingObserver {
  final _cleMontant = GlobalKey();
  final _cleCategories = GlobalKey();
  final _cleEnregistrer = GlobalKey();
  final _cleSolde = GlobalKey();
  final _cleSerie = GlobalKey();
  final _cleAnalyse = GlobalKey();
  final _cleMois = GlobalKey();
  final _cleReglages = GlobalKey();
  bool _didacticielEnCours = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verifierDepassements();
      if (!ref.read(reglagesRepositoryProvider).didacticielVu) {
        _lancerDidacticiel();
      }
    });
  }

  Future<void> _lancerDidacticiel() async {
    if (_didacticielEnCours) return;
    _didacticielEnCours = true;
    try {
      // Laisse finir la transition qui amène ici (fin de l'onboarding,
      // retour depuis Réglages) : les cibles doivent être à leur place.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      final l10n = context.l10n;
      await lancerDidacticiel(context, [
        EtapeDidacticiel(
          cible: _cleMontant,
          titre: l10n.didacticielMontantTitre,
          texte: l10n.didacticielMontantTexte,
        ),
        EtapeDidacticiel(
          cible: _cleCategories,
          titre: l10n.didacticielCategorieTitre,
          texte: l10n.didacticielCategorieTexte,
        ),
        EtapeDidacticiel(
          cible: _cleEnregistrer,
          titre: l10n.didacticielEnregistrerTitre,
          texte: l10n.didacticielEnregistrerTexte,
        ),
        EtapeDidacticiel(
          cible: _cleSolde,
          titre: l10n.didacticielSoldeTitre,
          texte: l10n.didacticielSoldeTexte,
        ),
        EtapeDidacticiel(
          cible: _cleSerie,
          titre: l10n.didacticielSerieTitre,
          texte: l10n.didacticielSerieTexte,
          ronde: true,
        ),
        EtapeDidacticiel(
          cible: _cleAnalyse,
          titre: l10n.didacticielAnalyseTitre,
          texte: l10n.didacticielAnalyseTexte,
          ronde: true,
        ),
        EtapeDidacticiel(
          cible: _cleMois,
          titre: l10n.didacticielMoisTitre,
          texte: l10n.didacticielMoisTexte,
          ronde: true,
        ),
        EtapeDidacticiel(
          cible: _cleReglages,
          titre: l10n.didacticielReglagesTitre,
          texte: l10n.didacticielReglagesTexte,
          ronde: true,
        ),
      ]);
      await ref.read(reglagesRepositoryProvider).marquerDidacticielVu();
      // La visite a fait défiler le formulaire : on le remet en haut.
      final position = _cleMontant.currentContext == null
          ? null
          : Scrollable.maybeOf(_cleMontant.currentContext!)?.position;
      await position?.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } finally {
      _didacticielEnCours = false;
    }
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

  /// Vérifie, chaque fois que l'app repasse au premier plan, si un
  /// pilier dépasse sa cible du mois et ne l'a pas encore signalé —
  /// pas de calcul en arrière-plan, juste un contrôle en direct à
  /// chaque reprise (voir le plan : aucune exécution hors ligne n'est
  /// possible sans backend).
  Future<void> _verifierDepassements() async {
    final transactions = ref.read(transactionRepositoryProvider).tous();
    final categories = ref.read(categorieRepositoryProvider).tous();
    final gamification = ref.read(gamificationRepositoryProvider);
    final maintenant = DateTime.now();

    final progressions = calculerProgressionPiliers(
      transactions,
      categories,
      maintenant: maintenant,
    );
    final enDepassement = piliersEnDepassementNonAlertes(
      progressions,
      (pilier) => gamification.dejaAlertePourCeMois(pilier, maintenant),
    );
    if (enDepassement.isEmpty) return;

    if (!mounted) return;
    final l10n = context.l10n;
    final notifications = ref.read(notificationsServiceProvider);
    for (final pilier in enDepassement) {
      await gamification.marquerAlertePourCeMois(pilier, maintenant);
      await notifications.afficherAlerteDepassement(
        pilier,
        titre: l10n.notificationDepassementNotifTitre,
        corps: l10n.notificationDepassementNotifCorps(
          l10n.libellePilier(pilier),
        ),
      );
    }
  }

  Future<void> _enregistrer(BuildContext context, WidgetRef ref) async {
    final form = ref.read(captureFormProvider);
    final transaction = Transaction(
      id: const Uuid().v4(),
      date: form.date,
      type: form.type,
      montant: form.montant,
      categorieId: form.categorieId!,
      compteId: form.compteId,
      note: form.note.isEmpty ? null : form.note,
    );
    final transactionRepo = ref.read(transactionRepositoryProvider);
    await transactionRepo.enregistrer(transaction);
    // Le retour haptique remplace un dialogue de confirmation (section 3.3) :
    // aucune étape supplémentaire ne doit retarder la saisie suivante.
    HapticFeedback.lightImpact();
    ref.read(captureFormProvider.notifier).reinitialiserApresEnregistrement();

    if (!context.mounted) return;
    await _mettreAJourSerieEtBadges(context, ref, transactionRepo);
  }

  /// Une saisie active est le seul événement qui compte pour la série
  /// et les badges — jamais une transaction générée automatiquement
  /// par une récurrence (voir `hive_init.dart`).
  Future<void> _mettreAJourSerieEtBadges(
    BuildContext context,
    WidgetRef ref,
    TransactionRepository transactionRepo,
  ) async {
    final gamification = ref.read(gamificationRepositoryProvider);
    final categories = ref.read(categorieRepositoryProvider).tous();
    final maintenant = DateTime.now();

    final nouvelleSerie = calculerNouvelleSerie(
      gamification.derniereActivite,
      maintenant,
      gamification.serieCourante,
    );
    await gamification.enregistrerActivite(maintenant, nouvelleSerie);

    final transactions = transactionRepo.tous();
    final progressions = calculerProgressionPiliers(
      transactions,
      categories,
      maintenant: maintenant,
    );
    final contexte = (
      serieCourante: nouvelleSerie,
      totalTransactions: transactions.length,
      progressionMoisCourant: progressions,
    );
    final nouveauxBadges = evaluerBadges(
      contexte,
      gamification.badgesDebloques,
    );
    if (nouveauxBadges.isEmpty) return;
    await gamification.debloquerBadges(nouveauxBadges);

    if (!context.mounted) return;
    final langue = Localizations.localeOf(context).languageCode;
    final badge = badgesDisponibles.firstWhere(
      (b) => b.id == nouveauxBadges.first,
    );
    await afficherDeblocageBadge(context, badge, langue);
  }

  @override
  Widget build(BuildContext context) {
    final montant = ref.watch(
      captureFormProvider.select((form) => form.montant),
    );
    final categorieId = ref.watch(
      captureFormProvider.select((form) => form.categorieId),
    );
    final peutEnregistrer = montant > 0 && categorieId != null;
    final l10n = context.l10n;
    ref.listen(demandeDidacticielProvider, (_, _) => _lancerDidacticiel());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  // Même largeur que les trois IconButton à droite : le
                  // solde reste centré, la série occupe ce coin gauche.
                  SizedBox(
                    width: 144,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: IndicateurSerie(key: _cleSerie),
                      ),
                    ),
                  ),
                  Expanded(child: Center(child: SoldeDuMois(key: _cleSolde))),
                  IconButton(
                    key: _cleAnalyse,
                    tooltip: l10n.tooltipAnalyse,
                    icon: const PhosphorIcon(PhosphorIconsFill.chartLineUp),
                    onPressed: () => Navigator.of(
                      context,
                    ).push(routeAnimee(const AnalyseScreen())),
                  ),
                  IconButton(
                    key: _cleMois,
                    tooltip: l10n.tooltipVoirLeMois,
                    icon: const PhosphorIcon(PhosphorIconsFill.listBullets),
                    onPressed: () => Navigator.of(
                      context,
                    ).push(routeAnimee(const MoisScreen())),
                  ),
                  IconButton(
                    key: _cleReglages,
                    tooltip: l10n.tooltipReglages,
                    icon: const PhosphorIcon(PhosphorIconsFill.gearSix),
                    onPressed: () => Navigator.of(
                      context,
                    ).push(routeAnimee(const ReglagesScreen())),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FormulaireTransaction(
                cleMontant: _cleMontant,
                cleCategories: _cleCategories,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                key: _cleEnregistrer,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: peutEnregistrer
                      ? () => _enregistrer(context, ref)
                      : null,
                  child: Text(l10n.enregistrer),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
