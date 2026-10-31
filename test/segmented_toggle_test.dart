import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koudi_na/ui/widgets/segmented_toggle.dart';

/// Régression : le `SegmentedButton` Material 3 remplacé par ce widget
/// coupait « Dépense » en « Dépens »/« e » dès qu'une échelle de texte
/// système plus grande était active (bug signalé en production).
void main() {
  testWidgets('aucun retour à la ligne même à grande échelle de texte', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.2)),
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 240,
                child: SegmentedToggle<String>(
                  options: const [
                    SegmentedToggleOption(valeur: 'depense', label: 'Dépense'),
                    SegmentedToggleOption(valeur: 'entree', label: 'Entrée'),
                  ],
                  selectionne: 'depense',
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    for (final texte in ['Dépense', 'Entrée']) {
      final widget = tester.widget<Text>(find.text(texte));
      expect(widget.maxLines, 1);
    }
  });
}
