import 'package:flutter_test/flutter_test.dart';
import 'package:koudi_na/data/models/pilier.dart';
import 'package:koudi_na/logic/services/alerte_depassement.dart';
import 'package:koudi_na/logic/services/calcul_piliers.dart';

ProgressionPilier _p(Pilier pilier, double progression) => (
  pilier: pilier,
  montantReel: 0,
  objectifMontant: 0,
  progression: progression,
);

void main() {
  test('progression > 1.0 et pas encore alerté : déclenche', () {
    final resultat = piliersEnDepassementNonAlertes([
      _p(Pilier.epargne, 1.1),
    ], (_) => false);
    expect(resultat, [Pilier.epargne]);
  });

  test('progression == 1.0 exactement : ne déclenche pas', () {
    final resultat = piliersEnDepassementNonAlertes([
      _p(Pilier.epargne, 1.0),
    ], (_) => false);
    expect(resultat, isEmpty);
  });

  test('déjà alerté ce mois-ci : ne redéclenche pas', () {
    final resultat = piliersEnDepassementNonAlertes([
      _p(Pilier.epargne, 1.5),
    ], (_) => true);
    expect(resultat, isEmpty);
  });

  test('les piliers sont évalués indépendamment', () {
    final resultat = piliersEnDepassementNonAlertes(
      [_p(Pilier.epargne, 1.5), _p(Pilier.famille, 1.2), _p(Pilier.vie, 0.8)],
      (pilier) => pilier == Pilier.epargne,
    );
    expect(resultat, [Pilier.famille]);
  });

  test('aucun pilier en dépassement : liste vide', () {
    final resultat = piliersEnDepassementNonAlertes([
      _p(Pilier.epargne, 0.5),
      _p(Pilier.famille, 0.9),
      _p(Pilier.vie, 1.0),
    ], (_) => false);
    expect(resultat, isEmpty);
  });
}
