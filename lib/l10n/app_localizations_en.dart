// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitre => 'Koudi Na';

  @override
  String get enregistrer => 'Save';

  @override
  String get annuler => 'Cancel';

  @override
  String get supprimer => 'Delete';

  @override
  String get modifier => 'Edit';

  @override
  String get tous => 'All';

  @override
  String get aChoisir => 'Choose';

  @override
  String get nouveau => 'New';

  @override
  String get total => 'Total';

  @override
  String get objectif => 'Goal';

  @override
  String get depense => 'Expense';

  @override
  String get entree => 'Income';

  @override
  String get depenses => 'Expenses';

  @override
  String get entrees => 'Income';

  @override
  String get solde => 'Balance';

  @override
  String get soldeDuMois => 'This month\'s balance';

  @override
  String get type => 'Type';

  @override
  String get categorie => 'Category';

  @override
  String get categories => 'Categories';

  @override
  String get compte => 'Account';

  @override
  String get comptes => 'Accounts';

  @override
  String get recurrences => 'Recurring';

  @override
  String get libelle => 'Name';

  @override
  String get icone => 'Icon';

  @override
  String get couleur => 'Color';

  @override
  String get pilierEpargne => 'Savings';

  @override
  String get pilierFamille => 'Family';

  @override
  String get pilierVie => 'Living';

  @override
  String get pilierRegle => 'Pillar (40/25/35 rule)';

  @override
  String get typeCompteEspeces => 'Cash';

  @override
  String get typeCompteBanque => 'Bank';

  @override
  String get typeCompteMobileMoney => 'Mobile Money';

  @override
  String get typeCompteEpargne => 'Savings';

  @override
  String get aujourdHui => 'Today';

  @override
  String get hier => 'Yesterday';

  @override
  String get transactionSupprimee => 'Transaction deleted';

  @override
  String get categorieSupprimee => 'Deleted category';

  @override
  String get supprimerTransactionTitre => 'Delete this transaction?';

  @override
  String get desactivees => 'Disabled';

  @override
  String get nouvelleCategorie => 'New category';

  @override
  String get modifierCategorie => 'Edit category';

  @override
  String get active => 'Enabled';

  @override
  String get actif => 'Enabled';

  @override
  String get categorieDesactiveeExplication =>
      'A disabled category is hidden when adding transactions, but its history is kept';

  @override
  String soldeInitialValeur(String montant) {
    return 'Opening balance: $montant';
  }

  @override
  String get nouveauCompte => 'New account';

  @override
  String get modifierCompte => 'Edit account';

  @override
  String get soldeInitial => 'Opening balance';

  @override
  String get objectifEpargne => 'Savings goal (optional)';

  @override
  String get objectifEpargneAide =>
      'Shown as a reference line in the \"Savings trajectory\" chart';

  @override
  String get compteDesactiveExplication =>
      'A disabled account is hidden when adding transactions, but its history is kept';

  @override
  String get aucuneRecurrence => 'No recurring transactions yet';

  @override
  String recurrenceSousTitre(String categorie, int jour) {
    return '$categorie · on the $jour of each month';
  }

  @override
  String get nouvelleRecurrence => 'New recurring transaction';

  @override
  String get modifierRecurrence => 'Edit recurring transaction';

  @override
  String get libelleExemple => 'Name (e.g. Rent, Salary)';

  @override
  String get montantChamp => 'Amount';

  @override
  String get jourDuMois => 'Day of month (1-31)';

  @override
  String get recurrenceDesactiveeExplication =>
      'A disabled recurring transaction no longer generates anything';

  @override
  String get reglages => 'Settings';

  @override
  String get donnees => 'Data';

  @override
  String get export => 'Export';

  @override
  String exportPartageTexte(String nomFichier) {
    return 'Koudi Na export — $nomFichier';
  }

  @override
  String get import => 'Import';

  @override
  String get importerCsv => 'Import a CSV';

  @override
  String get importerCsvSousTitre => 'Restore a Koudi Na export (same columns)';

  @override
  String get fichierIllisible => 'This file could not be read.';

  @override
  String get importerTitre => 'Import this file?';

  @override
  String importResume(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre transactions will be added.',
      one: '1 transaction will be added.',
      zero: 'No transactions will be added.',
    );
    return '$_temp0';
  }

  @override
  String importIgnorees(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre lines skipped (unknown category, account or amount).',
      one: '1 line skipped (unknown category, account or amount).',
    );
    return '$_temp0';
  }

  @override
  String get importDoublonsAvertissement =>
      'This import adds the transactions without checking for duplicates: importing the same file twice creates two copies.';

  @override
  String get importer => 'Import';

  @override
  String importTermine(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre transactions imported.',
      one: '1 transaction imported.',
    );
    return '$_temp0';
  }

  @override
  String get langue => 'Language';

  @override
  String get langueSysteme => 'System';

  @override
  String get exporterBouton => 'Export';

  @override
  String get periode => 'Period';

  @override
  String get periodeMoisCourant => 'This month';

  @override
  String get periodeTout => 'All';

  @override
  String get periodePersonnalisee => 'Custom';

  @override
  String get choisirDates => 'Choose dates';

  @override
  String plageDatesValeur(String debut, String fin) {
    return '$debut – $fin';
  }

  @override
  String get format => 'Format';

  @override
  String genereLe(String date) {
    return 'Generated on $date';
  }

  @override
  String get analyse => 'Insights';

  @override
  String get trajectoireEpargne => 'Savings trajectory';

  @override
  String get tauxEpargne => 'Savings rate';

  @override
  String get joursSansDepense => 'No-spend days';

  @override
  String get projectionFinDeMois => 'End-of-month projection';

  @override
  String get projectionDepasseEntrees =>
      'At the current pace, you will exceed your income this month';

  @override
  String get pasAssezDonneesComparer => 'Not enough data to compare';

  @override
  String get pasAssezDonnees90Jours => 'Not enough data over the last 90 days';

  @override
  String get momentMatin => 'Morning';

  @override
  String get momentApresMidi => 'Afternoon';

  @override
  String get momentSoir => 'Evening';

  @override
  String get momentNuit => 'Night';

  @override
  String obsHausse(String categorie, int pourcent) {
    return 'Your $categorie spending is up $pourcent% this month.';
  }

  @override
  String obsDepassement(String montant) {
    return 'At the current pace, you will exceed your income by $montant before the end of the month.';
  }

  @override
  String obsObjectifEpargne(int mois) {
    String _temp0 = intl.Intl.pluralLogic(
      mois,
      locale: localeName,
      other: 'You have met your savings goal $mois months in a row.',
    );
    return '$_temp0';
  }

  @override
  String obsAutonomie(String mois) {
    return 'Your savings now cover $mois months of spending.';
  }

  @override
  String get onboardingSuivant => 'Continue';

  @override
  String get onboardingCommencer => 'Log my first expense';

  @override
  String get devise => 'Currency';

  @override
  String get deviseRechercher => 'Search a currency';

  @override
  String get devisePrincipales => 'Main currencies';

  @override
  String get deviseToutes => 'All currencies';

  @override
  String get deviseAucunResultat => 'No currency found';

  @override
  String get deviseObligatoireIndication => 'Choose your currency to continue';

  @override
  String get onboardingTitre1 => 'Know where every cent goes';

  @override
  String get onboardingCorps1 =>
      'Bread, a moto ride, phone top-up: money leaves in small pieces. Log them in Koudi Na and see your whole month, cent by cent.';

  @override
  String get onboardingTitre2 => 'One amount, one category, saved';

  @override
  String onboardingCorps2(String montant) {
    return '$montant, Transport, saved: before the taxi pulls away. Cash, bank or mobile money, every cent lands in the right place. Nothing to type up tonight.';
  }

  @override
  String get onboardingTitre3 => '40/25/35: your income, already split';

  @override
  String get onboardingCorps3 =>
      'Savings 40%, Family 25%, Living 35%: the split is decided before you spend. Each bar shows where you stand against the target. One glance, nothing to calculate.';

  @override
  String get onboardingTitre4 => 'Your numbers stay in your pocket';

  @override
  String get onboardingCorps4 =>
      'Everything lives on your phone, no sign-up, no server. Works without signal, at the market or the village. Only you read your numbers. Your first expense is waiting.';

  @override
  String get aPropos => 'About';

  @override
  String aProposVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aProposPolitiqueConfidentialite => 'Privacy policy';

  @override
  String get aProposNousContacter => 'Contact us';

  @override
  String get aProposEditeur => 'Koudi Na is published by XNOVA Systems.';

  @override
  String get aProposHorsLigne =>
      '100% offline: no data leaves your phone, except a CSV export you start yourself.';

  @override
  String get aProposLienIndisponible => 'Couldn\'t open this link.';

  @override
  String get notificationSectionTitre => 'Notifications';

  @override
  String get notificationRappelQuotidienTitre => 'Daily reminder';

  @override
  String get notificationRappelQuotidienSousTitre =>
      'Pick a time to be reminded to record your expenses.';

  @override
  String notificationRappelHeureChoisie(String heure) {
    return 'On at $heure';
  }

  @override
  String get notificationRecapHebdomadaireTitre => 'Weekly recap';

  @override
  String get notificationRecapHebdomadaireSousTitre =>
      'A reminder every Sunday evening to check your week\'s summary.';

  @override
  String get notificationPermissionRefusee =>
      'Notifications denied. Allow them in your phone\'s settings to turn this on.';

  @override
  String get notificationRappelNotifTitre => 'Koudi Na';

  @override
  String get notificationRappelNotifCorps =>
      'Don\'t forget to record today\'s expenses.';

  @override
  String get notificationRecapNotifTitre => 'Koudi Na';

  @override
  String get notificationRecapNotifCorps =>
      'Your weekly summary is ready, open the app to see it.';

  @override
  String get notificationDepassementNotifTitre => 'Budget overrun';

  @override
  String notificationDepassementNotifCorps(String pilier) {
    return 'The $pilier pillar is over its target this month.';
  }

  @override
  String get badgesTitre => 'Badges';

  @override
  String get badgesEntreeReglages => 'View my badges';

  @override
  String get badgesDeblocageTitre => 'Badge unlocked!';

  @override
  String get badgesDeblocageBouton => 'Continue';

  @override
  String badgesProgression(int debloques, int total) {
    return '$debloques/$total badges unlocked';
  }

  @override
  String get astuceDuJourEtiquette => 'Tip of the day';

  @override
  String serieInfobulle(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre days in a row with at least one entry',
      one: '1 day in a row with at least one entry',
    );
    return '$_temp0';
  }

  @override
  String get serieInfobulleVide =>
      'Log an expense today to light up your streak';

  @override
  String get didacticielSuivant => 'Next';

  @override
  String get didacticielTerminer => 'Let\'s go';

  @override
  String get didacticielPasser => 'Skip';

  @override
  String didacticielEtape(int numero, int total) {
    return '$numero/$total';
  }

  @override
  String get didacticielSoldeTitre => 'Your monthly balance';

  @override
  String get didacticielSoldeTexte =>
      'This month\'s income minus spending, updated with every entry.';

  @override
  String get didacticielSerieTitre => 'Your streak';

  @override
  String get didacticielSerieTexte =>
      'Every day you log at least one expense, the flame lights up and counts the days. Tap it to see where you stand.';

  @override
  String get didacticielAnalyseTitre => 'Insights';

  @override
  String get didacticielAnalyseTexte =>
      'Your trends over 12 months, the 40/25/35 rule, a tip every day.';

  @override
  String get didacticielMoisTitre => 'Activity';

  @override
  String get didacticielMoisTexte =>
      'All your entries, month by month, to search, filter or edit.';

  @override
  String get didacticielReglagesTitre => 'Settings';

  @override
  String get didacticielReglagesTexte =>
      'Language, currency, reminders, badges, data export. You can replay this tour from there too.';

  @override
  String get reglagesRevoirDidacticiel => 'Replay the guided tour';

  @override
  String get ongletAccueil => 'Home';

  @override
  String get ongletJournal => 'Activity';

  @override
  String get boutonAjouterSemantique => 'Add an expense or income';

  @override
  String get nouvelleOperation => 'New entry';

  @override
  String get operationDepenseSousTitre => 'Meals, transport, data, family…';

  @override
  String get operationEntreeSousTitre => 'Salary, freelance, gifts…';

  @override
  String get fermer => 'Close';

  @override
  String saisieDate(String date) {
    return 'Date: $date';
  }

  @override
  String get aujourdhui => 'Today';

  @override
  String get saisieResteAvant => '';

  @override
  String get saisieResteApres => ' left this month';

  @override
  String get saisieNote => 'Note';

  @override
  String get saisieNoteAjouter => 'Add a note';

  @override
  String get saisieNoteIndice => 'e.g. Lunch, taxi, market…';

  @override
  String saisieEnregistrerMontant(String montant) {
    return 'Save $montant';
  }

  @override
  String get saisieEnregistrerModifs => 'Save changes';

  @override
  String get saisieMontantVide => 'Enter an amount';

  @override
  String get saisieEffacer => 'Delete last digit';

  @override
  String get saisiePlus => 'More';

  @override
  String get saisieToutesCategories => 'All categories';

  @override
  String get saisieDepenseEnregistree => 'Expense saved';

  @override
  String get saisieEntreeEnregistree => 'Income saved';

  @override
  String get saisieOperationModifiee => 'Entry updated';

  @override
  String accueilRythmeDepense(int pourcent) {
    return '$pourcent% of income spent';
  }

  @override
  String accueilRythmeJour(int jour, int total) {
    return 'day $jour / $total';
  }

  @override
  String get accueilEnAvance => 'you\'re ahead';

  @override
  String get accueilAttentionRythme => 'watch your pace';

  @override
  String get accueilMoisTermine => 'month closed';

  @override
  String get accueilFinDeMois => 'End of month';

  @override
  String accueilSousEntrees(String montant) {
    return '$montant under your income';
  }

  @override
  String accueilAuDessusEntrees(String montant) {
    return '$montant over your income';
  }

  @override
  String get accueilSansEntree => 'no income yet';

  @override
  String get accueilMoyenneJour => 'Daily average';

  @override
  String accueilHorsEpargne(String montant) {
    return '$montant excl. savings';
  }

  @override
  String get accueilEnveloppes => 'Envelopes';

  @override
  String get accueilReste => 'left';

  @override
  String get accueilDepasseDe => 'over by';

  @override
  String get accueilEnveloppesVide =>
      'Add your first income this month to turn on the 40 · 25 · 35 rule';

  @override
  String get accueilAjouterEntree => 'Add income';

  @override
  String get accueilRecents => 'Recent';

  @override
  String get toutVoir => 'See all';

  @override
  String get accueilRecentsVide => 'Nothing this month yet. Tap + to start.';

  @override
  String get accueilChoisirMois => 'Pick a month';

  @override
  String serieJoursCourt(int nombre) {
    String _temp0 = intl.Intl.pluralLogic(
      nombre,
      locale: localeName,
      other: '$nombre days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get journalRechercher => 'Search';

  @override
  String get journalRechercheIndice => 'Note, category, account, amount…';

  @override
  String get moisPrecedent => 'Previous month';

  @override
  String get moisSuivant => 'Next month';

  @override
  String get filtreTout => 'All';

  @override
  String get filtres => 'Filters';

  @override
  String get journalVide => 'Nothing this month. Tap + to add an entry.';

  @override
  String get journalAucunResultat => 'No results';

  @override
  String get periodeMois => 'Month';

  @override
  String get periode6Mois => '6 mo';

  @override
  String get periodeAnnee => 'Year';

  @override
  String get projectionSurtitre => 'Projection';

  @override
  String projectionEnCours(String mois) {
    return 'At this pace, you\'ll end $mois with about ';
  }

  @override
  String get projectionDeDepenses => ' in spending';

  @override
  String get projectionSoit => ', which is ';

  @override
  String projectionSansDepense(String mois) {
    return 'No spending in $mois so far.';
  }

  @override
  String get entreesEtDepenses => 'Income and spending';

  @override
  String ouVaLArgent(String periode) {
    return 'Where the money goes · $periode';
  }

  @override
  String semaineCourte(int numero) {
    return 'W$numero';
  }

  @override
  String get analyseJoursCouteux => 'Costliest days';

  @override
  String get analyseVide => 'Add a few entries to see your trends here.';

  @override
  String get didacticielPlusTitre => 'The + button';

  @override
  String get didacticielPlusTexte =>
      'Tap it to log an expense or income. Press and hold to go straight to an expense.';
}
