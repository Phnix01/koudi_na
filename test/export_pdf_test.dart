import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:koudi_na/data/models/categorie.dart';
import 'package:koudi_na/data/models/compte.dart';
import 'package:koudi_na/data/models/transaction.dart';
import 'package:koudi_na/data/models/type_mouvement.dart';
import 'package:koudi_na/logic/services/export_pdf.dart';

/// Garde-fou : le PDF charge ses polices et le logo par chemin d'asset.
/// Si l'un d'eux disparaît (changement de police…), ce test casse au
/// lieu de l'export en production.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('génère un PDF avec les polices et le logo embarqués', () async {
    await initializeDateFormatting('fr');
    final categorie = Categorie(id: 'cat-nourriture', libelle: 'Nourriture', type: TypeMouvement.depense, iconeCode: 'bowlFood', couleurHex: '#B45309');
    final compte = Compte(id: 'compte-especes', libelle: 'Espèces', type: TypeCompte.especes, iconeCode: 'coins', couleurHex: '#B45309');
    final octets = await genererPdfTransactions(
      transactions: [
        Transaction(id: 't', date: DateTime(2026, 11, 24), type: TypeMouvement.depense, montant: 2500, categorieId: categorie.id, compteId: compte.id, note: 'Déjeuner'),
      ],
      categoriesParId: {categorie.id: categorie},
      comptesParId: {compte.id: compte},
      langue: 'fr',
      libellePeriode: 'Novembre 2026',
      libelleGenereLe: 'Généré le 24 nov. 2026',
      libelleEntrees: 'Entrées',
      libelleDepenses: 'Dépenses',
      libelleSolde: 'Solde',
    );
    expect(octets.length, greaterThan(1000));
    expect(ascii.decode(octets.sublist(0, 5)), '%PDF-');
  });
}
