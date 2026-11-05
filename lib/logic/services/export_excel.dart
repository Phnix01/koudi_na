import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

import '../../core/utils/formatters.dart';
import '../../data/models/categorie.dart';
import '../../data/models/compte.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';
import 'csv_colonnes.dart';

/// Classeur Excel (.xlsx) des transactions — même colonnes et même
/// contrat d'en-têtes que [genererCsvTransactions], pour quelqu'un qui
/// veut manipuler les chiffres dans un tableur plutôt que lire un
/// rapport. Fonction pure (aucun accès disque) : le fichier à écrire
/// et à partager est délégué à l'appelant, via `partagerFichier`.
Uint8List genererExcelTransactions(
  List<Transaction> transactions,
  Map<String, Categorie> categoriesParId,
  Map<String, Compte> comptesParId, {
  String langue = 'fr',
}) {
  final colonnes = colonnesCsvPour(langue);
  final formatDate = DateFormat('yyyy-MM-dd');

  final classeur = Excel.createExcel();
  final nomFeuille = classeur.sheets.keys.first;
  final feuille = classeur[nomFeuille];

  feuille.appendRow(colonnes.enTetes.map(TextCellValue.new).toList());
  for (var i = 0; i < colonnes.enTetes.length; i++) {
    feuille
        .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        .cellStyle = CellStyle(bold: true);
  }

  for (final t in transactions) {
    feuille.appendRow([
      TextCellValue(formatDate.format(t.date)),
      TextCellValue(
        t.type == TypeMouvement.entree
            ? colonnes.valeurEntree
            : colonnes.valeurDepense,
      ),
      TextCellValue(formaterMontant(t.montant)),
      TextCellValue(categoriesParId[t.categorieId]?.libelle ?? ''),
      TextCellValue(comptesParId[t.compteId]?.libelle ?? ''),
      TextCellValue(t.note ?? ''),
    ]);
  }

  return Uint8List.fromList(classeur.encode()!);
}
