import '../models/categorie.dart';
import '../models/compte.dart';
import '../models/pilier.dart';
import '../models/type_mouvement.dart';
import '../repositories/categorie_repository.dart';
import '../repositories/compte_repository.dart';
import 'libelles_seed.dart';

/// Données proposées à la première ouverture (section 2.4). Les id sont
/// des slugs fixes (pas des UUID) car ce sont des entrées connues à
/// l'avance, pas des créations utilisateur.
///
/// Les noms viennent de `libelles_seed.dart` dans la langue du premier
/// lancement ; à l'affichage, un élément jamais renommé suit ensuite la
/// langue de l'app (voir `libelleAffiche`).
///
/// Répartition par pilier (règle 40/25/35) : c'est un choix par défaut,
/// l'utilisateur peut le changer librement dans Réglages.
String _libelle(String langue, String id) {
  final s = libellesSeed[id]!;
  return langue == 'en' ? s.en : s.fr;
}

/// (id, icône, couleur, pilier, ordre) d'une catégorie de départ, avec
/// l'icône et la couleur des versions précédentes : la migration ne les
/// remplace que si l'utilisateur ne les a pas changées.
typedef _DefCategorie = ({
  String id,
  String icone,
  String couleur,
  String? ancienneIcone,
  String? ancienneCouleur,
  Pilier? pilier,
  int ordre,
});

typedef _DefCompte = ({
  String id,
  TypeCompte type,
  String icone,
  String couleur,
  String ancienneCouleur,
});

const List<_DefCompte> _comptesInitiaux = [
  (id: 'compte-especes', type: TypeCompte.especes, icone: 'coins', couleur: '#B45309', ancienneCouleur: '#2ECC71'),
  (id: 'compte-banque', type: TypeCompte.banque, icone: 'bank', couleur: '#2F5BD3', ancienneCouleur: '#3498DB'),
  (id: 'compte-mobile-money', type: TypeCompte.mobileMoney, icone: 'deviceMobile', couleur: '#7C4DCC', ancienneCouleur: '#C9971E'),
  (id: 'compte-epargne', type: TypeCompte.epargne, icone: 'vault', couleur: '#0E7A4F', ancienneCouleur: '#00C2A8'),
];

// Palette et icônes du brief de refonte D (§2 et §3).
const List<_DefCategorie> _depensesInitiales = [
  (id: 'cat-nourriture', icone: 'bowlFood', couleur: '#B45309', ancienneIcone: null, ancienneCouleur: '#F5A623', pilier: Pilier.vie, ordre: 0),
  (id: 'cat-transport', icone: 'car', couleur: '#2F5BD3', ancienneIcone: null, ancienneCouleur: '#4A90D9', pilier: Pilier.vie, ordre: 1),
  (id: 'cat-data-telecom', icone: 'wifiHigh', couleur: '#7C4DCC', ancienneIcone: null, ancienneCouleur: '#9B59B6', pilier: Pilier.vie, ordre: 2),
  (id: 'cat-loyer-charges', icone: 'house', couleur: '#C2410C', ancienneIcone: null, ancienneCouleur: '#E74C3C', pilier: Pilier.vie, ordre: 3),
  (id: 'cat-soutien-familial', icone: 'users', couleur: '#BE3A78', ancienneIcone: 'usersThree', ancienneCouleur: '#EC7FA9', pilier: Pilier.famille, ordre: 4),
  (id: 'cat-epargne', icone: 'piggyBank', couleur: '#0E7A4F', ancienneIcone: null, ancienneCouleur: '#00C2A8', pilier: Pilier.epargne, ordre: 5),
  (id: 'cat-projets-investissement', icone: 'trendUp', couleur: '#0F766E', ancienneIcone: 'rocketLaunch', ancienneCouleur: '#16A085', pilier: Pilier.epargne, ordre: 6),
  (id: 'cat-formation-livres', icone: 'bookOpen', couleur: '#1D4ED8', ancienneIcone: null, ancienneCouleur: '#5DADE2', pilier: Pilier.vie, ordre: 7),
  (id: 'cat-sante', icone: 'heart', couleur: '#BE123C', ancienneIcone: 'heartbeat', ancienneCouleur: '#FF6B6B', pilier: Pilier.vie, ordre: 8),
  (id: 'cat-habillement', icone: 'tShirt', couleur: '#A16207', ancienneIcone: null, ancienneCouleur: '#F1C40F', pilier: Pilier.vie, ordre: 9),
  (id: 'cat-sadaqa-deen', icone: 'moon', couleur: '#8A6A2F', ancienneIcone: 'mosque', ancienneCouleur: '#C9971E', pilier: Pilier.famille, ordre: 10),
  (id: 'cat-divers', icone: 'dotsThree', couleur: '#5F5F66', ancienneIcone: 'dotsThreeOutline', ancienneCouleur: '#8A97A6', pilier: Pilier.vie, ordre: 11),
];

