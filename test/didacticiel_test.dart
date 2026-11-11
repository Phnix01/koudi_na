import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koudi_na/core/theme/app_theme.dart';
import 'package:koudi_na/l10n/app_localizations.dart';
import 'package:koudi_na/ui/widgets/didacticiel.dart';

void main() {
  final cleHaut = GlobalKey();
  final cleBas = GlobalKey();
  final cleAbsente = GlobalKey();

  Future<BuildContext> monter(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(key: cleHaut, height: 40, width: 100),
                const SizedBox(height: 2000),
                SizedBox(key: cleBas, height: 40, width: 100),
              ],
            ),
          ),
        ),
      ),
    );
    return tester.element(find.byType(Scaffold));
  }

  List<EtapeDidacticiel> etapes() => [
    EtapeDidacticiel(cible: cleHaut, titre: 'Haut', texte: 'premier'),
    EtapeDidacticiel(cible: cleBas, titre: 'Bas', texte: 'hors écran'),
    EtapeDidacticiel(cible: cleAbsente, titre: 'Absente', texte: 'jamais'),
  ];

  testWidgets('avance, défile vers la cible et saute celle qui est absente', (
    tester,
  ) async {
    final context = await monter(tester);
    var termine = false;
    lancerDidacticiel(context, etapes()).then((_) => termine = true);
    await tester.pumpAndSettle();

    expect(find.text('Haut'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Bas'), findsOneWidget);
    // La cible du bas a été ramenée dans l'écran par le défilement.
    final bas = tester.getRect(find.byKey(cleBas));
    expect(bas.top, lessThan(600));
    expect(bas.bottom, greaterThan(0));

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Absente'), findsNothing);
    expect(termine, isTrue);
  });

  testWidgets('« Passer » ferme la visite immédiatement', (tester) async {
    final context = await monter(tester);
    var termine = false;
    lancerDidacticiel(context, etapes()).then((_) => termine = true);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();
    expect(find.text('Haut'), findsNothing);
    expect(termine, isTrue);
  });
}
