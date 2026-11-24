import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitre.
  ///
  /// In fr, this message translates to:
  /// **'Koudi Na'**
  String get appTitre;

  /// No description provided for @enregistrer.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get enregistrer;

  /// No description provided for @annuler.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get annuler;

  /// No description provided for @supprimer.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get supprimer;

  /// No description provided for @modifier.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get modifier;

  /// No description provided for @tous.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get tous;

  /// No description provided for @aChoisir.
  ///
  /// In fr, this message translates to:
  /// **'À choisir'**
  String get aChoisir;

  /// No description provided for @nouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau'**
  String get nouveau;

  /// No description provided for @total.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @objectif.
  ///
  /// In fr, this message translates to:
  /// **'Objectif'**
  String get objectif;

  /// No description provided for @depense.
  ///
  /// In fr, this message translates to:
  /// **'Dépense'**
  String get depense;

  /// No description provided for @entree.
  ///
  /// In fr, this message translates to:
  /// **'Entrée'**
  String get entree;

  /// No description provided for @depenses.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses'**
  String get depenses;

  /// No description provided for @entrees.
  ///
  /// In fr, this message translates to:
  /// **'Entrées'**
  String get entrees;

  /// No description provided for @solde.
  ///
  /// In fr, this message translates to:
  /// **'Solde'**
  String get solde;

  /// No description provided for @soldeDuMois.
  ///
  /// In fr, this message translates to:
  /// **'Solde du mois'**
  String get soldeDuMois;

  /// No description provided for @type.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @categorie.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get categorie;

  /// No description provided for @categories.
  ///
  /// In fr, this message translates to:
  /// **'Catégories'**
  String get categories;

  /// No description provided for @compte.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get compte;

  /// No description provided for @comptes.
  ///
  /// In fr, this message translates to:
  /// **'Comptes'**
  String get comptes;

  /// No description provided for @recurrences.
  ///
  /// In fr, this message translates to:
  /// **'Récurrences'**
  String get recurrences;

  /// No description provided for @libelle.
  ///
  /// In fr, this message translates to:
  /// **'Libellé'**
  String get libelle;

  /// No description provided for @icone.
  ///
  /// In fr, this message translates to:
  /// **'Icône'**
  String get icone;

  /// No description provided for @couleur.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get couleur;

  /// No description provided for @pilierEpargne.
  ///
  /// In fr, this message translates to:
  /// **'Épargne'**
  String get pilierEpargne;

  /// No description provided for @pilierFamille.
  ///
  /// In fr, this message translates to:
  /// **'Famille'**
  String get pilierFamille;

  /// No description provided for @pilierVie.
  ///
  /// In fr, this message translates to:
  /// **'Vie'**
  String get pilierVie;

  /// No description provided for @pilierRegle.
  ///
  /// In fr, this message translates to:
  /// **'Pilier (règle 40/25/35)'**
  String get pilierRegle;

  /// No description provided for @typeCompteEspeces.
  ///
  /// In fr, this message translates to:
  /// **'Espèces'**
  String get typeCompteEspeces;

  /// No description provided for @typeCompteBanque.
  ///
  /// In fr, this message translates to:
  /// **'Banque'**
  String get typeCompteBanque;

  /// No description provided for @typeCompteMobileMoney.
  ///
  /// In fr, this message translates to:
  /// **'Mobile Money'**
  String get typeCompteMobileMoney;

  /// No description provided for @typeCompteEpargne.
  ///
  /// In fr, this message translates to:
  /// **'Épargne'**
  String get typeCompteEpargne;

  /// No description provided for @aujourdHui.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get aujourdHui;

  /// No description provided for @hier.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get hier;

  /// No description provided for @transactionSupprimee.
  ///
  /// In fr, this message translates to:
  /// **'Transaction supprimée'**
  String get transactionSupprimee;

  /// No description provided for @categorieSupprimee.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie supprimée'**
  String get categorieSupprimee;

  /// No description provided for @supprimerTransactionTitre.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette transaction ?'**
  String get supprimerTransactionTitre;

  /// No description provided for @desactivees.
  ///
  /// In fr, this message translates to:
  /// **'Désactivées'**
  String get desactivees;

  /// No description provided for @nouvelleCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle catégorie'**
  String get nouvelleCategorie;

  /// No description provided for @modifierCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la catégorie'**
  String get modifierCategorie;

  /// No description provided for @active.
  ///
  /// In fr, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @actif.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get actif;

  /// No description provided for @categorieDesactiveeExplication.
  ///
  /// In fr, this message translates to:
  /// **'Une catégorie désactivée disparaît de la saisie, sans effacer son historique'**
  String get categorieDesactiveeExplication;

  /// No description provided for @soldeInitialValeur.
  ///
  /// In fr, this message translates to:
  /// **'Solde initial : {montant}'**
  String soldeInitialValeur(String montant);

  /// No description provided for @nouveauCompte.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau compte'**
  String get nouveauCompte;

  /// No description provided for @modifierCompte.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le compte'**
  String get modifierCompte;

  /// No description provided for @soldeInitial.
  ///
  /// In fr, this message translates to:
  /// **'Solde initial'**
  String get soldeInitial;

  /// No description provided for @objectifEpargne.
  ///
  /// In fr, this message translates to:
  /// **'Objectif d\'épargne (optionnel)'**
  String get objectifEpargne;

  /// No description provided for @objectifEpargneAide.
  ///
  /// In fr, this message translates to:
  /// **'Utilisé comme ligne de repère dans le graphique « Trajectoire d\'épargne »'**
  String get objectifEpargneAide;

  /// No description provided for @compteDesactiveExplication.
  ///
  /// In fr, this message translates to:
  /// **'Un compte désactivé disparaît de la saisie, sans effacer son historique'**
  String get compteDesactiveExplication;

  /// No description provided for @aucuneRecurrence.
  ///
  /// In fr, this message translates to:
  /// **'Aucune récurrence pour l\'instant'**
  String get aucuneRecurrence;

  /// No description provided for @recurrenceSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'{categorie} · le {jour} de chaque mois'**
  String recurrenceSousTitre(String categorie, int jour);

  /// No description provided for @nouvelleRecurrence.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle récurrence'**
  String get nouvelleRecurrence;

  /// No description provided for @modifierRecurrence.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la récurrence'**
  String get modifierRecurrence;

  /// No description provided for @libelleExemple.
  ///
  /// In fr, this message translates to:
  /// **'Libellé (ex : Loyer, Salaire)'**
  String get libelleExemple;

  /// No description provided for @montantChamp.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get montantChamp;

  /// No description provided for @jourDuMois.
  ///
  /// In fr, this message translates to:
  /// **'Jour du mois (1-31)'**
  String get jourDuMois;

  /// No description provided for @recurrenceDesactiveeExplication.
  ///
  /// In fr, this message translates to:
  /// **'Une récurrence désactivée ne génère plus de transaction'**
  String get recurrenceDesactiveeExplication;

  /// No description provided for @reglages.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get reglages;

  /// No description provided for @donnees.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get donnees;

  /// No description provided for @export.
  ///
  /// In fr, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exportPartageTexte.
  ///
  /// In fr, this message translates to:
  /// **'Export Koudi Na — {nomFichier}'**
  String exportPartageTexte(String nomFichier);

  /// No description provided for @import.
  ///
  /// In fr, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @importerCsv.
  ///
  /// In fr, this message translates to:
  /// **'Importer un CSV'**
  String get importerCsv;

  /// No description provided for @importerCsvSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre un export Koudi Na (mêmes colonnes)'**
  String get importerCsvSousTitre;

  /// No description provided for @fichierIllisible.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de lire ce fichier.'**
  String get fichierIllisible;

  /// No description provided for @importerTitre.
  ///
  /// In fr, this message translates to:
  /// **'Importer ce fichier ?'**
  String get importerTitre;

  /// No description provided for @importResume.
  ///
  /// In fr, this message translates to:
  /// **'{nombre, plural, =0{Aucune transaction ne sera ajoutée.} =1{1 transaction sera ajoutée.} other{{nombre} transactions seront ajoutées.}}'**
  String importResume(int nombre);

  /// No description provided for @importIgnorees.
  ///
  /// In fr, this message translates to:
  /// **'{nombre, plural, =1{1 ligne ignorée (catégorie, compte ou montant introuvable).} other{{nombre} lignes ignorées (catégorie, compte ou montant introuvable).}}'**
  String importIgnorees(int nombre);

  /// No description provided for @importDoublonsAvertissement.
  ///
  /// In fr, this message translates to:
  /// **'Cet import ajoute ces transactions sans vérifier les doublons : réimporter le même fichier deux fois crée deux copies.'**
  String get importDoublonsAvertissement;

  /// No description provided for @importer.
  ///
  /// In fr, this message translates to:
  /// **'Importer'**
  String get importer;

  /// No description provided for @importTermine.
  ///
  /// In fr, this message translates to:
  /// **'{nombre, plural, =1{1 transaction importée.} other{{nombre} transactions importées.}}'**
  String importTermine(int nombre);

  /// No description provided for @langue.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get langue;

  /// No description provided for @langueSysteme.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get langueSysteme;

  /// No description provided for @exporterBouton.
  ///
  /// In fr, this message translates to:
  /// **'Exporter'**
  String get exporterBouton;

  /// No description provided for @periode.
  ///
  /// In fr, this message translates to:
  /// **'Période'**
  String get periode;

  /// No description provided for @periodeMoisCourant.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois'**
  String get periodeMoisCourant;

  /// No description provided for @periodeTout.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get periodeTout;

  /// No description provided for @periodePersonnalisee.
  ///
  /// In fr, this message translates to:
  /// **'Personnalisée'**
  String get periodePersonnalisee;

  /// No description provided for @choisirDates.
  ///
  /// In fr, this message translates to:
  /// **'Choisir les dates'**
  String get choisirDates;

  /// No description provided for @plageDatesValeur.
  ///
  /// In fr, this message translates to:
  /// **'{debut} – {fin}'**
  String plageDatesValeur(String debut, String fin);

  /// No description provided for @format.
  ///
  /// In fr, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @genereLe.
  ///
  /// In fr, this message translates to:
  /// **'Généré le {date}'**
  String genereLe(String date);

  /// No description provided for @analyse.
  ///
  /// In fr, this message translates to:
  /// **'Analyse'**
  String get analyse;

  /// No description provided for @trajectoireEpargne.
  ///
  /// In fr, this message translates to:
  /// **'Trajectoire d\'épargne'**
  String get trajectoireEpargne;

  /// No description provided for @tauxEpargne.
  ///
  /// In fr, this message translates to:
  /// **'Taux d\'épargne'**
  String get tauxEpargne;

  /// No description provided for @joursSansDepense.
  ///
  /// In fr, this message translates to:
  /// **'Jours sans dépense'**
  String get joursSansDepense;

  /// No description provided for @projectionFinDeMois.
  ///
  /// In fr, this message translates to:
  /// **'Projection fin de mois'**
  String get projectionFinDeMois;

  /// No description provided for @projectionDepasseEntrees.
  ///
  /// In fr, this message translates to:
  /// **'Au rythme actuel, tu dépasseras tes entrées ce mois-ci'**
  String get projectionDepasseEntrees;

  /// No description provided for @pasAssezDonneesComparer.
  ///
  /// In fr, this message translates to:
  /// **'Pas assez de données pour comparer'**
  String get pasAssezDonneesComparer;

  /// No description provided for @pasAssezDonnees90Jours.
  ///
  /// In fr, this message translates to:
  /// **'Pas assez de données sur les 90 derniers jours'**
  String get pasAssezDonnees90Jours;

  /// No description provided for @momentMatin.
  ///
  /// In fr, this message translates to:
  /// **'Matin'**
  String get momentMatin;

  /// No description provided for @momentApresMidi.
  ///
  /// In fr, this message translates to:
  /// **'Aprèm'**
  String get momentApresMidi;

  /// No description provided for @momentSoir.
  ///
  /// In fr, this message translates to:
  /// **'Soir'**
  String get momentSoir;

  /// No description provided for @momentNuit.
  ///
  /// In fr, this message translates to:
  /// **'Nuit'**
  String get momentNuit;

  /// No description provided for @obsHausse.
  ///
  /// In fr, this message translates to:
  /// **'Tes dépenses en {categorie} ont augmenté de {pourcent} % ce mois-ci.'**
  String obsHausse(String categorie, int pourcent);

  /// No description provided for @obsDepassement.
  ///
  /// In fr, this message translates to:
  /// **'Au rythme actuel, tu dépasseras tes entrées de {montant} d\'ici la fin du mois.'**
  String obsDepassement(String montant);

  /// No description provided for @obsObjectifEpargne.
  ///
  /// In fr, this message translates to:
  /// **'{mois, plural, other{Tu as respecté ton objectif d\'épargne {mois} mois de suite.}}'**
  String obsObjectifEpargne(int mois);

  /// No description provided for @obsAutonomie.
  ///
  /// In fr, this message translates to:
  /// **'Ton épargne couvre désormais {mois} mois de dépenses.'**
  String obsAutonomie(String mois);

  /// No description provided for @onboardingSuivant.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get onboardingSuivant;

  /// No description provided for @onboardingCommencer.
  ///
  /// In fr, this message translates to:
  /// **'Noter ma première dépense'**
  String get onboardingCommencer;

  /// No description provided for @devise.
  ///
  /// In fr, this message translates to:
  /// **'Devise'**
  String get devise;

  /// No description provided for @deviseRechercher.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une devise'**
  String get deviseRechercher;

  /// No description provided for @devisePrincipales.
  ///
  /// In fr, this message translates to:
  /// **'Principales'**
  String get devisePrincipales;

  /// No description provided for @deviseToutes.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les devises'**
  String get deviseToutes;

  /// No description provided for @deviseAucunResultat.
  ///
  /// In fr, this message translates to:
  /// **'Aucune devise trouvée'**
  String get deviseAucunResultat;

  /// No description provided for @deviseObligatoireIndication.
  ///
  /// In fr, this message translates to:
  /// **'Choisis ta devise pour continuer'**
  String get deviseObligatoireIndication;

  /// No description provided for @onboardingTitre1.
  ///
  /// In fr, this message translates to:
  /// **'Sache où va chaque centime'**
  String get onboardingTitre1;

  /// No description provided for @onboardingCorps1.
  ///
  /// In fr, this message translates to:
  /// **'Le pain, la moto, la recharge téléphone : ton argent part par petites sorties. Note-les dans Koudi Na et ton mois se lit centime par centime.'**
  String get onboardingCorps1;

  /// No description provided for @onboardingTitre2.
  ///
  /// In fr, this message translates to:
  /// **'Un montant, une catégorie, c\'est noté'**
  String get onboardingTitre2;

  /// No description provided for @onboardingCorps2.
  ///
  /// In fr, this message translates to:
  /// **'{montant}, Transport, enregistré : avant que le taxi redémarre. Cash, banque ou mobile money, chaque centime atterrit au bon endroit. Rien à ressaisir le soir.'**
  String onboardingCorps2(String montant);

  /// No description provided for @onboardingTitre3.
  ///
  /// In fr, this message translates to:
  /// **'40/25/35 : ton revenu déjà réparti'**
  String get onboardingTitre3;

  /// No description provided for @onboardingCorps3.
  ///
  /// In fr, this message translates to:
  /// **'Épargne 40 %, Famille 25 %, Vie 35 % : la répartition est décidée d\'avance. Chaque barre compare le réel à l\'objectif. Un regard suffit, zéro calcul.'**
  String get onboardingCorps3;

  /// No description provided for @onboardingTitre4.
  ///
  /// In fr, this message translates to:
  /// **'Tes chiffres restent dans ta poche'**
  String get onboardingTitre4;

  /// No description provided for @onboardingCorps4.
  ///
  /// In fr, this message translates to:
  /// **'Tout vit sur ton téléphone, sans inscription ni serveur. Ça marche sans réseau, au marché comme au village. Toi seul lis tes chiffres. Ta première dépense t\'attend.'**
  String get onboardingCorps4;

  /// No description provided for @aPropos.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get aPropos;

  /// No description provided for @aProposVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String aProposVersion(String version);

  /// No description provided for @aProposPolitiqueConfidentialite.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get aProposPolitiqueConfidentialite;

  /// No description provided for @aProposNousContacter.
  ///
  /// In fr, this message translates to:
  /// **'Nous contacter'**
  String get aProposNousContacter;

  /// No description provided for @aProposEditeur.
  ///
  /// In fr, this message translates to:
  /// **'Koudi Na est édité par XNOVA Systems.'**
  String get aProposEditeur;

  /// No description provided for @aProposHorsLigne.
  ///
  /// In fr, this message translates to:
  /// **'100 % hors ligne : aucune donnée ne quitte votre téléphone, sauf export CSV initié par vous.'**
  String get aProposHorsLigne;

  /// No description provided for @aProposLienIndisponible.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir ce lien.'**
  String get aProposLienIndisponible;

  /// No description provided for @notificationSectionTitre.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationSectionTitre;

  /// No description provided for @notificationRappelQuotidienTitre.
  ///
  /// In fr, this message translates to:
  /// **'Rappel quotidien'**
  String get notificationRappelQuotidienTitre;

  /// No description provided for @notificationRappelQuotidienSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une heure pour être rappelé d\'enregistrer ses dépenses.'**
  String get notificationRappelQuotidienSousTitre;

  /// No description provided for @notificationRappelHeureChoisie.
  ///
  /// In fr, this message translates to:
  /// **'Actif à {heure}'**
  String notificationRappelHeureChoisie(String heure);

  /// No description provided for @notificationRecapHebdomadaireTitre.
  ///
  /// In fr, this message translates to:
  /// **'Récap hebdomadaire'**
  String get notificationRecapHebdomadaireTitre;

  /// No description provided for @notificationRecapHebdomadaireSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Un rappel chaque dimanche soir pour consulter le résumé de la semaine.'**
  String get notificationRecapHebdomadaireSousTitre;

  /// No description provided for @notificationPermissionRefusee.
  ///
  /// In fr, this message translates to:
  /// **'Notifications refusées. Autorisez-les dans les réglages du téléphone pour activer ce rappel.'**
  String get notificationPermissionRefusee;

  /// No description provided for @notificationRappelNotifTitre.
  ///
  /// In fr, this message translates to:
  /// **'Koudi Na'**
  String get notificationRappelNotifTitre;

  /// No description provided for @notificationRappelNotifCorps.
  ///
  /// In fr, this message translates to:
  /// **'Pensez à enregistrer vos dépenses du jour.'**
  String get notificationRappelNotifCorps;

  /// No description provided for @notificationRecapNotifTitre.
  ///
  /// In fr, this message translates to:
  /// **'Koudi Na'**
  String get notificationRecapNotifTitre;

  /// No description provided for @notificationRecapNotifCorps.
  ///
  /// In fr, this message translates to:
  /// **'Votre résumé de la semaine est prêt, ouvrez l\'app pour le consulter.'**
  String get notificationRecapNotifCorps;

  /// No description provided for @notificationDepassementNotifTitre.
  ///
  /// In fr, this message translates to:
  /// **'Dépassement de budget'**
  String get notificationDepassementNotifTitre;

  /// No description provided for @notificationDepassementNotifCorps.
  ///
  /// In fr, this message translates to:
  /// **'Le pilier {pilier} dépasse son objectif ce mois-ci.'**
  String notificationDepassementNotifCorps(String pilier);

  /// No description provided for @badgesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Badges'**
  String get badgesTitre;

  /// No description provided for @badgesEntreeReglages.
  ///
  /// In fr, this message translates to:
  /// **'Voir mes badges'**
  String get badgesEntreeReglages;

  /// No description provided for @badgesDeblocageTitre.
  ///
  /// In fr, this message translates to:
  /// **'Badge débloqué !'**
  String get badgesDeblocageTitre;

  /// No description provided for @badgesDeblocageBouton.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get badgesDeblocageBouton;

  /// No description provided for @badgesProgression.
  ///
  /// In fr, this message translates to:
  /// **'{debloques}/{total} badges débloqués'**
  String badgesProgression(int debloques, int total);

  /// No description provided for @astuceDuJourEtiquette.
  ///
  /// In fr, this message translates to:
  /// **'Astuce du jour'**
  String get astuceDuJourEtiquette;

  /// No description provided for @serieInfobulle.
  ///
  /// In fr, this message translates to:
  /// **'{nombre, plural, =1{1 jour de suite avec au moins une saisie} other{{nombre} jours de suite avec au moins une saisie}}'**
  String serieInfobulle(int nombre);

  /// No description provided for @serieInfobulleVide.
  ///
  /// In fr, this message translates to:
  /// **'Note une dépense aujourd\'hui pour allumer ta série'**
  String get serieInfobulleVide;

  /// No description provided for @didacticielSuivant.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get didacticielSuivant;

  /// No description provided for @didacticielTerminer.
  ///
  /// In fr, this message translates to:
  /// **'C\'est parti'**
  String get didacticielTerminer;

  /// No description provided for @didacticielPasser.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get didacticielPasser;

  /// No description provided for @didacticielEtape.
  ///
  /// In fr, this message translates to:
  /// **'{numero}/{total}'**
  String didacticielEtape(int numero, int total);

  /// No description provided for @didacticielSoldeTitre.
  ///
  /// In fr, this message translates to:
  /// **'Ton solde du mois'**
  String get didacticielSoldeTitre;

  /// No description provided for @didacticielSoldeTexte.
  ///
  /// In fr, this message translates to:
  /// **'Entrées moins dépenses du mois, mis à jour à chaque opération.'**
  String get didacticielSoldeTexte;

  /// No description provided for @didacticielSerieTitre.
  ///
  /// In fr, this message translates to:
  /// **'Ta série'**
  String get didacticielSerieTitre;

  /// No description provided for @didacticielSerieTexte.
  ///
  /// In fr, this message translates to:
  /// **'Chaque jour où tu notes au moins une dépense, la flamme s\'allume et compte les jours. Touche-la pour voir où tu en es.'**
  String get didacticielSerieTexte;

  /// No description provided for @didacticielAnalyseTitre.
  ///
  /// In fr, this message translates to:
  /// **'Analyse'**
  String get didacticielAnalyseTitre;

  /// No description provided for @didacticielAnalyseTexte.
  ///
  /// In fr, this message translates to:
  /// **'Tes tendances sur 12 mois, la règle 40/25/35, une astuce par jour.'**
  String get didacticielAnalyseTexte;

  /// No description provided for @didacticielMoisTitre.
  ///
  /// In fr, this message translates to:
  /// **'Journal'**
  String get didacticielMoisTitre;

  /// No description provided for @didacticielMoisTexte.
  ///
  /// In fr, this message translates to:
  /// **'Toutes tes opérations, mois par mois, à rechercher, filtrer ou corriger.'**
  String get didacticielMoisTexte;

  /// No description provided for @didacticielReglagesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get didacticielReglagesTitre;

  /// No description provided for @didacticielReglagesTexte.
  ///
  /// In fr, this message translates to:
  /// **'Langue, devise, rappels, badges, export de tes données. Tu peux aussi y revoir cette visite.'**
  String get didacticielReglagesTexte;

  /// No description provided for @reglagesRevoirDidacticiel.
  ///
  /// In fr, this message translates to:
  /// **'Revoir la visite guidée'**
  String get reglagesRevoirDidacticiel;

  /// No description provided for @ongletAccueil.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get ongletAccueil;

  /// No description provided for @ongletJournal.
  ///
  /// In fr, this message translates to:
  /// **'Journal'**
  String get ongletJournal;

  /// No description provided for @boutonAjouterSemantique.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une dépense ou une entrée'**
  String get boutonAjouterSemantique;

  /// No description provided for @nouvelleOperation.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle opération'**
  String get nouvelleOperation;

  /// No description provided for @operationDepenseSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Repas, transport, data, famille…'**
  String get operationDepenseSousTitre;

  /// No description provided for @operationEntreeSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Salaire, freelance, don reçu…'**
  String get operationEntreeSousTitre;

  /// No description provided for @fermer.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get fermer;

  /// No description provided for @saisieDate.
  ///
  /// In fr, this message translates to:
  /// **'Date : {date}'**
  String saisieDate(String date);

  /// No description provided for @aujourdhui.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get aujourdhui;

  /// No description provided for @saisieResteAvant.
  ///
  /// In fr, this message translates to:
  /// **'il te restera '**
  String get saisieResteAvant;

  /// No description provided for @saisieResteApres.
  ///
  /// In fr, this message translates to:
  /// **''**
  String get saisieResteApres;

  /// No description provided for @saisieNote.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get saisieNote;

  /// No description provided for @saisieNoteAjouter.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une note'**
  String get saisieNoteAjouter;

  /// No description provided for @saisieNoteIndice.
  ///
  /// In fr, this message translates to:
  /// **'Ex. Déjeuner, taxi, marché…'**
  String get saisieNoteIndice;

  /// No description provided for @saisieEnregistrerMontant.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer {montant}'**
  String saisieEnregistrerMontant(String montant);

  /// No description provided for @saisieEnregistrerModifs.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les modifications'**
  String get saisieEnregistrerModifs;

  /// No description provided for @saisieMontantVide.
  ///
  /// In fr, this message translates to:
  /// **'Saisis un montant'**
  String get saisieMontantVide;

  /// No description provided for @saisieEffacer.
  ///
  /// In fr, this message translates to:
  /// **'Effacer le dernier chiffre'**
  String get saisieEffacer;

  /// No description provided for @saisiePlus.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get saisiePlus;

  /// No description provided for @saisieToutesCategories.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les catégories'**
  String get saisieToutesCategories;

  /// No description provided for @saisieDepenseEnregistree.
  ///
  /// In fr, this message translates to:
  /// **'Dépense enregistrée'**
  String get saisieDepenseEnregistree;

  /// No description provided for @saisieEntreeEnregistree.
  ///
  /// In fr, this message translates to:
  /// **'Entrée enregistrée'**
  String get saisieEntreeEnregistree;

  /// No description provided for @saisieOperationModifiee.
  ///
  /// In fr, this message translates to:
  /// **'Opération modifiée'**
  String get saisieOperationModifiee;

  /// No description provided for @accueilRythmeDepense.
  ///
  /// In fr, this message translates to:
  /// **'{pourcent} % des entrées dépensées'**
  String accueilRythmeDepense(int pourcent);

  /// No description provided for @accueilRythmeJour.
  ///
  /// In fr, this message translates to:
  /// **'jour {jour} / {total}'**
  String accueilRythmeJour(int jour, int total);

  /// No description provided for @accueilEnAvance.
  ///
  /// In fr, this message translates to:
  /// **'tu es en avance'**
  String get accueilEnAvance;

  /// No description provided for @accueilAttentionRythme.
  ///
  /// In fr, this message translates to:
  /// **'attention au rythme'**
  String get accueilAttentionRythme;

  /// No description provided for @accueilMoisTermine.
  ///
  /// In fr, this message translates to:
  /// **'mois terminé'**
  String get accueilMoisTermine;

  /// No description provided for @accueilFinDeMois.
  ///
  /// In fr, this message translates to:
  /// **'Fin de mois'**
  String get accueilFinDeMois;

  /// No description provided for @accueilSousEntrees.
  ///
  /// In fr, this message translates to:
  /// **'{montant} sous tes entrées'**
  String accueilSousEntrees(String montant);

  /// No description provided for @accueilAuDessusEntrees.
  ///
  /// In fr, this message translates to:
  /// **'{montant} au-dessus de tes entrées'**
  String accueilAuDessusEntrees(String montant);

  /// No description provided for @accueilSansEntree.
  ///
  /// In fr, this message translates to:
  /// **'pas encore d\'entrée'**
  String get accueilSansEntree;

  /// No description provided for @accueilMoyenneJour.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne par jour'**
  String get accueilMoyenneJour;

  /// No description provided for @accueilHorsEpargne.
  ///
  /// In fr, this message translates to:
  /// **'{montant} hors épargne'**
  String accueilHorsEpargne(String montant);

  /// No description provided for @accueilEnveloppes.
  ///
  /// In fr, this message translates to:
  /// **'Enveloppes'**
  String get accueilEnveloppes;

  /// No description provided for @accueilReste.
  ///
  /// In fr, this message translates to:
  /// **'reste'**
  String get accueilReste;

  /// No description provided for @accueilDepasseDe.
  ///
  /// In fr, this message translates to:
  /// **'dépassé de'**
  String get accueilDepasseDe;

  /// No description provided for @accueilEnveloppesVide.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute ta première entrée du mois pour activer la règle 40 · 25 · 35'**
  String get accueilEnveloppesVide;

  /// No description provided for @accueilAjouterEntree.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une entrée'**
  String get accueilAjouterEntree;

  /// No description provided for @accueilRecents.
  ///
  /// In fr, this message translates to:
  /// **'Récents'**
  String get accueilRecents;

  /// No description provided for @toutVoir.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get toutVoir;

  /// No description provided for @accueilRecentsVide.
  ///
  /// In fr, this message translates to:
  /// **'Aucune opération ce mois-ci. Touche + pour commencer.'**
  String get accueilRecentsVide;

  /// No description provided for @accueilChoisirMois.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un mois'**
  String get accueilChoisirMois;

  /// No description provided for @serieJoursCourt.
  ///
  /// In fr, this message translates to:
  /// **'{nombre, plural, =1{1 jour} other{{nombre} jours}}'**
  String serieJoursCourt(int nombre);

  /// No description provided for @journalRechercher.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get journalRechercher;

  /// No description provided for @journalRechercheIndice.
  ///
  /// In fr, this message translates to:
  /// **'Note, catégorie, compte, montant…'**
  String get journalRechercheIndice;

  /// No description provided for @moisPrecedent.
  ///
  /// In fr, this message translates to:
  /// **'Mois précédent'**
  String get moisPrecedent;

  /// No description provided for @moisSuivant.
  ///
  /// In fr, this message translates to:
  /// **'Mois suivant'**
  String get moisSuivant;

  /// No description provided for @filtreTout.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get filtreTout;

  /// No description provided for @filtres.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get filtres;

  /// No description provided for @journalVide.
  ///
  /// In fr, this message translates to:
  /// **'Rien ce mois-ci. Touche + pour noter une opération.'**
  String get journalVide;

  /// No description provided for @journalAucunResultat.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get journalAucunResultat;

  /// No description provided for @periodeMois.
  ///
  /// In fr, this message translates to:
  /// **'Mois'**
  String get periodeMois;

  /// No description provided for @periode6Mois.
  ///
  /// In fr, this message translates to:
  /// **'6 mois'**
  String get periode6Mois;

  /// No description provided for @periodeAnnee.
  ///
  /// In fr, this message translates to:
  /// **'Année'**
  String get periodeAnnee;

  /// No description provided for @projectionSurtitre.
  ///
  /// In fr, this message translates to:
  /// **'Projection'**
  String get projectionSurtitre;

  /// No description provided for @projectionEnCours.
  ///
  /// In fr, this message translates to:
  /// **'Au rythme actuel, tu termineras {mois} à environ '**
  String projectionEnCours(String mois);

  /// No description provided for @projectionDeDepenses.
  ///
  /// In fr, this message translates to:
  /// **' de dépenses'**
  String get projectionDeDepenses;

  /// No description provided for @projectionSoit.
  ///
  /// In fr, this message translates to:
  /// **', soit '**
  String get projectionSoit;

  /// No description provided for @projectionSansDepense.
  ///
  /// In fr, this message translates to:
  /// **'Aucune dépense en {mois} pour l\'instant.'**
  String projectionSansDepense(String mois);

  /// No description provided for @entreesEtDepenses.
  ///
  /// In fr, this message translates to:
  /// **'Entrées et dépenses'**
  String get entreesEtDepenses;

  /// No description provided for @ouVaLArgent.
  ///
  /// In fr, this message translates to:
  /// **'Où va l\'argent · {periode}'**
  String ouVaLArgent(String periode);

  /// No description provided for @semaineCourte.
  ///
  /// In fr, this message translates to:
  /// **'S{numero}'**
  String semaineCourte(int numero);

  /// No description provided for @analyseJoursCouteux.
  ///
  /// In fr, this message translates to:
  /// **'Les jours qui coûtent'**
  String get analyseJoursCouteux;

  /// No description provided for @analyseVide.
  ///
  /// In fr, this message translates to:
  /// **'Note quelques opérations pour voir tes tendances ici.'**
  String get analyseVide;

  /// No description provided for @didacticielPlusTitre.
  ///
  /// In fr, this message translates to:
  /// **'Le bouton +'**
  String get didacticielPlusTitre;

  /// No description provided for @didacticielPlusTexte.
  ///
  /// In fr, this message translates to:
  /// **'Touche-le pour noter une dépense ou une entrée. Garde le doigt appuyé pour aller droit à une dépense.'**
  String get didacticielPlusTexte;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
