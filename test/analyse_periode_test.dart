import 'package:flutter_test/flutter_test.dart';
import 'package:koudi_na/data/models/categorie.dart';
import 'package:koudi_na/data/models/transaction.dart';
import 'package:koudi_na/data/models/type_mouvement.dart';
import 'package:koudi_na/logic/services/analyse_periode.dart';

var _n = 0;
Transaction _t(DateTime d, int m, String cat, {TypeMouvement type = TypeMouvement.depense}) =>
    Transaction(id: '${_n++}', date: d, type: type, montant: m, categorieId: cat, compteId: 'c');

Categorie _c(String id) =>
    Categorie(id: id, libelle: id, type: TypeMouvement.depense, iconeCode: 'dotsThree', couleurHex: '#5F5F66');

void main() {
  final le24 = DateTime(2026, 11, 24);
  final transactions = [
    _t(DateTime(2026, 11, 1), 350000, 'salaire', type: TypeMouvement.entree),
    _t(DateTime(2026, 11, 2), 100000, 'epargne'),
    _t(DateTime(2026, 11, 20), 50000, 'famille'),
    _t(DateTime(2026, 11, 24), 2500, 'repas'),
    _t(DateTime(2026, 11, 24), 12000, 'repas'),
    _t(DateTime(2026, 10, 10), 30000, 'repas'),
    _t(DateTime(2026, 5, 10), 999, 'repas'),
  ];
  final categories = [_c('epargne'), _c('famille'), _c('repas')];

  test('période Mois : 5 semaines en novembre, la 4e est la courante', () {
    final barres = calculerBarres(transactions, PeriodeAnalyse.mois, maintenant: le24);
    expect(barres.length, 5);
    expect(barres.map((b) => b.depenses).toList(), [100000, 0, 50000, 14500, 0]);
    expect(barres[0].entrees, 350000);
    expect(barres.indexWhere((b) => b.courante), 3);
  });

  test('février non bissextile : 4 semaines', () {
    expect(calculerBarres(const [], PeriodeAnalyse.mois, maintenant: DateTime(2026, 2, 10)).length, 4);
  });

  test('6 mois et année : une barre par mois, la dernière est courante', () {
    final six = calculerBarres(transactions, PeriodeAnalyse.sixMois, maintenant: le24);
    expect(six.length, 6);
    expect(six.last.courante, isTrue);
    expect(six.last.depenses, 164500);
    expect(six[4].depenses, 30000);
    expect(calculerBarres(transactions, PeriodeAnalyse.annee, maintenant: le24).length, 12);
  });

  test('répartition du mois, triée, avec la part de chaque catégorie', () {
    final r = calculerRepartitionPeriode(transactions, categories, PeriodeAnalyse.mois, maintenant: le24);
    expect(r.map((p) => p.categorie.id).toList(), ['epargne', 'famille', 'repas']);
    expect(r.first.part, closeTo(100000 / 164500, 1e-9));
  });

  test('répartition sur 6 mois : inclut octobre, exclut mai', () {
    final r = calculerRepartitionPeriode(transactions, categories, PeriodeAnalyse.sixMois, maintenant: le24);
    final repas = r.firstWhere((p) => p.categorie.id == 'repas');
    expect(repas.montant, 44500);
  });
}
