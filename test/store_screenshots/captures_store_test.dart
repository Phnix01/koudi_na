// Captures App Store iPhone 6,9 pouces (1320×2868), rendues à partir du
// vrai code de l'app avec des données de démonstration.
//
// Ce n'est pas un test de non-régression : il ne tourne que sur demande.
//   tool/store/../ → voir test/store_screenshots/generer.sh
@Tags(['captures'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:koudi_na/core/constants/devises.dart';
import 'package:koudi_na/core/constants/hive_boxes.dart';
import 'package:koudi_na/core/theme/app_theme.dart';
import 'package:koudi_na/core/utils/formatters.dart';
import 'package:koudi_na/data/hive_init.dart';
import 'package:koudi_na/data/models/transaction.dart';
import 'package:koudi_na/data/models/type_mouvement.dart';
import 'package:koudi_na/data/repositories/reglages_repository.dart';
import 'package:koudi_na/data/repositories/transaction_repository.dart';
import 'package:koudi_na/l10n/app_localizations.dart';
import 'package:koudi_na/logic/providers/navigation_provider.dart';
import 'package:koudi_na/ui/screens/badges_screen.dart';
import 'package:koudi_na/ui/screens/saisie_screen.dart';
import 'package:koudi_na/ui/shell/app_shell.dart';
import 'package:koudi_na/ui/widgets/koudi/numeric_keypad.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// `fr` (FCFA, Niamey) ou `en` (USD), choisi par generer.sh.
const langue = String.fromEnvironment('LANGUE_CAPTURES', defaultValue: 'fr');
const sortie = String.fromEnvironment('SORTIE_CAPTURES', defaultValue: 'build/captures_store');
final fr = langue == 'fr';

const fond = Color(0xFFF5F5F2);
const encre = Color(0xFF111113);
const accent = Color(0xFF0E7A4F);

// Toile finale : 440×956 points × 3 = 1320×2868 pixels.
const toile = Size(440, 956);
const ecran = Size(390, 844);
const bord = 9.0;
const largeurTelephone = 340.0;
const echelle = (largeurTelephone - 2 * bord) / 390;

class _FauxChemins extends PathProviderPlatform with MockPlatformInterfaceMixin {
  @override
  Future<String?> getApplicationDocumentsPath() async => '.dart_tool/_hive_captures_$langue';
}

Future<void> _police(String famille, String asset) async {
  final loader = FontLoader(famille)..addFont(rootBundle.load(asset));
  await loader.load();
}

class Capture {
  const Capture(this.nom, this.titre, this.sousTitre, this.ecran, {this.onglet, this.preparer});
  final String nom;
  final String titre;
  final String sousTitre;
  final Widget Function() ecran;
  final int? onglet;
  final Future<void> Function(WidgetTester tester)? preparer;
}

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final dossierHive = Directory('.dart_tool/_hive_captures_$langue');
  if (dossierHive.existsSync()) dossierHive.deleteSync(recursive: true);
  PathProviderPlatform.instance = _FauxChemins();
  GoogleFonts.config.allowRuntimeFetching = false;
  PackageInfo.setMockInitialValues(appName: 'Koudi Na', packageName: 'k', version: '1.2.0', buildNumber: '3', buildSignature: '');
  await initializeDateFormatting(langue);
  await _police('packages/phosphor_flutter/PhosphorRegular', 'packages/phosphor_flutter/lib/fonts/Phosphor.ttf');
  await _police('packages/phosphor_flutter/PhosphorBold', 'packages/phosphor_flutter/lib/fonts/Phosphor-Bold.ttf');
  await _police('packages/phosphor_flutter/PhosphorFill', 'packages/phosphor_flutter/lib/fonts/Phosphor-Fill.ttf');

  await initialiserHive();
  final reglages = ReglagesRepository();
  await reglages.enregistrerLangue(langue);
  await reglages.enregistrerDevise(fr ? 'XOF' : 'USD');
  appliquerDeviseGlobale(deviseDepuisCode(fr ? 'XOF' : 'USD'));
  Intl.defaultLocale = langue;
  await reglages.marquerDidacticielVu();
  await Hive.box<String>(HiveBoxes.gamification).putAll({
    'serie_courante': '34',
    'serie_record': '34',
    'derniere_activite': DateTime.now().toIso8601String(),
    'badges_debloques': 'premiere_transaction,serie_3,serie_7,serie_30,transactions_50,mois_equilibre',
  });
  await _donneesDemo();

  final capturesFr = <Capture>[
    Capture('01_accueil', 'La règle 40/25/35\ncadre ton mois', 'Épargne · Famille · Vie', () => const AppShell(), onglet: 0),
    Capture('02_saisie', 'Note une dépense\nen quelques secondes', 'Montant, catégorie, compte. C’est noté.',
        () => const SaisieScreen.nouvelle(type: TypeMouvement.depense),
        preparer: (t) => _taper(t, '2500')),
    Capture('03_journal', 'Cash, banque,\nmobile money', 'Tous tes comptes au même endroit', () => const AppShell(), onglet: 1),
    Capture('04_analyse', 'Vois où part\nton argent', 'Semaine par semaine, catégorie par catégorie', () => const AppShell(), onglet: 2),
    Capture('05_ajout', 'Dépense ou entrée :\nun seul geste', 'Appui long sur + : dépense directe', () => const AppShell(),
        onglet: 0, preparer: (t) => _ouvrirPlus(t, 'Ajouter une dépense ou une entrée')),
    Capture('06_serie', 'Garde le rythme,\ngagne des médailles', '100 % hors ligne · sans inscription · sans pub',
        () => const BadgesScreen()),
  ];
  final capturesEn = <Capture>[
    Capture('01_home', 'The 40/25/35 rule\nshapes your month', 'Savings · Family · Living', () => const AppShell(), onglet: 0),
    Capture('02_entry', 'Log an expense\nin seconds', 'Amount, category, account. Done.',
        () => const SaisieScreen.nouvelle(type: TypeMouvement.depense),
        preparer: (t) => _taper(t, '14')),
    Capture('03_journal', 'Cash, bank,\nmobile money', 'Every account in one place', () => const AppShell(), onglet: 1),
    Capture('04_insights', 'See where your\nmoney goes', 'Week by week, category by category', () => const AppShell(), onglet: 2),
    Capture('05_add', 'Expense or income:\none tap away', 'Long-press + to log an expense', () => const AppShell(),
        onglet: 0, preparer: (t) => _ouvrirPlus(t, 'Add an expense or income')),
    Capture('06_streak', 'Keep your streak,\nearn medals', '100% offline · no sign-up · no ads', () => const BadgesScreen()),
  ];

  for (final c in fr ? capturesFr : capturesEn) {
    testWidgets(c.nom, (tester) async {
      tester.view.physicalSize = toile * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final cle = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(key: cle, child: _Composition(capture: c)));
      await _stabiliser(tester);
      await c.preparer?.call(tester);
      await _stabiliser(tester);
      expect(tester.takeException(), isNull);
      await _enregistrer(tester, cle, '$sortie/$langue/${c.nom}.rgba');
    });
  }
}

