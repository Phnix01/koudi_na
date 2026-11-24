import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:koudi_na/core/constants/hive_boxes.dart';
import 'package:koudi_na/core/theme/app_theme.dart';
import 'package:koudi_na/data/models/categorie.dart';
import 'package:koudi_na/data/models/compte.dart';
import 'package:koudi_na/data/models/transaction.dart';
import 'package:koudi_na/data/models/type_mouvement.dart';
import 'package:koudi_na/data/repositories/categorie_repository.dart';
import 'package:koudi_na/data/repositories/compte_repository.dart';
import 'package:koudi_na/data/repositories/transaction_repository.dart';
import 'package:koudi_na/data/seed/seed_initial.dart';
import 'package:koudi_na/hive_registrar.g.dart';
import 'package:koudi_na/l10n/app_localizations.dart';
import 'package:koudi_na/ui/navigation/saisie_navigation.dart';
import 'package:koudi_na/ui/widgets/koudi/numeric_keypad.dart';

/// Parcours clé du brief (§9) : saisir « 2 500, Repas, Espèces » depuis
/// la barre d'onglets, enregistrer réellement, puis annuler.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr');
    Hive.registerAdapters();
  });

  setUp(() async {
    Intl.defaultLocale = 'fr';
    // Boîtes en mémoire : pas d'entrée/sortie disque, que l'horloge
    // simulée des tests de widgets ne ferait jamais avancer.
    final vide = Uint8List(0);
    await Hive.openBox<Transaction>(HiveBoxes.transactions, bytes: vide);
    await Hive.openBox<Categorie>(HiveBoxes.categories, bytes: vide);
    await Hive.openBox<Compte>(HiveBoxes.comptes, bytes: vide);
    await Hive.openBox<String>(HiveBoxes.gamification, bytes: vide);
    await Hive.openBox<String>(HiveBoxes.reglages, bytes: vide);
    await seedSiPremierLancement(comptes: CompteRepository(), categories: CategorieRepository(), langue: 'fr');
  });

  tearDown(() => Hive.close());

  Future<void> monter(WidgetTester tester, TypeMouvement type) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.clair,
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: TextButton(onPressed: () => ouvrirSaisie(context, type), child: const Text('ouvrir')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
  }

  Future<void> taper(WidgetTester tester, String touche) async {
    await tester.tap(find.descendant(of: find.byType(NumericKeypad), matching: find.bySemanticsLabel(touche)));
    await tester.pump();
  }

  testWidgets('2 500, Repas, Espèces : enregistré puis annulé', (tester) async {
    await monter(tester, TypeMouvement.depense);

    expect(find.text('Saisis un montant'), findsOneWidget);
    for (final c in ['2', '5', '0', '0']) {
      await taper(tester, c);
    }
    await tester.tap(find.text('Repas'));
    await tester.tap(find.text('Espèces'));
    await tester.pump();

    await tester.tap(find.text('Enregistrer −2 500 FCFA'));
    await tester.pumpAndSettle();

    final enregistrees = TransactionRepository().tous();
    expect(enregistrees.length, 1);
    final t = enregistrees.single;
    expect((t.montant, t.type, t.categorieId, t.compteId), (2500, TypeMouvement.depense, 'cat-nourriture', 'compte-especes'));

    // Première opération : la carte du badge « Premier pas » passe avant
    // la SnackBar.
    expect(find.text('Premier pas'), findsOneWidget);
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Dépense enregistrée'), findsOneWidget);

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(TransactionRepository().tous(), isEmpty);
  });

  testWidgets('la dernière catégorie et le dernier compte sont présélectionnés', (tester) async {
    await TransactionRepository().enregistrer(
      Transaction(
        id: 'avant',
        date: DateTime.now().subtract(const Duration(hours: 1)),
        type: TypeMouvement.depense,
        montant: 1000,
        categorieId: 'cat-transport',
        compteId: 'compte-mobile-money',
      ),
    );
    await monter(tester, TypeMouvement.depense);
    for (final c in ['1', '000']) {
      await taper(tester, c);
    }
    await tester.tap(find.textContaining('Enregistrer'));
    await tester.pumpAndSettle();

    final derniere = TransactionRepository().tous().firstWhere((t) => t.id != 'avant');
    expect((derniere.montant, derniere.categorieId, derniere.compteId), (1000, 'cat-transport', 'compte-mobile-money'));
  });

  testWidgets('pavé : « 000 » ignoré sur un montant vide, 9 chiffres au plus, ⌫', (tester) async {
    await monter(tester, TypeMouvement.entree);
    await taper(tester, '000');
    expect(find.text('Saisis un montant'), findsOneWidget);
    for (var i = 0; i < 12; i++) {
      await taper(tester, '9');
    }
    expect(find.text('999 999 999'), findsOneWidget);
    await taper(tester, 'Effacer le dernier chiffre');
    expect(find.text('99 999 999'), findsOneWidget);
  });
}
