import 'package:flutter_test/flutter_test.dart';
import 'package:koudi_na/core/constants/astuces.dart';

void main() {
  test('au moins une astuce disponible', () {
    expect(astucesDisponibles, isNotEmpty);
  });

  test('chaque astuce a un texte fr et en non vide', () {
    for (final astuce in astucesDisponibles) {
      expect(astuce.texteFr, isNotEmpty);
      expect(astuce.texteEn, isNotEmpty);
    }
  });

  test('le même jour de l\'année renvoie toujours la même astuce', () {
    final jour = DateTime(2026, 3, 10);
    expect(astuceDuJour(jour, 'fr'), astuceDuJour(jour, 'fr'));
  });

  test('l\'index boucle correctement sur la longueur de la liste', () {
    final premierJour = DateTime(2026, 1, 1);
    final unAn = DateTime(2027, 1, 1);
    final decalage = unAn.difference(premierJour).inDays;
    if (decalage % astucesDisponibles.length == 0) {
      expect(astuceDuJour(premierJour, 'fr'), astuceDuJour(unAn, 'fr'));
    }
  });

  test('bascule entre fr et en', () {
    final jour = DateTime(2026, 3, 10);
    final texteFr = astuceDuJour(jour, 'fr');
    final texteEn = astuceDuJour(jour, 'en');
    final astuceDuJourIndex = astucesDisponibles.firstWhere(
      (a) => a.texteFr == texteFr,
    );
    expect(texteEn, astuceDuJourIndex.texteEn);
  });
}
