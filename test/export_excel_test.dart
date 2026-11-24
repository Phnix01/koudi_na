import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koudi_na/data/models/categorie.dart';
import 'package:koudi_na/data/models/compte.dart';
import 'package:koudi_na/data/models/transaction.dart';
import 'package:koudi_na/data/models/type_mouvement.dart';
import 'package:koudi_na/logic/services/export_excel.dart';

String? _texte(Data? cell) =>
    cell?.value == null ? null : (cell!.value as TextCellValue).value.text;

void main() {
  final categories = [
    Categorie(
      id: 'cat-nourriture',
      libelle: 'Nourriture',
      type: TypeMouvement.depense,
      iconeCode: 'bowlFood',
      couleurHex: '#F5A623',
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
      note: 'Riz',
    ),
  ];
  final categoriesParId = {for (final c in categories) c.id: c};
  final comptesParId = {for (final c in comptes) c.id: c};

  test('en-têtes et valeurs en français', () {
    final octets = genererExcelTransactions(
      transactions,
      categoriesParId,
      comptesParId,
      langue: 'fr',
    );
    final classeur = Excel.decodeBytes(octets);
    final feuille = classeur.tables[classeur.sheets.keys.first]!;
    final lignes = feuille.rows;

    expect(lignes, hasLength(2));
    expect(_texte(lignes[0][0]), 'Date');
    expect(_texte(lignes[0][2]), 'Montant');
    expect(_texte(lignes[1][1]), 'Dépense');
    // Nom d'origine du seed : exporté sous son nom actuel, dans la langue
    // de l'export.
    expect(_texte(lignes[1][3]), 'Alimentation');
    expect(_texte(lignes[1][4]), 'Espèces');
  });

  test('en-têtes en anglais', () {
    final octets = genererExcelTransactions(
      transactions,
      categoriesParId,
      comptesParId,
      langue: 'en',
    );
    final classeur = Excel.decodeBytes(octets);
    final feuille = classeur.tables[classeur.sheets.keys.first]!;
    expect(_texte(feuille.rows[0][2]), 'Amount');
    expect(_texte(feuille.rows[1][1]), 'Expense');
    expect(_texte(feuille.rows[1][3]), 'Food');
    expect(_texte(feuille.rows[1][4]), 'Cash');
  });
}
