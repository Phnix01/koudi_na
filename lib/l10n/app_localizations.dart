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

  /// No description provided for @enregistrerModifications.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les modifications'**
  String get enregistrerModifications;

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

  /// No description provided for @reinitialiser.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get reinitialiser;

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

  /// No description provided for @regle402535.
  ///
  /// In fr, this message translates to:
  /// **'Règle 40/25/35'**
  String get regle402535;

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

  /// No description provided for @tooltipAnalyse.
  ///
  /// In fr, this message translates to:
  /// **'Analyse'**
  String get tooltipAnalyse;

  /// No description provided for @tooltipVoirLeMois.
  ///
  /// In fr, this message translates to:
  /// **'Voir le mois'**
  String get tooltipVoirLeMois;

  /// No description provided for @tooltipReglages.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get tooltipReglages;

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

  /// No description provided for @aucuneTransactionFiltres.
  ///
  /// In fr, this message translates to:
  /// **'Aucune transaction pour ces filtres'**
  String get aucuneTransactionFiltres;

  /// No description provided for @aucuneTransactionMois.
  ///
  /// In fr, this message translates to:
  /// **'Aucune transaction ce mois-ci'**
  String get aucuneTransactionMois;

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

  /// No description provided for @compteSupprime.
  ///
  /// In fr, this message translates to:
  /// **'Compte supprimé'**
  String get compteSupprime;

  /// No description provided for @supprimerTransactionTitre.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette transaction ?'**
  String get supprimerTransactionTitre;

  /// No description provided for @actionIrreversible.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible.'**
  String get actionIrreversible;

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

  /// No description provided for @soldeInitialFcfa.
  ///
  /// In fr, this message translates to:
  /// **'Solde initial (FCFA)'**
  String get soldeInitialFcfa;

  /// No description provided for @objectifEpargneFcfa.
  ///
  /// In fr, this message translates to:
  /// **'Objectif d\'épargne (FCFA, optionnel)'**
  String get objectifEpargneFcfa;

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

  /// No description provided for @montantFcfa.
  ///
  /// In fr, this message translates to:
  /// **'Montant (FCFA)'**
  String get montantFcfa;

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

  /// No description provided for @exporterMoisCourant.
  ///
  /// In fr, this message translates to:
  /// **'Exporter le mois courant'**
  String get exporterMoisCourant;

  /// No description provided for @exporterTout.
  ///
  /// In fr, this message translates to:
  /// **'Exporter toutes les transactions'**
  String get exporterTout;

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

  /// No description provided for @analyse.
  ///
  /// In fr, this message translates to:
  /// **'Analyse'**
  String get analyse;

  /// No description provided for @evolution12Mois.
  ///
  /// In fr, this message translates to:
  /// **'Évolution sur 12 mois'**
  String get evolution12Mois;

  /// No description provided for @repartitionDepensesMois.
  ///
  /// In fr, this message translates to:
  /// **'Répartition des dépenses (ce mois)'**
  String get repartitionDepensesMois;

  /// No description provided for @top5Titre.
  ///
  /// In fr, this message translates to:
  /// **'Top 5 des catégories (ce mois vs le mois dernier)'**
  String get top5Titre;

  /// No description provided for @moisDernier.
  ///
  /// In fr, this message translates to:
  /// **'Mois dernier'**
  String get moisDernier;

  /// No description provided for @ceMoisCouleurCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois : couleur de la catégorie'**
  String get ceMoisCouleurCategorie;

  /// No description provided for @rythmeDuMois.
  ///
  /// In fr, this message translates to:
  /// **'Rythme du mois'**
  String get rythmeDuMois;

  /// No description provided for @habitudesHebdo90.
  ///
  /// In fr, this message translates to:
  /// **'Habitudes hebdomadaires (90 derniers jours)'**
  String get habitudesHebdo90;

  /// No description provided for @trajectoireEpargne.
  ///
  /// In fr, this message translates to:
  /// **'Trajectoire d\'épargne'**
  String get trajectoireEpargne;

  /// No description provided for @aucunObjectifRegle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun objectif réglé : ouvre Réglages → Comptes → ton compte Épargne pour en fixer un.'**
  String get aucunObjectifRegle;

  /// No description provided for @equilibrePiliers6Mois.
  ///
  /// In fr, this message translates to:
  /// **'Équilibre des piliers (6 mois)'**
  String get equilibrePiliers6Mois;

  /// No description provided for @autonomieFinanciere.
  ///
  /// In fr, this message translates to:
  /// **'Autonomie financière'**
  String get autonomieFinanciere;

  /// No description provided for @autonomieValeur.
  ///
  /// In fr, this message translates to:
  /// **'{mois} mois'**
  String autonomieValeur(String mois);

  /// No description provided for @autonomieDescription.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de mois de dépenses moyennes que couvre ton épargne actuelle'**
  String get autonomieDescription;

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

  /// No description provided for @depenseMoyJourMois.
  ///
  /// In fr, this message translates to:
  /// **'Dépense moy. / jour (ce mois)'**
  String get depenseMoyJourMois;

  /// No description provided for @depenseMoyJourHistorique.
  ///
  /// In fr, this message translates to:
  /// **'Dépense moy. / jour (historique)'**
  String get depenseMoyJourHistorique;

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

  /// No description provided for @pasAssezDonnees.
  ///
  /// In fr, this message translates to:
  /// **'Pas assez de données'**
  String get pasAssezDonnees;

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

  /// No description provided for @aucuneDepenseMois.
  ///
  /// In fr, this message translates to:
  /// **'Aucune dépense ce mois-ci'**
  String get aucuneDepenseMois;

  /// No description provided for @entreesDuMois.
  ///
  /// In fr, this message translates to:
  /// **'Entrées du mois'**
  String get entreesDuMois;

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

  /// No description provided for @retirerNote.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la note'**
  String get retirerNote;

  /// No description provided for @ajouterNote.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une note'**
  String get ajouterNote;

  /// No description provided for @noteOptionnelle.
  ///
  /// In fr, this message translates to:
  /// **'Note (optionnel)'**
  String get noteOptionnelle;

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

  /// No description provided for @onboardingPasser.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get onboardingPasser;

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

  /// No description provided for @onboardingTitre1.
  ///
  /// In fr, this message translates to:
  /// **'Sache où va chaque franc'**
  String get onboardingTitre1;

  /// No description provided for @onboardingCorps1.
  ///
  /// In fr, this message translates to:
  /// **'Le pain, la moto, la recharge téléphone : ton argent part par petites sorties. Note-les dans Koudi Na et ton mois se lit franc par franc.'**
  String get onboardingCorps1;

  /// No description provided for @onboardingTitre2.
  ///
  /// In fr, this message translates to:
  /// **'Un montant, une catégorie, c\'est noté'**
  String get onboardingTitre2;

  /// No description provided for @onboardingCorps2.
  ///
  /// In fr, this message translates to:
  /// **'2 500 F, Transport, enregistré : avant que le taxi redémarre. Cash, banque ou mobile money, chaque franc atterrit au bon endroit. Rien à ressaisir le soir.'**
  String get onboardingCorps2;

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
