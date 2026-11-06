import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:koudi_na/data/models/categorie.dart';
import 'package:koudi_na/data/models/compte.dart';
import 'package:koudi_na/data/models/transaction.dart';
import 'package:koudi_na/data/models/type_mouvement.dart';
import 'package:koudi_na/logic/services/export_pdf.dart';

void main() {
  testWidgets('aperçu visuel jetable du rapport PDF', (tester) async {
    await initializeDateFormatting('fr');
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
        date: DateTime(2026, 11, 3),
        type: TypeMouvement.depense,
        montant: 2500,
        categorieId: 'cat-nourriture',
        compteId: 'compte-especes',
        note: 'Riz, sauce, tomates',
      ),
      Transaction(
        id: 't2',
        date: DateTime(2026, 11, 1),
        type: TypeMouvement.entree,
        montant: 250000,
        categorieId: 'cat-salaire',
        compteId: 'compte-especes',
      ),
      Transaction(
        id: 't3',
        date: DateTime(2026, 11, 5),
        type: TypeMouvement.depense,
        montant: 15000,
        categorieId: 'cat-nourriture',
        compteId: 'compte-especes',
      ),
    ];
    final categoriesParId = {for (final c in categories) c.id: c};
    final comptesParId = {for (final c in comptes) c.id: c};

    final octets = await genererPdfTransactions(
      transactions: transactions,
      categoriesParId: categoriesParId,
      comptesParId: comptesParId,
      langue: 'fr',
      libellePeriode: 'Novembre 2026',
      libelleGenereLe: 'Généré le 15/11/2026 10:00',
      libelleEntrees: 'Entrées',
      libelleDepenses: 'Dépenses',
      libelleSolde: 'Solde',
    );

    final fichier = File('/tmp/koudi_na_apercu_rapport.pdf');
    await fichier.writeAsBytes(octets);
    expect(fichier.existsSync(), isTrue);
  });
}
