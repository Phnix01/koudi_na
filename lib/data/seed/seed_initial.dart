import '../models/categorie.dart';
import '../models/compte.dart';
import '../models/pilier.dart';
import '../models/type_mouvement.dart';
import '../repositories/categorie_repository.dart';
import '../repositories/compte_repository.dart';

/// Données proposées à la première ouverture (section 2.4). Les id sont
/// des slugs fixes (pas des UUID) car ce sont des entrées connues à
/// l'avance, pas des créations utilisateur — la génération d'UUID
/// n'interviendra qu'à l'écran Capture, pour les vraies transactions.
///
/// Les libellés existent en français et en anglais : le seed se fait
/// dans la langue de l'utilisateur au premier lancement, puis ces
/// libellés lui appartiennent (modifiables dans Réglages) et ne sont
/// plus retraduits si la langue change ensuite.
///
/// Répartition par pilier (règle 40/25/35) : c'est un choix par défaut,
/// pas une règle du cahier des charges — l'utilisateur peut le changer
/// librement dans Réglages, aucune catégorie n'est figée dans le code.
const Map<String, Map<String, String>> _libelles = {
  'fr': {
    'compte-especes': 'Espèces',
    'compte-banque': 'Compte bancaire',
    'compte-mobile-money': 'Mobile Money',
    'compte-epargne': 'Épargne',
    'cat-nourriture': 'Nourriture',
    'cat-transport': 'Transport',
    'cat-data-telecom': 'Data & Télécom',
    'cat-loyer-charges': 'Loyer & Charges',
    'cat-soutien-familial': 'Soutien familial',
    'cat-epargne': 'Épargne',
    'cat-projets-investissement': 'Projets & Investissement',
    'cat-formation-livres': 'Formation & Livres',
    'cat-sante': 'Santé',
    'cat-habillement': 'Habillement',
    'cat-sadaqa-deen': 'Sadaqa & Deen',
    'cat-divers': 'Divers',
    'cat-salaire': 'Salaire',
    'cat-prestations-contrats': 'Prestations & Contrats',
    'cat-freelance': 'Freelance',
    'cat-business': 'Business',
    'cat-autres-entrees': 'Autres entrées',
  },
  'en': {
    'compte-especes': 'Cash',
    'compte-banque': 'Bank account',
    'compte-mobile-money': 'Mobile Money',
    'compte-epargne': 'Savings',
    'cat-nourriture': 'Food',
    'cat-transport': 'Transport',
    'cat-data-telecom': 'Data & Telecom',
    'cat-loyer-charges': 'Rent & Utilities',
    'cat-soutien-familial': 'Family support',
    'cat-epargne': 'Savings',
    'cat-projets-investissement': 'Projects & Investment',
    'cat-formation-livres': 'Training & Books',
    'cat-sante': 'Health',
    'cat-habillement': 'Clothing',
    'cat-sadaqa-deen': 'Sadaqa & Deen',
    'cat-divers': 'Miscellaneous',
    'cat-salaire': 'Salary',
    'cat-prestations-contrats': 'Services & Contracts',
    'cat-freelance': 'Freelance',
    'cat-business': 'Business',
    'cat-autres-entrees': 'Other income',
  },
};

String _libelle(String langue, String id) =>
    (_libelles[langue] ?? _libelles['fr']!)[id]!;

List<Compte> comptesInitiaux(String langue) => [
  Compte(
    id: 'compte-especes',
    libelle: _libelle(langue, 'compte-especes'),
    type: TypeCompte.especes,
    iconeCode: 'coins',
    couleurHex: '#2ECC71',
  ),
  Compte(
    id: 'compte-banque',
    libelle: _libelle(langue, 'compte-banque'),
    type: TypeCompte.banque,
    iconeCode: 'bank',
    couleurHex: '#3498DB',
  ),
  Compte(
    id: 'compte-mobile-money',
    libelle: _libelle(langue, 'compte-mobile-money'),
    type: TypeCompte.mobileMoney,
    iconeCode: 'deviceMobile',
    couleurHex: '#C9971E',
  ),
  Compte(
    id: 'compte-epargne',
    libelle: _libelle(langue, 'compte-epargne'),
    type: TypeCompte.epargne,
    iconeCode: 'vault',
    couleurHex: '#00C2A8',
  ),
];

