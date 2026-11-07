import 'package:flutter_test/flutter_test.dart';
import 'package:koudi_na/logic/services/serie_quotidienne.dart';

void main() {
  test('pas de dernière activité : démarre une série à 1', () {
    expect(calculerNouvelleSerie(null, DateTime(2026, 3, 10), 0), 1);
  });

  test('même jour calendaire : série inchangée', () {
    final aujourdHui = DateTime(2026, 3, 10, 18);
    final derniereActivite = DateTime(2026, 3, 10, 8);
    expect(calculerNouvelleSerie(derniereActivite, aujourdHui, 4), 4);
  });

  test('même jour calendaire, série encore à 0 : démarre à 1', () {
    expect(
      calculerNouvelleSerie(DateTime(2026, 3, 10), DateTime(2026, 3, 10), 0),
      1,
    );
  });

  test('exactement un jour d\'écart : la série continue', () {
    expect(
      calculerNouvelleSerie(DateTime(2026, 3, 9), DateTime(2026, 3, 10), 4),
      5,
    );
  });

  test('transition 31 décembre → 1er janvier : comptée comme 1 jour', () {
    expect(
      calculerNouvelleSerie(
        DateTime(2025, 12, 31),
        DateTime(2026, 1, 1),
        10,
      ),
      11,
    );
  });

  test('plus d\'un jour d\'écart : la série repart à 1', () {
    expect(
      calculerNouvelleSerie(DateTime(2026, 3, 1), DateTime(2026, 3, 10), 20),
      1,
    );
  });
}
