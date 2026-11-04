import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koudi_na/core/theme/app_theme.dart';
import 'package:koudi_na/ui/widgets/segmented_toggle.dart';

enum _Pilier { epargne, famille, vie }

Future<void> _pump(
  WidgetTester tester,
  Widget enfant, {
  Size taille = const Size(390, 200),
}) async {
  await tester.binding.setSurfaceSize(taille);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: RepaintBoundary(child: Center(child: enfant))),
    ),
  );
}

void main() {
  testWidgets('BasculeLangue : SegmentedToggle dans une Row avec Spacer', (
    tester,
  ) async {
    await _pump(
      tester,
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 112,
              child: SegmentedToggle<String>(
                options: const [
                  SegmentedToggleOption(valeur: 'fr', label: 'FR'),
                  SegmentedToggleOption(valeur: 'en', label: 'EN'),
                ],
                selectionne: 'fr',
                onChanged: (_) {},
              ),
            ),
            const Spacer(),
            TextButton(onPressed: () {}, child: const Text('Passer')),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('_tmp_bascule_langue.png'),
    );
  });

  testWidgets('Sélecteur de pilier : SegmentedToggle pleine largeur, 3 options', (
    tester,
  ) async {
    await _pump(
      tester,
      SizedBox(
        width: double.infinity,
        child: SegmentedToggle<_Pilier>(
          options: const [
            SegmentedToggleOption(valeur: _Pilier.epargne, label: 'Épargne'),
            SegmentedToggleOption(valeur: _Pilier.famille, label: 'Famille'),
            SegmentedToggleOption(valeur: _Pilier.vie, label: 'Vie'),
          ],
          selectionne: _Pilier.vie,
          onChanged: (_) {},
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('_tmp_pilier.png'),
    );
  });

  testWidgets('Carte avec liseré + FAB rose', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 300));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Carte de test'),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('_tmp_carte_fab.png'),
    );
  });
}
