import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:koudi_na/core/constants/hive_boxes.dart';
import 'package:koudi_na/core/theme/app_theme.dart';
import 'package:koudi_na/data/hive_init.dart';
import 'package:koudi_na/data/models/transaction.dart';
import 'package:koudi_na/data/models/type_mouvement.dart';
import 'package:koudi_na/data/repositories/reglages_repository.dart';
import 'package:koudi_na/data/repositories/transaction_repository.dart';
import 'package:koudi_na/l10n/app_localizations.dart';
import 'package:koudi_na/logic/providers/navigation_provider.dart';
import 'package:koudi_na/ui/screens/saisie_screen.dart';
import 'package:koudi_na/ui/shell/app_shell.dart';
import 'package:koudi_na/ui/widgets/koudi/numeric_keypad.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _FauxChemins extends PathProviderPlatform with MockPlatformInterfaceMixin {
  @override
  Future<String?> getApplicationDocumentsPath() async => '.dart_tool/_tmp_hive_refonte';
}

Future<void> _police(String famille, String asset) async {
  final loader = FontLoader(famille)..addFont(rootBundle.load(asset));
  await loader.load();
}

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FauxChemins();
  GoogleFonts.config.allowRuntimeFetching = false;
  PackageInfo.setMockInitialValues(appName: 'Koudi Na', packageName: 'k', version: '1.2.0', buildNumber: '3', buildSignature: '');
  await initializeDateFormatting('fr');
  Intl.defaultLocale = 'fr';
  await _police('packages/phosphor_flutter/PhosphorRegular', 'packages/phosphor_flutter/lib/fonts/Phosphor.ttf');
  await _police('packages/phosphor_flutter/PhosphorBold', 'packages/phosphor_flutter/lib/fonts/Phosphor-Bold.ttf');
  await _police('packages/phosphor_flutter/PhosphorFill', 'packages/phosphor_flutter/lib/fonts/Phosphor-Fill.ttf');

  await initialiserHive();
  // initialiserHive applique la locale du système de test (anglais).
  Intl.defaultLocale = 'fr';
  await ReglagesRepository().marquerDidacticielVu();
  await Hive.box<String>(HiveBoxes.gamification).put('serie_courante', '12');
  final repo = TransactionRepository();
  final now = DateTime.now();
  DateTime j(int jour, [int moisDecale = 0]) => DateTime(now.year, now.month - moisDecale, jour, 12);
  var n = 0;
  Future<void> t(DateTime d, int m, String cat, String compte, {String? note, bool entree = false}) => repo.enregistrer(
    Transaction(
      id: 'demo${n++}',
      date: d,
      type: entree ? TypeMouvement.entree : TypeMouvement.depense,
      montant: m,
      categorieId: cat,
      compteId: compte,
      note: note,
    ),
  );
  await t(j(1), 350000, 'cat-salaire', 'compte-banque', entree: true, note: 'Salaire');
  await t(j(1), 100000, 'cat-epargne', 'compte-epargne', note: 'Virement au coffre');
  await t(j(20), 50000, 'cat-soutien-familial', 'compte-banque', note: 'Envoi à la famille');
  await t(j(20), 2000, 'cat-sadaqa-deen', 'compte-especes', note: 'Sadaqa du vendredi');
  await t(now.subtract(const Duration(days: 1)), 5000, 'cat-data-telecom', 'compte-mobile-money', note: 'Forfait internet');
  await t(now.subtract(const Duration(days: 1)), 6500, 'cat-nourriture', 'compte-especes', note: 'Courses du marché');
  await t(now, 1000, 'cat-transport', 'compte-especes', note: 'Taxi');
  await t(now, 2500, 'cat-nourriture', 'compte-especes', note: 'Déjeuner');
  for (final (m, dep) in [(5, 210000), (4, 245000), (3, 198000), (2, 232000), (1, 221000)]) {
    await t(j(1, m), 350000, 'cat-salaire', 'compte-banque', entree: true);
    await t(j(10, m), dep ~/ 2, 'cat-nourriture', 'compte-especes');
    await t(j(18, m), dep - dep ~/ 2, 'cat-soutien-familial', 'compte-banque');
  }

  Widget app(Widget home, {List<Override> overrides = const []}) => ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.clair,
      debugShowCheckedModeBanner: false,
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );

  Future<void> taille(WidgetTester tester, Size logique) async {
    tester.view.physicalSize = logique * 3;
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
    tester.view.viewPadding = const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
  }

  Future<void> stabiliser(WidgetTester tester) async {
    await tester.runAsync(() => GoogleFonts.pendingFonts());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  for (final (nom, onglet) in [('accueil', 0), ('journal', 1), ('analyse', 2), ('reglages', 3)]) {
    testWidgets('onglet $nom', (tester) async {
      await taille(tester, const Size(390, 844));
      await tester.pumpWidget(app(const AppShell(), overrides: [ongletProvider.overrideWith((ref) => onglet)]));
      await stabiliser(tester);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('_tmp_d_$nom.png'));
    });
  }

  testWidgets('sheet nouvelle opération', (tester) async {
    await taille(tester, const Size(390, 844));
    await tester.pumpWidget(app(const AppShell()));
    await stabiliser(tester);
    await tester.tap(find.bySemanticsLabel('Ajouter une dépense ou une entrée'));
    await stabiliser(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('_tmp_d_sheet.png'));
  });

  for (final (nom, sz) in [('17pro', const Size(390, 844)), ('se', const Size(375, 667))]) {
    testWidgets('saisie $nom', (tester) async {
      await taille(tester, sz);
      if (nom == 'se') {
        tester.view.padding = const FakeViewPadding(top: 20 * 3);
        tester.view.viewPadding = const FakeViewPadding(top: 20 * 3);
      }
      await tester.pumpWidget(app(const SaisieScreen.nouvelle(type: TypeMouvement.depense)));
      await stabiliser(tester);
      for (final c in ['2', '5', '0', '0']) {
        await tester.tap(find.descendant(of: find.byType(NumericKeypad), matching: find.bySemanticsLabel(c)));
        await tester.pump();
      }
      await stabiliser(tester);
      expect(tester.takeException(), isNull);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('_tmp_d_saisie_$nom.png'));
    });
  }
}