// Entrées — pas de pilier : seules les dépenses alimentent la règle 40/25/35.
const List<_DefCategorie> _entreesInitiales = [
  (id: 'cat-salaire', icone: 'trendUp', couleur: '#0E7A4F', ancienneIcone: 'wallet', ancienneCouleur: '#2ECC71', pilier: null, ordre: 0),
  (id: 'cat-prestations-contrats', icone: 'handshake', couleur: '#0F766E', ancienneIcone: 'fileText', ancienneCouleur: '#3498DB', pilier: null, ordre: 1),
  (id: 'cat-freelance', icone: 'laptop', couleur: '#2F5BD3', ancienneIcone: null, ancienneCouleur: '#9B59B6', pilier: null, ordre: 2),
  (id: 'cat-business', icone: 'storefront', couleur: '#A16207', ancienneIcone: null, ancienneCouleur: '#F39C12', pilier: null, ordre: 3),
  (id: 'cat-don-recu', icone: 'gift', couleur: '#BE3A78', ancienneIcone: null, ancienneCouleur: null, pilier: null, ordre: 4),
  (id: 'cat-autres-entrees', icone: 'dotsThree', couleur: '#5F5F66', ancienneIcone: 'plusCircle', ancienneCouleur: '#8A97A6', pilier: null, ordre: 5),
];

List<Compte> comptesInitiaux(String langue) => [
  for (final d in _comptesInitiaux)
    Compte(
      id: d.id,
      libelle: _libelle(langue, d.id),
      type: d.type,
      iconeCode: d.icone,
      couleurHex: d.couleur,
    ),
];

Categorie _categorie(_DefCategorie d, TypeMouvement type, String langue) => Categorie(
  id: d.id,
  libelle: _libelle(langue, d.id),
  type: type,
  iconeCode: d.icone,
  couleurHex: d.couleur,
  pilier: d.pilier,
  ordre: d.ordre,
);

List<Categorie> categoriesInitiales(String langue) => [
  for (final d in _depensesInitiales) _categorie(d, TypeMouvement.depense, langue),
  for (final d in _entreesInitiales) _categorie(d, TypeMouvement.entree, langue),
];

/// Peuple les Box "comptes" et "categories" si elles sont vides.
/// Idempotent : appeler cette fonction à chaque démarrage ne duplique
/// rien, seul le tout premier lancement écrit des données.
Future<void> seedSiPremierLancement({
  required CompteRepository comptes,
  required CategorieRepository categories,
  required String langue,
}) async {
  if (comptes.estVide) {
    for (final compte in comptesInitiaux(langue)) {
      await comptes.enregistrer(compte);
    }
  }
  if (categories.estVide) {
    for (final categorie in categoriesInitiales(langue)) {
      await categories.enregistrer(categorie);
    }
  }
}

/// Mise à niveau des données d'avant la refonte D, sans perte : ids et
/// noms stockés intacts (l'affichage traduit les noms d'origine, voir
/// `libelleAffiche`). Ne remplace une couleur ou une icône que si elle a
/// encore sa valeur d'origine, ajoute « Don reçu » s'il manque. Rejouable
/// sans effet : chaque étape vérifie l'état avant d'écrire.
Future<void> migrerVersRefonteD({
  required CompteRepository comptes,
  required CategorieRepository categories,
  required String langue,
}) async {
  final existantes = {for (final c in categories.tous()) c.id: c};
  for (final d in [..._depensesInitiales, ..._entreesInitiales]) {
    final c = existantes[d.id];
    if (c == null) continue;
    var modifiee = false;
    if (d.ancienneCouleur != null && c.couleurHex.toUpperCase() == d.ancienneCouleur) {
      c.couleurHex = d.couleur;
      modifiee = true;
    }
    if (d.ancienneIcone != null && c.iconeCode == d.ancienneIcone) {
      c.iconeCode = d.icone;
      modifiee = true;
    }
    if (modifiee) await categories.enregistrer(c);
  }

  // « Don reçu » se glisse avant « Autres entrées », si celle-ci est
  // encore à sa place d'origine.
  if (existantes.isNotEmpty && !existantes.containsKey('cat-don-recu')) {
    final autres = existantes['cat-autres-entrees'];
    if (autres != null && autres.ordre == 4) {
      autres.ordre = 5;
      await categories.enregistrer(autres);
    }
    final don = _entreesInitiales.firstWhere((d) => d.id == 'cat-don-recu');
    await categories.enregistrer(_categorie(don, TypeMouvement.entree, langue));
  }

  for (final compte in comptes.tous()) {
    for (final d in _comptesInitiaux) {
      if (compte.id == d.id && compte.couleurHex.toUpperCase() == d.ancienneCouleur) {
        compte.couleurHex = d.couleur;
        await comptes.enregistrer(compte);
      }
    }
  }
}
