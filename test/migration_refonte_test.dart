import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:koudi_na/core/constants/hive_boxes.dart';
import 'package:koudi_na/hive_registrar.g.dart';
import 'package:koudi_na/data/models/categorie.dart';
import 'package:koudi_na/data/models/compte.dart';
import 'package:koudi_na/data/models/type_mouvement.dart';
import 'package:koudi_na/data/repositories/categorie_repository.dart';
import 'package:koudi_na/data/repositories/compte_repository.dart';
import 'package:koudi_na/data/seed/seed_initial.dart';

/// Données d'avant la refonte D : ids et noms intacts, couleurs et icônes
/// d'origine remplacées, personnalisations conservées, rejouable.
void main() {
  late Directory dossier;

  setUpAll(() => Hive.registerAdapters());

  setUp(() async {
    dossier = await Directory.systemTemp.createTemp('koudi_migration');
    Hive.init(dossier.path);
    await Hive.openBox<Categorie>(HiveBoxes.categories);
    await Hive.openBox<Compte>(HiveBoxes.comptes);
    final categories = CategorieRepository();
    // Base d'avant la refonte : couleurs et icônes de l'ancienne palette.
    await categories.enregistrer(Categorie(id: 'cat-nourriture', libelle: 'Nourriture', type: TypeMouvement.depense, iconeCode: 'bowlFood', couleurHex: '#F5A623', ordre: 0));
    await categories.enregistrer(Categorie(id: 'cat-sadaqa-deen', libelle: 'Sadaqa & Deen', type: TypeMouvement.depense, iconeCode: 'mosque', couleurHex: '#C9971E', ordre: 10));
    // Personnalisée par l'utilisateur : couleur et nom changés.
    await categories.enregistrer(Categorie(id: 'cat-transport', libelle: 'Moto-taxi', type: TypeMouvement.depense, iconeCode: 'car', couleurHex: '#123456', ordre: 1));
    await categories.enregistrer(Categorie(id: 'cat-autres-entrees', libelle: 'Autres entrées', type: TypeMouvement.entree, iconeCode: 'plusCircle', couleurHex: '#8A97A6', ordre: 4));
    await CompteRepository().enregistrer(Compte(id: 'compte-epargne', libelle: 'Épargne', type: TypeCompte.epargne, iconeCode: 'vault', couleurHex: '#00C2A8'));
  });

  tearDown(() async {
    await Hive.close();
    await dossier.delete(recursive: true);
  });

  Future<void> migrer() => migrerVersRefonteD(comptes: CompteRepository(), categories: CategorieRepository(), langue: 'fr');

  test('palette et icônes d’origine mises à jour, personnalisation conservée', () async {
    await migrer();
    final parId = {for (final c in CategorieRepository().tous()) c.id: c};
    expect(parId['cat-nourriture']!.couleurHex, '#B45309');
    expect(parId['cat-nourriture']!.libelle, 'Nourriture');
    expect(parId['cat-sadaqa-deen']!.iconeCode, 'moon');
    expect(parId['cat-transport']!.couleurHex, '#123456');
    expect(parId['cat-transport']!.libelle, 'Moto-taxi');
    expect(CompteRepository().tous().single.couleurHex, '#0E7A4F');
  });

  test('« Don reçu » ajoutée avant « Autres entrées »', () async {
    await migrer();
    final parId = {for (final c in CategorieRepository().tous()) c.id: c};
    expect(parId['cat-don-recu']!.type, TypeMouvement.entree);
    expect(parId['cat-don-recu']!.ordre, 4);
    expect(parId['cat-autres-entrees']!.ordre, 5);
  });

  test('rejouer la migration ne change rien', () async {
    await migrer();
    final avant = {for (final c in CategorieRepository().tous()) c.id: (c.couleurHex, c.iconeCode, c.ordre)};
    await migrer();
    final apres = {for (final c in CategorieRepository().tous()) c.id: (c.couleurHex, c.iconeCode, c.ordre)};
    expect(apres, avant);
    expect(CategorieRepository().tous().where((c) => c.id == 'cat-don-recu').length, 1);
  });
}
