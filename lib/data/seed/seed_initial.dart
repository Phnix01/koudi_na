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
/// Répartition par pilier (règle 40/25/35) : c'est un choix par défaut,
/// pas une règle du cahier des charges — l'utilisateur peut le changer
/// librement dans Réglages, aucune catégorie n'est figée dans le code.
final List<Compte> comptesInitiaux = [
  Compte(
    id: 'compte-especes',
    libelle: 'Espèces',
    type: TypeCompte.especes,
    iconeCode: 'coins',
    couleurHex: '#2ECC71',
  ),
  Compte(
    id: 'compte-banque',
    libelle: 'Compte bancaire',
    type: TypeCompte.banque,
    iconeCode: 'bank',
    couleurHex: '#3498DB',
  ),
  Compte(
    id: 'compte-mobile-money',
    libelle: 'Mobile Money',
    type: TypeCompte.mobileMoney,
    iconeCode: 'deviceMobile',
    couleurHex: '#C9971E',
  ),
  Compte(
    id: 'compte-epargne',
    libelle: 'Épargne',
    type: TypeCompte.epargne,
    iconeCode: 'vault',
    couleurHex: '#00C2A8',
  ),
];

final List<Categorie> categoriesInitiales = [
  // Dépenses
  Categorie(
    id: 'cat-nourriture',
    libelle: 'Nourriture',
    type: TypeMouvement.depense,
    iconeCode: 'bowlFood',
    couleurHex: '#F5A623',
    pilier: Pilier.vie,
    ordre: 0,
  ),
  Categorie(
    id: 'cat-transport',
    libelle: 'Transport',
    type: TypeMouvement.depense,
    iconeCode: 'car',
    couleurHex: '#4A90D9',
    pilier: Pilier.vie,
    ordre: 1,
  ),
  Categorie(
    id: 'cat-data-telecom',
    libelle: 'Data & Télécom',
    type: TypeMouvement.depense,
    iconeCode: 'wifiHigh',
    couleurHex: '#9B59B6',
    pilier: Pilier.vie,
    ordre: 2,
  ),
  Categorie(
    id: 'cat-loyer-charges',
    libelle: 'Loyer & Charges',
    type: TypeMouvement.depense,
    iconeCode: 'house',
    couleurHex: '#E74C3C',
    pilier: Pilier.vie,
    ordre: 3,
  ),
  Categorie(
    id: 'cat-soutien-familial',
    libelle: 'Soutien familial',
    type: TypeMouvement.depense,
    iconeCode: 'usersThree',
    couleurHex: '#EC7FA9',
    pilier: Pilier.famille,
    ordre: 4,
  ),
  Categorie(
    id: 'cat-epargne',
    libelle: 'Épargne',
    type: TypeMouvement.depense,
    iconeCode: 'piggyBank',
    couleurHex: '#00C2A8',
    pilier: Pilier.epargne,
    ordre: 5,
  ),
  Categorie(
    id: 'cat-projets-investissement',
    libelle: 'Projets & Investissement',
    type: TypeMouvement.depense,
    iconeCode: 'rocketLaunch',
    couleurHex: '#16A085',
    pilier: Pilier.epargne,
    ordre: 6,
  ),
  Categorie(
    id: 'cat-formation-livres',
    libelle: 'Formation & Livres',
    type: TypeMouvement.depense,
    iconeCode: 'bookOpen',
    couleurHex: '#5DADE2',
    pilier: Pilier.vie,
    ordre: 7,
  ),
  Categorie(
    id: 'cat-sante',
    libelle: 'Santé',
    type: TypeMouvement.depense,
    iconeCode: 'heartbeat',
    couleurHex: '#FF6B6B',
    pilier: Pilier.vie,
    ordre: 8,
  ),
  Categorie(
    id: 'cat-habillement',
    libelle: 'Habillement',
    type: TypeMouvement.depense,
    iconeCode: 'tShirt',
    couleurHex: '#F1C40F',
    pilier: Pilier.vie,
    ordre: 9,
  ),
  Categorie(
    id: 'cat-sadaqa-deen',
    libelle: 'Sadaqa & Deen',
    type: TypeMouvement.depense,
    iconeCode: 'mosque',
    couleurHex: '#C9971E',
    pilier: Pilier.famille,
    ordre: 10,
  ),
  Categorie(
    id: 'cat-divers',
    libelle: 'Divers',
    type: TypeMouvement.depense,
    iconeCode: 'dotsThreeOutline',
    couleurHex: '#8A97A6',
    pilier: Pilier.vie,
    ordre: 11,
  ),

  // Entrées — pas de pilier : seules les dépenses alimentent la règle 40/25/35.
  Categorie(
    id: 'cat-salaire',
    libelle: 'Salaire',
    type: TypeMouvement.entree,
    iconeCode: 'wallet',
    couleurHex: '#2ECC71',
    ordre: 0,
  ),
  Categorie(
    id: 'cat-prestations-contrats',
    libelle: 'Prestations & Contrats',
    type: TypeMouvement.entree,
    iconeCode: 'fileText',
    couleurHex: '#3498DB',
    ordre: 1,
  ),
  Categorie(
    id: 'cat-freelance',
    libelle: 'Freelance',
    type: TypeMouvement.entree,
    iconeCode: 'laptop',
    couleurHex: '#9B59B6',
    ordre: 2,
  ),
  Categorie(
    id: 'cat-business',
    libelle: 'Business',
    type: TypeMouvement.entree,
    iconeCode: 'storefront',
    couleurHex: '#F39C12',
    ordre: 3,
  ),
  Categorie(
    id: 'cat-autres-entrees',
    libelle: 'Autres entrées',
    type: TypeMouvement.entree,
    iconeCode: 'plusCircle',
    couleurHex: '#8A97A6',
    ordre: 4,
  ),
];

/// Peuple les Box "comptes" et "categories" si elles sont vides.
/// Idempotent : appeler cette fonction à chaque démarrage ne duplique
/// rien, seul le tout premier lancement écrit des données.
Future<void> seedSiPremierLancement({
  required CompteRepository comptes,
  required CategorieRepository categories,
}) async {
  if (comptes.estVide) {
    for (final compte in comptesInitiaux) {
      await comptes.enregistrer(compte);
    }
  }
  if (categories.estVide) {
    for (final categorie in categoriesInitiales) {
      await categories.enregistrer(categorie);
    }
  }
}
