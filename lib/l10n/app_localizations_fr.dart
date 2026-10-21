// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitre => 'Koudi Na';

  @override
  String get enregistrer => 'Enregistrer';

  @override
  String get enregistrerModifications => 'Enregistrer les modifications';

  @override
  String get annuler => 'Annuler';

  @override
  String get supprimer => 'Supprimer';

  @override
  String get modifier => 'Modifier';

  @override
  String get tous => 'Tous';

  @override
  String get reinitialiser => 'Réinitialiser';

  @override
  String get aChoisir => 'À choisir';

  @override
  String get nouveau => 'Nouveau';

  @override
  String get total => 'Total';

  @override
  String get objectif => 'Objectif';

  @override
  String get depense => 'Dépense';

  @override
  String get entree => 'Entrée';

  @override
  String get depenses => 'Dépenses';

  @override
  String get entrees => 'Entrées';

  @override
  String get solde => 'Solde';

  @override
  String get soldeDuMois => 'Solde du mois';

  @override
  String get type => 'Type';

  @override
  String get categorie => 'Catégorie';

  @override
  String get categories => 'Catégories';

  @override
  String get compte => 'Compte';

  @override
  String get comptes => 'Comptes';

  @override
  String get recurrences => 'Récurrences';

  @override
  String get libelle => 'Libellé';

  @override
  String get icone => 'Icône';

  @override
  String get couleur => 'Couleur';

  @override
  String get pilierEpargne => 'Épargne';

  @override
  String get pilierFamille => 'Famille';

  @override
  String get pilierVie => 'Vie';

  @override
  String get regle402535 => 'Règle 40/25/35';

  @override
  String get pilierRegle => 'Pilier (règle 40/25/35)';

  @override
  String get typeCompteEspeces => 'Espèces';

  @override
  String get typeCompteBanque => 'Banque';

  @override
  String get typeCompteMobileMoney => 'Mobile Money';

  @override
  String get typeCompteEpargne => 'Épargne';

  @override
  String get tooltipAnalyse => 'Analyse';

  @override
  String get tooltipVoirLeMois => 'Voir le mois';

  @override
  String get tooltipReglages => 'Réglages';

  @override
  String get aujourdHui => 'Aujourd\'hui';

  @override
  String get hier => 'Hier';

  @override
  String get aucuneTransactionFiltres => 'Aucune transaction pour ces filtres';

  @override
  String get aucuneTransactionMois => 'Aucune transaction ce mois-ci';

  @override
  String get transactionSupprimee => 'Transaction supprimée';

  @override
  String get categorieSupprimee => 'Catégorie supprimée';

  @override
  String get compteSupprime => 'Compte supprimé';

  @override
  String get supprimerTransactionTitre => 'Supprimer cette transaction ?';

  @override
  String get actionIrreversible => 'Cette action est irréversible.';

  @override
  String get desactivees => 'Désactivées';

  @override
  String get nouvelleCategorie => 'Nouvelle catégorie';

  @override
  String get modifierCategorie => 'Modifier la catégorie';

  @override
  String get active => 'Active';

  @override
  String get actif => 'Actif';

  @override
  String get categorieDesactiveeExplication =>
      'Une catégorie désactivée disparaît de la saisie, sans effacer son historique';

  @override
  String soldeInitialValeur(String montant) {
    return 'Solde initial : $montant';
  }

  @override
  String get nouveauCompte => 'Nouveau compte';

  @override
  String get modifierCompte => 'Modifier le compte';

  @override
  String get soldeInitialFcfa => 'Solde initial (FCFA)';

  @override
  String get objectifEpargneFcfa => 'Objectif d\'épargne (FCFA, optionnel)';

  @override
  String get objectifEpargneAide =>
      'Utilisé comme ligne de repère dans le graphique « Trajectoire d\'épargne »';

  @override
  String get compteDesactiveExplication =>
      'Un compte désactivé disparaît de la saisie, sans effacer son historique';

  @override
  String get aucuneRecurrence => 'Aucune récurrence pour l\'instant';

  @override
  String recurrenceSousTitre(String categorie, int jour) {
    return '$categorie · le $jour de chaque mois';
  }

  @override
  String get nouvelleRecurrence => 'Nouvelle récurrence';

  @override
  String get modifierRecurrence => 'Modifier la récurrence';

  @override
  String get libelleExemple => 'Libellé (ex : Loyer, Salaire)';

  @override
  String get montantFcfa => 'Montant (FCFA)';

  @override
  String get jourDuMois => 'Jour du mois (1-31)';

  @override
  String get recurrenceDesactiveeExplication =>
      'Une récurrence désactivée ne génère plus de transaction';

  @override
  String get reglages => 'Réglages';

  @override
  String get donnees => 'Données';

  @override
  String get export => 'Export';

  @override
  String get exporterMoisCourant => 'Exporter le mois courant';

  @override
  String get exporterTout => 'Exporter toutes les transactions';

  @override
  String exportPartageTexte(String nomFichier) {
    return 'Export Koudi Na — $nomFichier';
  }

  @override
  String get import => 'Import';

  @override
  String get importerCsv => 'Importer un CSV';

  @override
  String get importerCsvSousTitre =>
      'Reprendre un export Koudi Na (mêmes colonnes)';

  @override
  String get fichierIllisible => 'Impossible de lire ce fichier.';

  @override
  String get importerTitre => 'Importer ce fichier ?';

  @override
  String importResume(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre transactions seront ajoutées.',
      one: '1 transaction sera ajoutée.',
      zero: 'Aucune transaction ne sera ajoutée.',
    );
    return '$_temp0';
  }

  @override
  String importIgnorees(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other:
          '$nombre lignes ignorées (catégorie, compte ou montant introuvable).',
      one: '1 ligne ignorée (catégorie, compte ou montant introuvable).',
    );
    return '$_temp0';
  }

  @override
  String get importDoublonsAvertissement =>
      'Cet import ajoute ces transactions sans vérifier les doublons : réimporter le même fichier deux fois crée deux copies.';

  @override
  String get importer => 'Importer';

  @override
  String importTermine(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre transactions importées.',
      one: '1 transaction importée.',
    );
    return '$_temp0';
  }

  @override
  String get langue => 'Langue';

  @override
  String get langueSysteme => 'Système';

  @override
  String get analyse => 'Analyse';

  @override
  String get evolution12Mois => 'Évolution sur 12 mois';

  @override
  String get repartitionDepensesMois => 'Répartition des dépenses (ce mois)';

  @override
  String get top5Titre => 'Top 5 des catégories (ce mois vs le mois dernier)';

  @override
  String get moisDernier => 'Mois dernier';

  @override
  String get ceMoisCouleurCategorie => 'Ce mois : couleur de la catégorie';

  @override
  String get rythmeDuMois => 'Rythme du mois';

  @override
  String get habitudesHebdo90 => 'Habitudes hebdomadaires (90 derniers jours)';

  @override
  String get trajectoireEpargne => 'Trajectoire d\'épargne';

  @override
  String get aucunObjectifRegle =>
      'Aucun objectif réglé : ouvre Réglages → Comptes → ton compte Épargne pour en fixer un.';

  @override
  String get equilibrePiliers6Mois => 'Équilibre des piliers (6 mois)';

  @override
  String get autonomieFinanciere => 'Autonomie financière';

  @override
  String autonomieValeur(String mois) {
    return '$mois mois';
  }

  @override
  String get autonomieDescription =>
      'Nombre de mois de dépenses moyennes que couvre ton épargne actuelle';

  @override
  String get tauxEpargne => 'Taux d\'épargne';

  @override
  String get joursSansDepense => 'Jours sans dépense';

  @override
  String get depenseMoyJourMois => 'Dépense moy. / jour (ce mois)';

  @override
  String get depenseMoyJourHistorique => 'Dépense moy. / jour (historique)';

  @override
  String get projectionFinDeMois => 'Projection fin de mois';

  @override
  String get projectionDepasseEntrees =>
      'Au rythme actuel, tu dépasseras tes entrées ce mois-ci';

  @override
  String get pasAssezDonnees => 'Pas assez de données';

  @override
  String get pasAssezDonneesComparer => 'Pas assez de données pour comparer';

  @override
  String get pasAssezDonnees90Jours =>
      'Pas assez de données sur les 90 derniers jours';

  @override
  String get aucuneDepenseMois => 'Aucune dépense ce mois-ci';

  @override
  String get entreesDuMois => 'Entrées du mois';

  @override
  String get momentMatin => 'Matin';

  @override
  String get momentApresMidi => 'Aprèm';

  @override
  String get momentSoir => 'Soir';

  @override
  String get momentNuit => 'Nuit';

  @override
  String get retirerNote => 'Retirer la note';

  @override
  String get ajouterNote => 'Ajouter une note';

  @override
  String get noteOptionnelle => 'Note (optionnel)';

  @override
  String obsHausse(String categorie, int pourcent) {
    return 'Tes dépenses en $categorie ont augmenté de $pourcent % ce mois-ci.';
  }

  @override
  String obsDepassement(String montant) {
    return 'Au rythme actuel, tu dépasseras tes entrées de $montant d\'ici la fin du mois.';
  }

  @override
  String obsObjectifEpargne(int mois) {
    String _temp0 = intl.Intl.pluralLogic(
      mois,
      locale: localeName,
      other: 'Tu as respecté ton objectif d\'épargne $mois mois de suite.',
    );
    return '$_temp0';
  }

  @override
  String obsAutonomie(String mois) {
    return 'Ton épargne couvre désormais $mois mois de dépenses.';
  }
}