Future<void> _stabiliser(WidgetTester tester) async {
  await tester.runAsync(() => GoogleFonts.pendingFonts());
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

Future<void> _taper(WidgetTester tester, String chiffres) async {
  for (final c in chiffres.split('')) {
    await tester.tap(find.descendant(of: find.byType(NumericKeypad), matching: find.bySemanticsLabel(c)));
    await tester.pump();
  }
}

Future<void> _ouvrirPlus(WidgetTester tester, String semantique) async {
  await tester.tap(find.bySemanticsLabel(semantique));
}

/// Pixels bruts RGBA : generer.sh les écrit en PNG RGB (sans alpha).
Future<void> _enregistrer(WidgetTester tester, GlobalKey cle, String chemin) async {
  final boundary = cle.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 3);
    final octets = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final fichier = File(chemin)..createSync(recursive: true);
    fichier.writeAsBytesSync(octets!.buffer.asUint8List());
    File('$chemin.taille').writeAsStringSync('${image.width}x${image.height}');
  });
}

class _Composition extends StatelessWidget {
  const _Composition({required this.capture});
  final Capture capture;

  @override
  Widget build(BuildContext context) {
    final rayonEcran = 47.0;
    final hauteurEcran = ecran.height * echelle;
    final largeurEcran = ecran.width * echelle;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: fond,
        child: SizedBox.fromSize(
          size: toile,
          child: Stack(
            children: [
              Positioned(
                left: 24,
                right: 24,
                top: 58,
                child: Column(
                  children: [
                    Text(
                      capture.titre,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: GoogleFonts.geist(
                        fontSize: 33,
                        height: 1.12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.9,
                        color: encre,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      capture.sousTitre,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: GoogleFonts.geist(
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: (toile.width - largeurTelephone) / 2,
                bottom: 26,
                child: Container(
                  padding: const EdgeInsets.all(bord),
                  decoration: BoxDecoration(
                    color: encre,
                    borderRadius: BorderRadius.circular(rayonEcran + bord),
                    boxShadow: const [
                      BoxShadow(color: Color(0x1F111113), blurRadius: 40, offset: Offset(0, 18)),
                      BoxShadow(color: Color(0x0F111113), blurRadius: 8, offset: Offset(0, 2)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(rayonEcran),
                    child: SizedBox(
                      width: largeurEcran,
                      height: hauteurEcran,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: SizedBox.fromSize(size: ecran, child: _Telephone(capture: capture)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// L'app elle-même, dans un MediaQuery d'iPhone (390×844, encoche),
/// avec sa propre MaterialApp : les routes poussées sur le navigateur
/// racine (sheet du +) restent dans l'écran du téléphone.
class _Telephone extends StatelessWidget {
  const _Telephone({required this.capture});
  final Capture capture;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).copyWith(
      size: ecran,
      devicePixelRatio: 3,
      padding: const EdgeInsets.only(top: 47, bottom: 34),
      viewPadding: const EdgeInsets.only(top: 47, bottom: 34),
      textScaler: TextScaler.noScaling,
    );
    return MediaQuery(
      data: media,
      child: Stack(
        children: [
          ProviderScope(
            overrides: [if (capture.onglet != null) ongletProvider.overrideWith((ref) => capture.onglet!)],
            child: MaterialApp(
              theme: AppTheme.clair,
              debugShowCheckedModeBanner: false,
              locale: Locale(langue),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: capture.ecran(),
            ),
          ),
          const Positioned(left: 0, right: 0, top: 0, height: 47, child: IgnorePointer(child: _BarreEtat())),
        ],
      ),
    );
  }
}

class _BarreEtat extends StatelessWidget {
  const _BarreEtat();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          width: 130,
          top: 15,
          child: Text(
            '9:41',
            textAlign: TextAlign.center,
            style: GoogleFonts.geist(fontSize: 16.5, fontWeight: FontWeight.w600, color: encre, letterSpacing: -0.2),
          ),
        ),
        // Dynamic Island.
        Positioned(
          top: 11,
          left: (390 - 124) / 2,
          child: Container(
            width: 124,
            height: 36,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(18)),
          ),
        ),
        Positioned(
          right: 0,
          width: 130,
          top: 19,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _Reseau(),
              SizedBox(width: 6),
              _Wifi(),
              SizedBox(width: 6),
              _Batterie(),
            ],
          ),
        ),
      ],
    );
  }
}

class _Reseau extends StatelessWidget {
  const _Reseau();
  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final h in [4.0, 6.5, 9.0, 11.5])
            Container(
              width: 3,
              height: h,
              margin: const EdgeInsets.only(right: 1.5),
              decoration: BoxDecoration(color: encre, borderRadius: BorderRadius.circular(1)),
            ),
        ],
      );
}

class _Wifi extends StatelessWidget {
  const _Wifi();
  @override
  Widget build(BuildContext context) => CustomPaint(size: const Size(16, 12), painter: _WifiPeintre());
}

class _WifiPeintre extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height);
    final pinceau = Paint()..color = encre;
    for (final (r, debut) in [(12.0, 0.0), (8.0, 0.0), (4.0, 0.0)]) {
      final rect = Rect.fromCircle(center: centre, radius: r);
      final chemin = Path()
        ..moveTo(centre.dx, centre.dy)
        ..arcTo(rect, -2.36 + debut, 1.57, false)
        ..close();
      canvas.drawPath(chemin, pinceau);
      canvas.drawPath(
        Path()
          ..moveTo(centre.dx, centre.dy)
          ..arcTo(Rect.fromCircle(center: centre, radius: r - 2.2), -2.36, 1.57, false)
          ..close(),
        Paint()
          ..color = fond
          ..blendMode = BlendMode.src,
      );
      if (r == 4.0) canvas.drawPath(chemin, pinceau);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Batterie extends StatelessWidget {
  const _Batterie();
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 25,
            height: 12,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(color: encre.withValues(alpha: 0.4), width: 1),
              borderRadius: BorderRadius.circular(3.5),
            ),
            child: Container(
              decoration: BoxDecoration(color: encre, borderRadius: BorderRadius.circular(1.5)),
            ),
          ),
          Container(
            width: 1.5,
            height: 4,
            margin: const EdgeInsets.only(left: 1),
            decoration: BoxDecoration(color: encre.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(1)),
          ),
        ],
      );
}

/// Un mois réaliste (le mois courant, jusqu'à aujourd'hui) et cinq mois
/// d'historique. FR : FCFA à Niamey. EN : dollars, montants à l'échelle.
Future<void> _donneesDemo() async {
  final repo = TransactionRepository();
  final now = DateTime.now();
  var n = 0;
  DateTime j(int jour, [int moisDecale = 0, int heure = 12]) {
    final dernier = DateTime(now.year, now.month - moisDecale + 1, 0).day;
    final d = DateTime(now.year, now.month - moisDecale, jour.clamp(1, dernier), heure);
    return moisDecale == 0 && d.isAfter(now) ? now.subtract(const Duration(minutes: 30)) : d;
  }

  // m : montant FCFA ; usd : montant en dollars.
  Future<void> t(DateTime d, int m, int usd, String cat, String compte, String noteFr, String noteEn, {bool entree = false}) =>
      repo.enregistrer(
        Transaction(
          id: 'demo${n++}',
          date: d,
          type: entree ? TypeMouvement.entree : TypeMouvement.depense,
          montant: fr ? m : usd,
          categorieId: cat,
          compteId: compte,
          note: fr ? noteFr : noteEn,
        ),
      );

  // Historique : cinq mois précédents (Analyse 6 mois / année).
  for (final (m, dep) in [(5, 0.86), (4, 0.94), (3, 0.81), (2, 0.97), (1, 0.89)]) {
    await t(j(1, m), 350000, 4200, 'cat-salaire', 'compte-banque', 'Salaire', 'Salary', entree: true);
    await t(j(1, m), 80000, 800, 'cat-epargne', 'compte-epargne', 'Virement au coffre', 'Transfer to vault');
    await t(j(2, m), 85000, 1100, 'cat-loyer-charges', 'compte-banque', 'Loyer', 'Rent');
    await t(j(9, m), (70000 * dep).round(), (520 * dep).round(), 'cat-nourriture', 'compte-especes', 'Courses du mois', 'Groceries');
    await t(j(15, m), (25000 * dep).round(), (180 * dep).round(), 'cat-transport', 'compte-especes', 'Carburant', 'Fuel');
    await t(j(20, m), 40000, 300, 'cat-soutien-familial', 'compte-mobile-money', 'Envoi à maman', 'Sent to mom');
    await t(j(24, m), (20000 * dep).round(), (160 * dep).round(), 'cat-divers', 'compte-especes', 'Divers', 'Misc');
  }

  // Mois courant.
  await t(j(1), 350000, 4200, 'cat-salaire', 'compte-banque', 'Salaire', 'Salary', entree: true);
  await t(j(1), 100000, 800, 'cat-epargne', 'compte-epargne', 'Virement au coffre', 'Transfer to vault');
  await t(j(2), 85000, 1100, 'cat-loyer-charges', 'compte-banque', 'Loyer de novembre', 'Rent');
  await t(j(4), 12500, 95, 'cat-loyer-charges', 'compte-mobile-money', 'Facture NIGELEC', 'Electricity bill');
  await t(j(5), 25000, 200, 'cat-epargne', 'compte-mobile-money', 'Cotisation tontine', 'Savings club');
  await t(j(6), 5000, 30, 'cat-data-telecom', 'compte-mobile-money', 'Forfait internet', 'Phone plan');
  await t(j(8), 32000, 240, 'cat-nourriture', 'compte-especes', 'Courses au marché', 'Groceries');
  await t(j(12), 75000, 650, 'cat-freelance', 'compte-mobile-money', 'Site web client', 'Website project', entree: true);
  await t(j(13), 15000, 120, 'cat-habillement', 'compte-especes', 'Tissu pour la fête', 'New shoes');
  await t(j(14), 2000, 20, 'cat-sadaqa-deen', 'compte-especes', 'Sadaqa du vendredi', 'Charity');
  await t(j(15), 20000, 150, 'cat-don-recu', 'compte-especes', 'Cadeau de tonton', 'Birthday gift', entree: true);
  await t(j(16), 10000, 45, 'cat-transport', 'compte-especes', 'Carburant moto', 'Fuel');
  await t(j(18), 3500, 25, 'cat-sante', 'compte-especes', 'Pharmacie', 'Pharmacy');
  await t(j(20), 40000, 300, 'cat-soutien-familial', 'compte-mobile-money', 'Envoi à maman', 'Sent to mom');
  await t(j(21), 2000, 20, 'cat-sadaqa-deen', 'compte-especes', 'Sadaqa du vendredi', 'Charity');
  await t(j(22), 18500, 135, 'cat-nourriture', 'compte-especes', 'Courses au marché', 'Groceries');
  await t(j(23), 7500, 18, 'cat-formation-livres', 'compte-especes', 'Livre', 'Book');
  await t(j(25), 1500, 6, 'cat-transport', 'compte-especes', 'Taxi', 'Bus fare');
  await t(j(26), 3000, 9, 'cat-divers', 'compte-especes', 'Crédit téléphone', 'Coffee');
  final hier = now.subtract(const Duration(days: 1));
  await t(DateTime(hier.year, hier.month, hier.day, 19), 6500, 48, 'cat-nourriture', 'compte-especes', 'Courses du soir', 'Groceries');
  await t(DateTime(hier.year, hier.month, hier.day, 8), 1000, 12, 'cat-transport', 'compte-especes', 'Taxi', 'Taxi');
  final ce = DateTime(now.year, now.month, now.day);
  await t(ce.add(const Duration(hours: 8)), 500, 4, 'cat-nourriture', 'compte-especes', 'Pain du matin', 'Breakfast');
  await t(ce.add(const Duration(hours: 9)), 1000, 12, 'cat-transport', 'compte-especes', 'Taxi', 'Taxi');
  await t(ce.add(const Duration(hours: 13)), 2500, 14, 'cat-nourriture', 'compte-especes', 'Déjeuner', 'Lunch');
}
