import 'package:flutter_test/flutter_test.dart';
import 'package:koudi_na/data/models/categorie.dart';
import 'package:koudi_na/data/models/compte.dart';
import 'package:koudi_na/data/models/transaction.dart';
import 'package:koudi_na/data/models/type_mouvement.dart';
import 'package:koudi_na/logic/services/export_csv.dart';
import 'package:koudi_na/logic/services/import_csv.dart';

/// Le CSV est le seul format d'échange de l'application : un export
/// fait dans une langue doit se réimporter dans l'autre sans perte.
void main() {
  final categories = [
    Categorie(
      id: 'cat-nourriture',
      libelle: 'Nourriture',
      type: TypeMouvement.depense,
      iconeCode: 'bowlFood',
      couleurHex: '#F5A623',
    ),
    Categorie(
      id: 'cat-salaire',
      libelle: 'Salaire',
      type: TypeMouvement.entree,
      iconeCode: 'wallet',
      couleurHex: '#2ECC71',
    ),
  ];
  final comptes = [
    Compte(
      id: 'compte-especes',
      libelle: 'Espèces',
      type: TypeCompte.especes,
      iconeCode: 'coins',
      couleurHex: '#2ECC71',
    ),
  ];
  final transactions = [
    Transaction(
      id: 't1',
      date: DateTime(2026, 10, 3),
      type: TypeMouvement.depense,
      montant: 2500,
      categorieId: 'cat-nourriture',
      compteId: 'compte-especes',
      note: 'Riz, "sauce", tomates',
    ),
    Transaction(
      id: 't2',
      date: DateTime(2026, 10, 1),
      type: TypeMouvement.entree,
      montant: 250000,
      categorieId: 'cat-salaire',
      compteId: 'compte-especes',
    ),
  ];
  final categoriesParId = {for (final c in categories) c.id: c};
  final comptesParId = {for (final c in comptes) c.id: c};

  for (final langue in ['fr', 'en']) {
    test('aller-retour export → import en $langue', () {
      final csv = genererCsvTransactions(
        transactions,
        categoriesParId,
        comptesParId,
        langue: langue,
      );
      final resultat = parserCsvTransactions(csv, categories, comptes);

      expect(resultat.lignesIgnorees, 0);
      expect(resultat.transactions, hasLength(2));

      final depense = resultat.transactions.firstWhere(
        (t) => t.type == TypeMouvement.depense,
      );
      expect(depense.montant, 2500);
      expect(depense.date, DateTime(2026, 10, 3));
      expect(depense.categorieId, 'cat-nourriture');
      expect(depense.compteId, 'compte-especes');
      expect(depense.note, 'Riz, "sauce", tomates');

      final entree = resultat.transactions.firstWhere(
        (t) => t.type == TypeMouvement.entree,
      );
      expect(entree.montant, 250000);
      expect(entree.categorieId, 'cat-salaire');
    });
  }

  test('les en-têtes suivent la langue demandée', () {
    final fr = genererCsvTransactions(const [], {}, {}, langue: 'fr');
    final en = genererCsvTransactions(const [], {}, {}, langue: 'en');
    expect(fr, contains('Catégorie'));
    expect(en, contains('Category'));
    expect(en, isNot(contains('Catégorie')));
  });

  test('une ligne dont la catégorie est inconnue est ignorée', () {
    const csv =
        'Date,Type,Montant (FCFA),Catégorie,Compte,Note\n'
        '2026-10-03,Dépense,1000,Inconnue,Espèces,\n'
        '2026-10-04,Dépense,1000,Nourriture,Espèces,';
    final resultat = parserCsvTransactions(csv, categories, comptes);
    expect(resultat.lignesIgnorees, 1);
    expect(resultat.transactions, hasLength(1));
  });
}
