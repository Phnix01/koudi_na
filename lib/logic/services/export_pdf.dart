import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/utils/formatters.dart';
import '../../data/models/categorie.dart';
import '../../data/models/compte.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';
import 'csv_colonnes.dart';

/// Rapport PDF brandé XNOVA Systems (section Export, Réglages) : logo +
/// période en en-tête, bandeau Entrées/Dépenses/Solde, puis le tableau
/// des transactions avec les mêmes colonnes que le CSV. Comme
/// [genererCsvTransactions], ne connaît pas `BuildContext`/`l10n` —
/// l'appelant passe les libellés déjà résolus.
///
/// Les polices sont chargées depuis `assets/google_fonts/` (déjà
/// embarquées pour l'app elle-même) plutôt que via un service de
/// police en ligne : l'app doit rester utilisable sans réseau, y
/// compris pour générer ce rapport.
Future<Uint8List> genererPdfTransactions({
  required List<Transaction> transactions,
  required Map<String, Categorie> categoriesParId,
  required Map<String, Compte> comptesParId,
  required String langue,
  required String libellePeriode,
  required String libelleGenereLe,
  required String libelleEntrees,
  required String libelleDepenses,
  required String libelleSolde,
}) async {
  final police = await _chargerPolice('assets/google_fonts/Inter-Regular.ttf');
  final policeMoyenne = await _chargerPolice(
    'assets/google_fonts/Inter-Medium.ttf',
  );
  final policeTitre = await _chargerPolice(
    'assets/google_fonts/Sora-Bold.ttf',
  );
  final logo = pw.MemoryImage(
    (await rootBundle.load('assets/icon/app_icon.png')).buffer.asUint8List(),
  );

  final couleurPrimaire = PdfColor.fromInt(0xFF00C2A8);
  final couleurPositif = PdfColor.fromInt(0xFF2ECC71);
  final couleurNegatif = PdfColor.fromInt(0xFFE74C3C);
  final couleurTexteMuet = PdfColor.fromInt(0xFF8A97A6);

  var totalEntrees = 0;
  var totalDepenses = 0;
  for (final t in transactions) {
    if (t.type == TypeMouvement.entree) {
      totalEntrees += t.montant;
    } else {
      totalDepenses += t.montant;
    }
  }
  final solde = totalEntrees - totalDepenses;

  pw.Widget caseResume(String libelle, String valeur, PdfColor couleur) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: couleur, width: 1),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              libelle,
              style: pw.TextStyle(fontSize: 9, color: couleurTexteMuet),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              valeur,
              style: pw.TextStyle(
                font: policeMoyenne,
                fontSize: 13,
                color: couleur,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget entete(pw.Context context) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.ClipRRect(
            horizontalRadius: 6,
            verticalRadius: 6,
            child: pw.Image(logo, width: 28, height: 28),
          ),
          pw.SizedBox(width: 8),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Koudi Na', style: pw.TextStyle(font: policeTitre, fontSize: 15)),
              pw.Text(
                'XNOVA Systems',
                style: pw.TextStyle(fontSize: 8, color: couleurTexteMuet),
              ),
            ],
          ),
          pw.Spacer(),
          pw.Text(
            libellePeriode,
            style: pw.TextStyle(font: policeMoyenne, fontSize: 10),
          ),
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Divider(color: couleurPrimaire, thickness: 1.5),
      pw.SizedBox(height: 10),
    ],
  );

  pw.Widget piedDePage(pw.Context context) => pw.Column(
    children: [
      pw.Divider(color: couleurTexteMuet, thickness: 0.5),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            libelleGenereLe,
            style: pw.TextStyle(fontSize: 8, color: couleurTexteMuet),
          ),
          pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: couleurTexteMuet),
          ),
        ],
      ),
    ],
  );

  final colonnes = colonnesCsvPour(langue);
  final formatDate = DateFormat.yMMMd(langue);
  final table = pw.TableHelper.fromTextArray(
    headers: colonnes.enTetes,
    data: [
      for (final t in transactions)
        [
          formatDate.format(t.date),
          t.type == TypeMouvement.entree
              ? colonnes.valeurEntree
              : colonnes.valeurDepense,
          formaterMontant(t.montant),
          categoriesParId[t.categorieId]?.libelle ?? '',
          comptesParId[t.compteId]?.libelle ?? '',
          t.note ?? '',
        ],
    ],
    headerStyle: pw.TextStyle(
      font: policeMoyenne,
      fontSize: 9,
      color: PdfColors.white,
    ),
    headerDecoration: pw.BoxDecoration(color: couleurPrimaire),
    cellStyle: pw.TextStyle(font: police, fontSize: 9),
    cellAlignments: {2: pw.Alignment.centerRight},
    cellHeight: 22,
  );

  final document = pw.Document(theme: pw.ThemeData.withFont(base: police, bold: policeMoyenne));
  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      header: entete,
      footer: piedDePage,
      build: (context) => [
        pw.Row(
          children: [
            caseResume(libelleEntrees, formaterMontant(totalEntrees), couleurPositif),
            pw.SizedBox(width: 8),
            caseResume(libelleDepenses, formaterMontant(totalDepenses), couleurNegatif),
            pw.SizedBox(width: 8),
            caseResume(
              libelleSolde,
              formaterMontant(solde),
              solde >= 0 ? couleurPositif : couleurNegatif,
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        table,
      ],
    ),
  );

  return document.save();
}

Future<pw.Font> _chargerPolice(String chemin) async {
  final donnees = await rootBundle.load(chemin);
  return pw.Font.ttf(donnees);
}
