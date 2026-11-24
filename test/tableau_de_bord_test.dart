import 'package:flutter_test/flutter_test.dart';
import 'package:koudi_na/core/utils/formatters.dart';
import 'package:koudi_na/data/models/categorie.dart';
import 'package:koudi_na/data/models/pilier.dart';
import 'package:koudi_na/data/models/transaction.dart';
import 'package:koudi_na/data/models/type_mouvement.dart';
import 'package:koudi_na/logic/services/tableau_de_bord.dart';

Categorie _cat(String id, Pilier? pilier, {TypeMouvement type = TypeMouvement.depense}) =>
    Categorie(id: id, libelle: id, type: type, iconeCode: 'dotsThree', couleurHex: '#5F5F66', pilier: pilier);

var _n = 0;
Transaction _t(DateTime date, int montant, String categorieId, {TypeMouvement type = TypeMouvement.depense, String compte = 'compte-especes'}) =>
    Transaction(id: '${_n++}', date: date, type: type, montant: montant, categorieId: categorieId, compteId: compte);

void main() {
  final categories = [
    _cat('salaire', null, type: TypeMouvement.entree),
    _cat('repas', Pilier.vie),
    _cat('famille', Pilier.famille),
    _cat('epargne', Pilier.epargne),
  ];
  final novembre = DateTime(2026, 11);
  final le24 = DateTime(2026, 11, 24, 18);

  // Le scénario des maquettes : 350 000 d'entrées, 186 500 de dépenses
  // au 24 novembre, dont 100 000 d'épargne.
  final maquette = [
    _t(DateTime(2026, 11, 1), 350000, 'salaire', type: TypeMouvement.entree),
    _t(DateTime(2026, 11, 1), 100000, 'epargne'),
    _t(DateTime(2026, 11, 20), 50000, 'famille'),
    _t(DateTime(2026, 11, 24), 36500, 'repas'),
  ];

  test('solde du mois = entrées − dépenses', () {
    final t = calculerTableauDeBord(maquette, categories, mois: novembre, maintenant: le24);
    expect(t.entrees, 350000);
    expect(t.depenses, 186500);
    expect(t.solde, 163500);
  });

  test('rythme : 53 % dépensé au jour 24 / 30 → en avance', () {
    final r = calculerTableauDeBord(maquette, categories, mois: novembre, maintenant: le24).rythme!;
    expect(r.ratioDepense, closeTo(0.533, 0.001));
    expect(r.ratioTemps, closeTo(0.8, 0.001));
    expect((r.jour, r.joursDuMois), (24, 30));
    expect(r.enAvance, isTrue);
  });

  test('rythme : dépenser plus vite que le temps → attention', () {
    final rapide = [
      _t(DateTime(2026, 11, 1), 100000, 'salaire', type: TypeMouvement.entree),
      _t(DateTime(2026, 11, 3), 60000, 'repas'),
    ];
    final r = calculerTableauDeBord(rapide, categories, mois: novembre, maintenant: DateTime(2026, 11, 5)).rythme!;
    expect(r.enAvance, isFalse);
  });

  test('sans entrée, pas de barre de rythme', () {
    final sansEntree = [_t(DateTime(2026, 11, 3), 5000, 'repas')];
    expect(calculerTableauDeBord(sansEntree, categories, mois: novembre, maintenant: le24).rythme, isNull);
  });

  test('projection : dépenses / jour × jours du mois, à 3 chiffres significatifs', () {
    final t = calculerTableauDeBord(maquette, categories, mois: novembre, maintenant: le24);
    // 186 500 / 24 × 30 = 233 125 → 233 000
    expect(t.projectionFinDeMois, 233000);
  });

  test('projection d’un mois terminé = total réel', () {
    final t = calculerTableauDeBord(maquette, categories, mois: novembre, maintenant: DateTime(2026, 12, 5));
    expect(t.projectionFinDeMois, 186500);
    expect(t.rythme!.jour, 30);
  });

  test('mois pas encore commencé : rien d’écoulé, pas de division par zéro', () {
    final t = calculerTableauDeBord(maquette, categories, mois: DateTime(2026, 12), maintenant: le24);
    expect(t.projectionFinDeMois, 0);
    expect(t.moyenneParJour, 0);
    expect(t.rythme, isNull);
  });

  test('moyenne par jour, avec et hors épargne', () {
    final t = calculerTableauDeBord(maquette, categories, mois: novembre, maintenant: le24);
    expect(t.moyenneParJour, (186500 / 24).round());
    expect(t.moyenneParJourHorsEpargne, (86500 / 24).round());
  });

  test('enveloppes 40/25/35 : budget, consommé, reste', () {
    final e = calculerTableauDeBord(maquette, categories, mois: novembre, maintenant: le24).enveloppes;
    final epargne = e.firstWhere((x) => x.pilier == Pilier.epargne);
    expect((epargne.budget, epargne.consomme, epargne.reste), (140000, 100000, 40000));
    final famille = e.firstWhere((x) => x.pilier == Pilier.famille);
    expect((famille.budget, famille.reste), (87500, 37500));
  });

  test('enveloppe dépassée : reste négatif', () {
    final depasse = [
      _t(DateTime(2026, 11, 1), 100000, 'salaire', type: TypeMouvement.entree),
      _t(DateTime(2026, 11, 2), 40000, 'famille'),
    ];
    final famille = calculerTableauDeBord(depasse, categories, mois: novembre, maintenant: le24)
        .enveloppes
        .firstWhere((x) => x.pilier == Pilier.famille);
    expect(famille.reste, -15000);
  });

  test('les autres mois ne comptent pas', () {
    final melange = [...maquette, _t(DateTime(2026, 10, 30), 99999, 'repas')];
    expect(calculerTableauDeBord(melange, categories, mois: novembre, maintenant: le24).depenses, 186500);
  });

  test('dernier choix par type, pour présélectionner la saisie', () {
    final historique = [
      _t(DateTime(2026, 11, 2), 1000, 'repas', compte: 'compte-banque'),
      _t(DateTime(2026, 11, 9), 2000, 'famille', compte: 'compte-especes'),
      _t(DateTime(2026, 11, 10), 5000, 'salaire', type: TypeMouvement.entree, compte: 'compte-banque'),
    ];
    expect(dernierChoix(historique, TypeMouvement.depense), (categorieId: 'famille', compteId: 'compte-especes'));
    expect(dernierChoix(historique, TypeMouvement.entree), (categorieId: 'salaire', compteId: 'compte-banque'));
    expect(dernierChoix(const [], TypeMouvement.depense), (categorieId: null, compteId: null));
  });

  test('arrondi à 3 chiffres significatifs, adapté à toutes les devises', () {
    expect(arrondiSignificatif(212487), 212000);
    expect(arrondiSignificatif(1234), 1230);
    expect(arrondiSignificatif(987), 987);
    expect(arrondiSignificatif(12550000), 12600000);
  });
}
