import 'package:flutter_test/flutter_test.dart';
import 'package:koudi_na/data/models/pilier.dart';
import 'package:koudi_na/logic/services/calcul_piliers.dart';
import 'package:koudi_na/logic/services/evaluation_badges.dart';

ProgressionPilier _p(Pilier pilier, double progression) => (
  pilier: pilier,
  montantReel: 0,
  objectifMontant: 0,
  progression: progression,
);

void main() {
  final piliersRespectes = Pilier.values.map((p) => _p(p, 0.5)).toList();
  // Aucun pilier respecté : neutralise mois_equilibre/epargne_respectee,
  // pour isoler les badges liés à la série/au nombre de transactions.
  final piliersDepasses = Pilier.values.map((p) => _p(p, 1.5)).toList();
  final epargneDepassee = [
    _p(Pilier.epargne, 1.2),
    _p(Pilier.famille, 0.5),
    _p(Pilier.vie, 0.5),
  ];

  test('première transaction débloque premiere_transaction', () {
    final badges = evaluerBadges((
      serieCourante: 1,
      totalTransactions: 1,
      progressionMoisCourant: piliersRespectes,
    ), {});
    expect(badges, contains('premiere_transaction'));
  });

  test('aucune transaction : aucun badge de transaction débloqué', () {
    final badges = evaluerBadges((
      serieCourante: 0,
      totalTransactions: 0,
      progressionMoisCourant: piliersDepasses,
    ), {});
    expect(badges, isEmpty);
  });

  test('série à 7 débloque serie_3 et serie_7 mais pas serie_30', () {
    final badges = evaluerBadges((
      serieCourante: 7,
      totalTransactions: 7,
      progressionMoisCourant: piliersDepasses,
    ), {});
    expect(badges, containsAll(['serie_3', 'serie_7']));
    expect(badges, isNot(contains('serie_30')));
  });

  test('un badge déjà débloqué n\'est jamais redonné', () {
    final badges = evaluerBadges((
      serieCourante: 3,
      totalTransactions: 1,
      progressionMoisCourant: piliersDepasses,
    ), {'premiere_transaction', 'serie_3'});
    expect(badges, isEmpty);
  });

  test('mois_equilibre seulement si les 3 piliers sont respectés', () {
    final respecte = evaluerBadges((
      serieCourante: 0,
      totalTransactions: 0,
      progressionMoisCourant: piliersRespectes,
    ), {});
    expect(respecte, contains('mois_equilibre'));

    final nonRespecte = evaluerBadges((
      serieCourante: 0,
      totalTransactions: 0,
      progressionMoisCourant: epargneDepassee,
    ), {});
    expect(nonRespecte, isNot(contains('mois_equilibre')));
  });

  test('epargne_respectee ne dépend que du pilier épargne', () {
    final badges = evaluerBadges((
      serieCourante: 0,
      totalTransactions: 0,
      progressionMoisCourant: epargneDepassee,
    ), {});
    expect(badges, isNot(contains('epargne_respectee')));
  });

  test('plusieurs seuils atteints simultanément apparaissent tous', () {
    final badges = evaluerBadges((
      serieCourante: 100,
      totalTransactions: 200,
      progressionMoisCourant: piliersRespectes,
    ), {});
    expect(
      badges,
      containsAll([
        'serie_3',
        'serie_7',
        'serie_30',
        'serie_100',
        'transactions_50',
        'transactions_200',
      ]),
    );
  });
}