/// (id, icône, couleur, pilier, ordre) de chaque catégorie de dépense
/// de départ ; le pilier `null` n'existe que pour les entrées.
typedef _DefCategorie = ({
  String id,
  String icone,
  String couleur,
  Pilier? pilier,
  int ordre,
});

const List<_DefCategorie> _depensesInitiales = [
  (
    id: 'cat-nourriture',
    icone: 'bowlFood',
    couleur: '#F5A623',
    pilier: Pilier.vie,
    ordre: 0,
  ),
  (
    id: 'cat-transport',
    icone: 'car',
    couleur: '#4A90D9',
    pilier: Pilier.vie,
    ordre: 1,
  ),
  (
    id: 'cat-data-telecom',
    icone: 'wifiHigh',
    couleur: '#9B59B6',
    pilier: Pilier.vie,
    ordre: 2,
  ),
  (
    id: 'cat-loyer-charges',
    icone: 'house',
    couleur: '#E74C3C',
    pilier: Pilier.vie,
    ordre: 3,
  ),
  (
    id: 'cat-soutien-familial',
    icone: 'usersThree',
    couleur: '#EC7FA9',
    pilier: Pilier.famille,
    ordre: 4,
  ),
  (
    id: 'cat-epargne',
    icone: 'piggyBank',
    couleur: '#00C2A8',
    pilier: Pilier.epargne,
    ordre: 5,
  ),
  (
    id: 'cat-projets-investissement',
    icone: 'rocketLaunch',
    couleur: '#16A085',
    pilier: Pilier.epargne,
    ordre: 6,
  ),
  (
    id: 'cat-formation-livres',
    icone: 'bookOpen',
    couleur: '#5DADE2',
    pilier: Pilier.vie,
    ordre: 7,
  ),
  (
    id: 'cat-sante',
    icone: 'heartbeat',
    couleur: '#FF6B6B',
    pilier: Pilier.vie,
    ordre: 8,
  ),
  (
    id: 'cat-habillement',
    icone: 'tShirt',
    couleur: '#F1C40F',
    pilier: Pilier.vie,
    ordre: 9,
  ),
  (
    id: 'cat-sadaqa-deen',
    icone: 'mosque',
    couleur: '#C9971E',
    pilier: Pilier.famille,
    ordre: 10,
  ),
  (
    id: 'cat-divers',
    icone: 'dotsThreeOutline',
    couleur: '#8A97A6',
    pilier: Pilier.vie,
    ordre: 11,
  ),
];

// Entrées — pas de pilier : seules les dépenses alimentent la règle 40/25/35.
const List<_DefCategorie> _entreesInitiales = [
  (
    id: 'cat-salaire',
    icone: 'wallet',
    couleur: '#2ECC71',
    pilier: null,
    ordre: 0,
  ),
  (
    id: 'cat-prestations-contrats',
    icone: 'fileText',
    couleur: '#3498DB',
    pilier: null,
    ordre: 1,
  ),
  (
    id: 'cat-freelance',
    icone: 'laptop',
    couleur: '#9B59B6',
    pilier: null,
    ordre: 2,
  ),
  (
    id: 'cat-business',
    icone: 'storefront',
    couleur: '#F39C12',
    pilier: null,
    ordre: 3,
  ),
  (
    id: 'cat-autres-entrees',
    icone: 'plusCircle',
    couleur: '#8A97A6',
    pilier: null,
    ordre: 4,
  ),
];

List<Categorie> categoriesInitiales(String langue) => [
  for (final d in _depensesInitiales)
    Categorie(
      id: d.id,
      libelle: _libelle(langue, d.id),
      type: TypeMouvement.depense,
      iconeCode: d.icone,
      couleurHex: d.couleur,
      pilier: d.pilier,
      ordre: d.ordre,
    ),
  for (final d in _entreesInitiales)
    Categorie(
      id: d.id,
      libelle: _libelle(langue, d.id),
      type: TypeMouvement.entree,
      iconeCode: d.icone,
      couleurHex: d.couleur,
      ordre: d.ordre,
    ),
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
