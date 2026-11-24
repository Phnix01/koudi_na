import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:koudi_na/data/models/categorie.dart';
import 'package:koudi_na/data/models/compte.dart';
import 'package:koudi_na/data/models/type_mouvement.dart';
import 'package:koudi_na/data/seed/libelles_seed.dart';
import 'package:koudi_na/logic/services/import_csv.dart';

/// Refonte D : les noms d'origine suivent la langue de l'app, un nom
/// choisi par l'utilisateur est conservé, et l'import CSV reconnaît tous
/// les noms qu'un élément du seed a pu porter.
void main() {
  tearDown(() => Intl.defaultLocale = null);

  test('un nom d’origine, même ancien ou anglais, suit la langue de l’app', () {
    Intl.defaultLocale = 'fr';
    expect(libelleAffiche('cat-nourriture', 'Food'), 'Alimentation');
    expect(libelleAffiche('cat-nourriture', 'Nourriture'), 'Alimentation');
    expect(libelleAffiche('compte-epargne', 'Savings'), 'Coffre');
    expect(libelleAffiche('compte-banque', 'Compte bancaire'), 'Banque');
    Intl.defaultLocale = 'en';
    expect(libelleAffiche('cat-nourriture', 'Nourriture'), 'Food');
    expect(libelleAffiche('compte-epargne', 'Épargne'), 'Vault');
  });

  test('nom court pour la grille de saisie', () {
    Intl.defaultLocale = 'fr';
    expect(libelleAffiche('cat-nourriture', 'Nourriture', court: true), 'Repas');
    expect(libelleAffiche('cat-loyer-charges', 'Rent & Utilities', court: true), 'Logement');
  });

  test('un nom choisi par l’utilisateur est conservé tel quel', () {
    Intl.defaultLocale = 'en';
    expect(libelleAffiche('cat-nourriture', 'Marché du soir'), 'Marché du soir');
    expect(libelleAffiche('cat-perso-123', 'Moto'), 'Moto');
  });

  test('import : un export ancien ou dans l’autre langue se réimporte', () {
    final categories = [
      Categorie(id: 'cat-nourriture', libelle: 'Alimentation', type: TypeMouvement.depense, iconeCode: 'bowlFood', couleurHex: '#B45309'),
    ];
    final comptes = [
      Compte(id: 'compte-banque', libelle: 'Banque', type: TypeCompte.banque, iconeCode: 'bank', couleurHex: '#2F5BD3'),
    ];
    const csv = 'Date,Type,Montant,Catégorie,Compte,Note\n'
        '2026-10-03,Dépense,2500,Nourriture,Compte bancaire,\n'
        '2026-10-04,Dépense,1000,Food,Bank account,\n'
        '2026-10-05,Dépense,500,Alimentation,Banque,\n'
        '2026-10-06,Dépense,700,Inconnue,Banque,\n';
    final resultat = parserCsvTransactions(csv, categories, comptes);
    expect(resultat.transactions.length, 3);
    expect(resultat.lignesIgnorees, 1);
    expect(resultat.transactions.every((t) => t.categorieId == 'cat-nourriture' && t.compteId == 'compte-banque'), isTrue);
  });
}
