import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koudi_na/data/models/transaction.dart';
import 'package:koudi_na/data/models/type_mouvement.dart';
import 'package:koudi_na/logic/services/filtre_periode.dart';

Transaction _t(String id, DateTime date) => Transaction(
  id: id,
  date: date,
  type: TypeMouvement.depense,
  montant: 1000,
  categorieId: 'cat',
  compteId: 'compte',
);

void main() {
  final maintenant = DateTime.now();
  final transactions = [
    _t('mois-courant', DateTime(maintenant.year, maintenant.month, 5)),
    _t('an-dernier', DateTime(maintenant.year - 1, 6, 15)),
    _t('plage-debut', DateTime(2026, 1, 1)),
    _t('plage-milieu', DateTime(2026, 1, 15)),
    _t('plage-fin', DateTime(2026, 1, 31)),
    _t('hors-plage', DateTime(2026, 2, 1)),
  ];

  test('tout renvoie toutes les transactions sans filtrage', () {
    expect(filtrerParPeriode(transactions, PeriodeExport.tout, null), transactions);
  });

  test('mois courant ne garde que le mois en cours', () {
    final resultat = filtrerParPeriode(
      transactions,
      PeriodeExport.moisCourant,
      null,
    );
    expect(resultat.map((t) => t.id), ['mois-courant']);
  });

  test('personnalisée garde les bornes inclusivement', () {
    final plage = DateTimeRange(
      start: DateTime(2026, 1, 1),
      end: DateTime(2026, 1, 31),
    );
    final resultat = filtrerParPeriode(
      transactions,
      PeriodeExport.personnalisee,
      plage,
    );
    expect(resultat.map((t) => t.id), [
      'plage-debut',
      'plage-milieu',
      'plage-fin',
    ]);
  });

  test('personnalisée sans plage choisie ne renvoie rien', () {
    expect(
      filtrerParPeriode(transactions, PeriodeExport.personnalisee, null),
      isEmpty,
    );
  });
}
