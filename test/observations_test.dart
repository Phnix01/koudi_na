import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:koudi_na/data/models/categorie.dart';
import 'package:koudi_na/data/models/compte.dart';
import 'package:koudi_na/data/models/pilier.dart';
import 'package:koudi_na/data/models/transaction.dart';
import 'package:koudi_na/data/models/type_mouvement.dart';
import 'package:koudi_na/l10n/app_localizations_en.dart';
import 'package:koudi_na/l10n/app_localizations_fr.dart';
import 'package:koudi_na/logic/services/observations_automatiques.dart';

/// Les observations automatiques sont les seules phrases complètes
/// produites par la couche logique : on vérifie qu'elles sortent bien
/// dans la langue demandée, avec les mêmes données.
void main() {
  final categories = [
    Categorie(
      id: 'cat-epargne',
      libelle: 'Épargne',
      type: TypeMouvement.depense,
      iconeCode: 'piggyBank',
      couleurHex: '#00C2A8',
      pilier: Pilier.epargne,
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
      id: 'compte-epargne',
      libelle: 'Épargne',
      type: TypeCompte.epargne,
      iconeCode: 'vault',
      couleurHex: '#00C2A8',
      soldeInitial: 300000,
    ),
  ];
  final maintenant = DateTime(2026, 10, 15);
  // Trois mois de suite : 100 000 d'entrées, 40 000 épargnés (= la
  // cible de 40 %), pour déclencher l'observation « objectif respecté ».
  final transactions = [
    for (var i = 0; i < 3; i++) ...[
      Transaction(
        id: 'e$i',
        date: DateTime(2026, 10 - i, 1),
        type: TypeMouvement.entree,
        montant: 100000,
        categorieId: 'cat-salaire',
        compteId: 'compte-epargne',
      ),
      Transaction(
        id: 'd$i',
        date: DateTime(2026, 10 - i, 2),
        type: TypeMouvement.depense,
        montant: 40000,
        categorieId: 'cat-epargne',
        compteId: 'compte-epargne',
      ),
    ],
  ];

  test('observations en français', () {
    Intl.defaultLocale = 'fr';
    final observations = genererObservations(
      transactions,
      categories,
      comptes,
      AppLocalizationsFr(),
      maintenant: maintenant,
    );
    expect(
      observations,
      contains("Tu as respecté ton objectif d'épargne 3 mois de suite."),
    );
    expect(
      observations.any((o) => o.startsWith('Ton épargne couvre désormais')),
      isTrue,
    );
  });

  test('observations en anglais', () {
    Intl.defaultLocale = 'en';
    final observations = genererObservations(
      transactions,
      categories,
      comptes,
      AppLocalizationsEn(),
      maintenant: maintenant,
    );
    expect(
      observations,
      contains('You have met your savings goal 3 months in a row.'),
    );
    expect(
      observations.any((o) => o.startsWith('Your savings now cover')),
      isTrue,
    );
  });
}
