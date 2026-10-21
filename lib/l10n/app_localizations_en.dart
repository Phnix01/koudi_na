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
  String get enregistrerModifications => 'Save changes';

  @override
  String get annuler => 'Cancel';

  @override
  String get supprimer => 'Delete';

  @override
  String get modifier => 'Edit';

  @override
  String get tous => 'All';

  @override
  String get reinitialiser => 'Reset';

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
  String get regle402535 => '40/25/35 rule';

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
  String get tooltipAnalyse => 'Insights';

  @override
  String get tooltipVoirLeMois => 'View month';

  @override
  String get tooltipReglages => 'Settings';

  @override
  String get aujourdHui => 'Today';

  @override
  String get hier => 'Yesterday';

  @override
  String get aucuneTransactionFiltres => 'No transactions match these filters';

  @override
  String get aucuneTransactionMois => 'No transactions this month';

  @override
  String get transactionSupprimee => 'Transaction deleted';

  @override
  String get categorieSupprimee => 'Deleted category';

  @override
  String get compteSupprime => 'Deleted account';

  @override
  String get supprimerTransactionTitre => 'Delete this transaction?';

  @override
  String get actionIrreversible => 'This cannot be undone.';

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
  String get soldeInitialFcfa => 'Opening balance (FCFA)';

  @override
  String get objectifEpargneFcfa => 'Savings goal (FCFA, optional)';

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
  String get montantFcfa => 'Amount (FCFA)';

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
  String get exporterMoisCourant => 'Export current month';

  @override
  String get exporterTout => 'Export all transactions';

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
  String get analyse => 'Insights';

  @override
  String get evolution12Mois => '12-month trend';

  @override
  String get repartitionDepensesMois => 'Spending breakdown (this month)';

  @override
  String get top5Titre => 'Top 5 categories (this month vs last month)';

  @override
  String get moisDernier => 'Last month';

  @override
  String get ceMoisCouleurCategorie => 'This month: category color';

  @override
  String get rythmeDuMois => 'Monthly pace';

  @override
  String get habitudesHebdo90 => 'Weekly habits (last 90 days)';

  @override
  String get trajectoireEpargne => 'Savings trajectory';

  @override
  String get aucunObjectifRegle =>
      'No goal set: open Settings → Accounts → your Savings account to set one.';

  @override
  String get equilibrePiliers6Mois => 'Pillar balance (6 months)';

  @override
  String get autonomieFinanciere => 'Financial runway';

  @override
  String autonomieValeur(String mois) {
    return '$mois months';
  }

  @override
  String get autonomieDescription =>
      'Number of months of average spending your current savings cover';

  @override
  String get tauxEpargne => 'Savings rate';

  @override
  String get joursSansDepense => 'No-spend days';

  @override
  String get depenseMoyJourMois => 'Avg. spend / day (this month)';

  @override
  String get depenseMoyJourHistorique => 'Avg. spend / day (all time)';

  @override
  String get projectionFinDeMois => 'End-of-month projection';

  @override
  String get projectionDepasseEntrees =>
      'At the current pace, you will exceed your income this month';

  @override
  String get pasAssezDonnees => 'Not enough data';

  @override
  String get pasAssezDonneesComparer => 'Not enough data to compare';

  @override
  String get pasAssezDonnees90Jours => 'Not enough data over the last 90 days';

  @override
  String get aucuneDepenseMois => 'No expenses this month';

  @override
  String get entreesDuMois => 'Month\'s income';

  @override
  String get momentMatin => 'Morning';

  @override
  String get momentApresMidi => 'Afternoon';

  @override
  String get momentSoir => 'Evening';

  @override
  String get momentNuit => 'Night';

  @override
  String get retirerNote => 'Remove note';

  @override
  String get ajouterNote => 'Add a note';

  @override
  String get noteOptionnelle => 'Note (optional)';

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
}
