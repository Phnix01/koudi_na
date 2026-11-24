import 'package:intl/intl.dart';

/// Noms des comptes et catégories proposés au premier lancement, en
/// français et en anglais, longs (listes) et courts (tuiles de la grille
/// de saisie). Table Dart plutôt que clés ARB, même principe que
/// `devises.dart` et `badges.dart` : les clés stables sont les ids du
/// seed, et les services (export PDF, import CSV) s'en servent sans
/// `BuildContext`.
class LibelleSeed {
  const LibelleSeed(this.fr, this.en, {String? frCourt, String? enCourt})
    : frCourt = frCourt ?? fr,
      enCourt = enCourt ?? en;

  final String fr;
  final String en;
  final String frCourt;
  final String enCourt;
}

const Map<String, LibelleSeed> libellesSeed = {
  'compte-especes': LibelleSeed('Espèces', 'Cash'),
  'compte-banque': LibelleSeed('Banque', 'Bank'),
  'compte-mobile-money': LibelleSeed('Mobile money', 'Mobile money'),
  // « Coffre » plutôt qu'« Épargne » : lève l'ambiguïté avec la catégorie.
  'compte-epargne': LibelleSeed('Coffre', 'Vault'),
  'cat-nourriture': LibelleSeed('Alimentation', 'Food', frCourt: 'Repas', enCourt: 'Meals'),
  'cat-transport': LibelleSeed('Transport', 'Transport'),
  'cat-data-telecom': LibelleSeed('Data & Télécom', 'Data & Telecom', frCourt: 'Data', enCourt: 'Data'),
  'cat-loyer-charges': LibelleSeed('Loyer & charges', 'Rent & utilities', frCourt: 'Logement', enCourt: 'Housing'),
  'cat-soutien-familial': LibelleSeed('Famille', 'Family'),
  'cat-epargne': LibelleSeed('Épargne', 'Savings'),
  'cat-projets-investissement': LibelleSeed('Projets', 'Projects'),
  'cat-formation-livres': LibelleSeed('Formation', 'Learning'),
  'cat-sante': LibelleSeed('Santé', 'Health'),
  'cat-habillement': LibelleSeed('Vêtements', 'Clothing', frCourt: 'Habits', enCourt: 'Clothes'),
  'cat-sadaqa-deen': LibelleSeed('Sadaqa & Deen', 'Sadaqa & Deen', frCourt: 'Sadaqa', enCourt: 'Sadaqa'),
  'cat-divers': LibelleSeed('Divers', 'Miscellaneous', enCourt: 'Misc.'),
  'cat-salaire': LibelleSeed('Salaire', 'Salary'),
  'cat-prestations-contrats': LibelleSeed('Prestations & contrats', 'Services & contracts', frCourt: 'Prestations', enCourt: 'Contracts'),
  'cat-freelance': LibelleSeed('Freelance', 'Freelance'),
  'cat-business': LibelleSeed('Business', 'Business'),
  'cat-don-recu': LibelleSeed('Don reçu', 'Gift received', enCourt: 'Gift'),
  'cat-autres-entrees': LibelleSeed('Autre entrée', 'Other income', frCourt: 'Autre', enCourt: 'Other'),
};

/// Noms donnés par les versions précédentes. Un compte ou une catégorie
/// qui porte encore l'un d'eux n'a pas été renommé par l'utilisateur.
const Map<String, List<String>> anciensLibellesSeed = {
  'compte-banque': ['Compte bancaire', 'Bank account'],
  'compte-mobile-money': ['Mobile Money'],
  'compte-epargne': ['Épargne', 'Savings'],
  'cat-nourriture': ['Nourriture'],
  'cat-loyer-charges': ['Loyer & Charges', 'Rent & Utilities'],
  'cat-soutien-familial': ['Soutien familial', 'Family support'],
  'cat-projets-investissement': ['Projets & Investissement', 'Projects & Investment'],
  'cat-formation-livres': ['Formation & Livres', 'Training & Books'],
  'cat-habillement': ['Habillement'],
  'cat-prestations-contrats': ['Prestations & Contrats', 'Services & Contracts'],
  'cat-autres-entrees': ['Autres entrées'],
};

/// Tous les noms qu'un élément du seed a pu porter (FR, EN, courts,
/// anciens) : pour savoir s'il a été renommé, et pour l'import CSV.
Set<String> nomsConnusSeed(String id) {
  final s = libellesSeed[id];
  if (s == null) return const {};
  return {s.fr, s.en, s.frCourt, s.enCourt, ...?anciensLibellesSeed[id]};
}

bool _anglais() => (Intl.defaultLocale ?? Intl.getCurrentLocale()).startsWith('en');

/// Nom à afficher : la traduction de la langue courante pour un élément
/// du seed resté tel quel, le nom choisi par l'utilisateur sinon.
///
/// [langue] force la langue (exports) ; sinon celle de l'app.
String libelleAffiche(String id, String libelleStocke, {bool court = false, String? langue}) {
  final s = libellesSeed[id];
  if (s == null || !nomsConnusSeed(id).contains(libelleStocke.trim())) {
    return libelleStocke;
  }
  if (langue != null ? langue == 'en' : _anglais()) return court ? s.enCourt : s.en;
  return court ? s.frCourt : s.fr;
}
