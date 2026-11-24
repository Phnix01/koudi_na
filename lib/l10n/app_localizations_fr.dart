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
  String get annuler => 'Annuler';

  @override
  String get supprimer => 'Supprimer';

  @override
  String get modifier => 'Modifier';

  @override
  String get tous => 'Tous';

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
  String get aujourdHui => 'Aujourd\'hui';

  @override
  String get hier => 'Hier';

  @override
  String get transactionSupprimee => 'Transaction supprimée';

  @override
  String get categorieSupprimee => 'Catégorie supprimée';

  @override
  String get supprimerTransactionTitre => 'Supprimer cette transaction ?';

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
  String get soldeInitial => 'Solde initial';

  @override
  String get objectifEpargne => 'Objectif d\'épargne (optionnel)';

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
  String get montantChamp => 'Montant';

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
  String get exporterBouton => 'Exporter';

  @override
  String get periode => 'Période';

  @override
  String get periodeMoisCourant => 'Ce mois';

  @override
  String get periodeTout => 'Tout';

  @override
  String get periodePersonnalisee => 'Personnalisée';

  @override
  String get choisirDates => 'Choisir les dates';

  @override
  String plageDatesValeur(String debut, String fin) {
    return '$debut – $fin';
  }

  @override
  String get format => 'Format';

  @override
  String genereLe(String date) {
    return 'Généré le $date';
  }

  @override
  String get analyse => 'Analyse';

  @override
  String get trajectoireEpargne => 'Trajectoire d\'épargne';

  @override
  String get tauxEpargne => 'Taux d\'épargne';

  @override
  String get joursSansDepense => 'Jours sans dépense';

  @override
  String get projectionFinDeMois => 'Projection fin de mois';

  @override
  String get projectionDepasseEntrees =>
      'Au rythme actuel, tu dépasseras tes entrées ce mois-ci';

  @override
  String get pasAssezDonneesComparer => 'Pas assez de données pour comparer';

  @override
  String get pasAssezDonnees90Jours =>
      'Pas assez de données sur les 90 derniers jours';

  @override
  String get momentMatin => 'Matin';

  @override
  String get momentApresMidi => 'Aprèm';

  @override
  String get momentSoir => 'Soir';

  @override
  String get momentNuit => 'Nuit';

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

  @override
  String get onboardingSuivant => 'Continuer';

  @override
  String get onboardingCommencer => 'Noter ma première dépense';

  @override
  String get devise => 'Devise';

  @override
  String get deviseRechercher => 'Rechercher une devise';

  @override
  String get devisePrincipales => 'Principales';

  @override
  String get deviseToutes => 'Toutes les devises';

  @override
  String get deviseAucunResultat => 'Aucune devise trouvée';

  @override
  String get deviseObligatoireIndication => 'Choisis ta devise pour continuer';

  @override
  String get onboardingTitre1 => 'Sache où va chaque centime';

  @override
  String get onboardingCorps1 =>
      'Le pain, la moto, la recharge téléphone : ton argent part par petites sorties. Note-les dans Koudi Na et ton mois se lit centime par centime.';

  @override
  String get onboardingTitre2 => 'Un montant, une catégorie, c\'est noté';

  @override
  String onboardingCorps2(String montant) {
    return '$montant, Transport, enregistré : avant que le taxi redémarre. Cash, banque ou mobile money, chaque centime atterrit au bon endroit. Rien à ressaisir le soir.';
  }

  @override
  String get onboardingTitre3 => '40/25/35 : ton revenu déjà réparti';

  @override
  String get onboardingCorps3 =>
      'Épargne 40 %, Famille 25 %, Vie 35 % : la répartition est décidée d\'avance. Chaque barre compare le réel à l\'objectif. Un regard suffit, zéro calcul.';

  @override
  String get onboardingTitre4 => 'Tes chiffres restent dans ta poche';

  @override
  String get onboardingCorps4 =>
      'Tout vit sur ton téléphone, sans inscription ni serveur. Ça marche sans réseau, au marché comme au village. Toi seul lis tes chiffres. Ta première dépense t\'attend.';

  @override
  String get aPropos => 'À propos';

  @override
  String aProposVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aProposPolitiqueConfidentialite => 'Politique de confidentialité';

  @override
  String get aProposNousContacter => 'Nous contacter';

  @override
  String get aProposEditeur => 'Koudi Na est édité par XNOVA Systems.';

  @override
  String get aProposHorsLigne =>
      '100 % hors ligne : aucune donnée ne quitte votre téléphone, sauf export CSV initié par vous.';

  @override
  String get aProposLienIndisponible => 'Impossible d\'ouvrir ce lien.';

  @override
  String get notificationSectionTitre => 'Notifications';

  @override
  String get notificationRappelQuotidienTitre => 'Rappel quotidien';

  @override
  String get notificationRappelQuotidienSousTitre =>
      'Choisir une heure pour être rappelé d\'enregistrer ses dépenses.';

  @override
  String notificationRappelHeureChoisie(String heure) {
    return 'Actif à $heure';
  }

  @override
  String get notificationRecapHebdomadaireTitre => 'Récap hebdomadaire';

  @override
  String get notificationRecapHebdomadaireSousTitre =>
      'Un rappel chaque dimanche soir pour consulter le résumé de la semaine.';

  @override
  String get notificationPermissionRefusee =>
      'Notifications refusées. Autorisez-les dans les réglages du téléphone pour activer ce rappel.';

  @override
  String get notificationRappelNotifTitre => 'Koudi Na';

  @override
  String get notificationRappelNotifCorps =>
      'Pensez à enregistrer vos dépenses du jour.';

  @override
  String get notificationRecapNotifTitre => 'Koudi Na';

  @override
  String get notificationRecapNotifCorps =>
      'Votre résumé de la semaine est prêt, ouvrez l\'app pour le consulter.';

  @override
  String get notificationDepassementNotifTitre => 'Dépassement de budget';

  @override
  String notificationDepassementNotifCorps(String pilier) {
    return 'Le pilier $pilier dépasse son objectif ce mois-ci.';
  }

  @override
  String get badgesTitre => 'Badges';

  @override
  String get badgesEntreeReglages => 'Voir mes badges';

  @override
  String get badgesDeblocageTitre => 'Badge débloqué !';

  @override
  String get badgesDeblocageBouton => 'Continuer';

  @override
  String badgesProgression(int debloques, int total) {
    return '$debloques/$total badges débloqués';
  }

  @override
  String get astuceDuJourEtiquette => 'Astuce du jour';

  @override
  String serieInfobulle(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre jours de suite avec au moins une saisie',
      one: '1 jour de suite avec au moins une saisie',
    );
    return '$_temp0';
  }

  @override
  String get serieInfobulleVide =>
      'Note une dépense aujourd\'hui pour allumer ta série';

  @override
  String get didacticielSuivant => 'Suivant';

  @override
  String get didacticielTerminer => 'C\'est parti';

  @override
  String get didacticielPasser => 'Passer';

  @override
  String didacticielEtape(int numero, int total) {
    return '$numero/$total';
  }

  @override
  String get didacticielSoldeTitre => 'Ton solde du mois';

  @override
  String get didacticielSoldeTexte =>
      'Entrées moins dépenses du mois, mis à jour à chaque opération.';

  @override
  String get didacticielSerieTitre => 'Ta série';

  @override
  String get didacticielSerieTexte =>
      'Chaque jour où tu notes au moins une dépense, la flamme s\'allume et compte les jours. Touche-la pour voir où tu en es.';

  @override
  String get didacticielAnalyseTitre => 'Analyse';

  @override
  String get didacticielAnalyseTexte =>
      'Tes tendances sur 12 mois, la règle 40/25/35, une astuce par jour.';

  @override
  String get didacticielMoisTitre => 'Journal';

  @override
  String get didacticielMoisTexte =>
      'Toutes tes opérations, mois par mois, à rechercher, filtrer ou corriger.';

  @override
  String get didacticielReglagesTitre => 'Réglages';

  @override
  String get didacticielReglagesTexte =>
      'Langue, devise, rappels, badges, export de tes données. Tu peux aussi y revoir cette visite.';

  @override
  String get reglagesRevoirDidacticiel => 'Revoir la visite guidée';

  @override
  String get ongletAccueil => 'Accueil';

  @override
  String get ongletJournal => 'Journal';

  @override
  String get boutonAjouterSemantique => 'Ajouter une dépense ou une entrée';

  @override
  String get nouvelleOperation => 'Nouvelle opération';

  @override
  String get operationDepenseSousTitre => 'Repas, transport, data, famille…';

  @override
  String get operationEntreeSousTitre => 'Salaire, freelance, don reçu…';

  @override
  String get fermer => 'Fermer';

  @override
  String saisieDate(String date) {
    return 'Date : $date';
  }

  @override
  String get aujourdhui => 'Aujourd\'hui';

  @override
  String get saisieResteAvant => 'il te restera ';

  @override
  String get saisieResteApres => '';

  @override
  String get saisieNote => 'Note';

  @override
  String get saisieNoteAjouter => 'Ajouter une note';

  @override
  String get saisieNoteIndice => 'Ex. Déjeuner, taxi, marché…';

  @override
  String saisieEnregistrerMontant(String montant) {
    return 'Enregistrer $montant';
  }

  @override
  String get saisieEnregistrerModifs => 'Enregistrer les modifications';

  @override
  String get saisieMontantVide => 'Saisis un montant';

  @override
  String get saisieEffacer => 'Effacer le dernier chiffre';

  @override
  String get saisiePlus => 'Plus';

  @override
  String get saisieToutesCategories => 'Toutes les catégories';

  @override
  String get saisieDepenseEnregistree => 'Dépense enregistrée';

  @override
  String get saisieEntreeEnregistree => 'Entrée enregistrée';

  @override
  String get saisieOperationModifiee => 'Opération modifiée';

  @override
  String accueilRythmeDepense(int pourcent) {
    return '$pourcent % des entrées dépensées';
  }

  @override
  String accueilRythmeJour(int jour, int total) {
    return 'jour $jour / $total';
  }

  @override
  String get accueilEnAvance => 'tu es en avance';

  @override
  String get accueilAttentionRythme => 'attention au rythme';

  @override
  String get accueilMoisTermine => 'mois terminé';

  @override
  String get accueilFinDeMois => 'Fin de mois';

  @override
  String accueilSousEntrees(String montant) {
    return '$montant sous tes entrées';
  }

  @override
  String accueilAuDessusEntrees(String montant) {
    return '$montant au-dessus de tes entrées';
  }

  @override
  String get accueilSansEntree => 'pas encore d\'entrée';

  @override
  String get accueilMoyenneJour => 'Moyenne par jour';

  @override
  String accueilHorsEpargne(String montant) {
    return '$montant hors épargne';
  }

  @override
  String get accueilEnveloppes => 'Enveloppes';

  @override
  String get accueilReste => 'reste';

  @override
  String get accueilDepasseDe => 'dépassé de';

  @override
  String get accueilEnveloppesVide =>
      'Ajoute ta première entrée du mois pour activer la règle 40 · 25 · 35';

  @override
  String get accueilAjouterEntree => 'Ajouter une entrée';

  @override
  String get accueilRecents => 'Récents';

  @override
  String get toutVoir => 'Tout voir';

  @override
  String get accueilRecentsVide =>
      'Aucune opération ce mois-ci. Touche + pour commencer.';

  @override
  String get accueilChoisirMois => 'Choisir un mois';

  @override
  String serieJoursCourt(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get journalRechercher => 'Rechercher';

  @override
  String get journalRechercheIndice => 'Note, catégorie, compte, montant…';

  @override
  String get moisPrecedent => 'Mois précédent';

  @override
  String get moisSuivant => 'Mois suivant';

  @override
  String get filtreTout => 'Tout';

  @override
  String get filtres => 'Filtres';

  @override
  String get journalVide =>
      'Rien ce mois-ci. Touche + pour noter une opération.';

  @override
  String get journalAucunResultat => 'Aucun résultat';

  @override
  String get periodeMois => 'Mois';

  @override
  String get periode6Mois => '6 mois';

  @override
  String get periodeAnnee => 'Année';

  @override
  String get projectionSurtitre => 'Projection';

  @override
  String projectionEnCours(String mois) {
    return 'Au rythme actuel, tu termineras $mois à environ ';
  }

  @override
  String get projectionDeDepenses => ' de dépenses';

  @override
  String get projectionSoit => ', soit ';

  @override
  String projectionSansDepense(String mois) {
    return 'Aucune dépense en $mois pour l\'instant.';
  }

  @override
  String get entreesEtDepenses => 'Entrées et dépenses';

  @override
  String ouVaLArgent(String periode) {
    return 'Où va l\'argent · $periode';
  }

  @override
  String semaineCourte(int numero) {
    return 'S$numero';
  }

  @override
  String get analyseJoursCouteux => 'Les jours qui coûtent';

  @override
  String get analyseVide =>
      'Note quelques opérations pour voir tes tendances ici.';

  @override
  String get didacticielPlusTitre => 'Le bouton +';

  @override
  String get didacticielPlusTexte =>
      'Touche-le pour noter une dépense ou une entrée. Garde le doigt appuyé pour aller droit à une dépense.';
}
