/// Le contrat de données du CSV (section 4, écran D) : un export
/// Koudi Na doit pouvoir être réimporté quelle que soit la langue dans
/// laquelle il a été produit. Les noms de colonnes et les valeurs de
/// la colonne Type sont donc définis ici, dans chaque langue, et
/// partagés par `export_csv.dart` (qui écrit dans la langue courante)
/// et `import_csv.dart` (qui accepte toutes les variantes).
class ColonnesCsv {
  const ColonnesCsv({
    required this.date,
    required this.type,
    required this.montant,
    required this.categorie,
    required this.compte,
    required this.note,
    required this.valeurEntree,
    required this.valeurDepense,
  });

  final String date;
  final String type;
  final String montant;
  final String categorie;
  final String compte;
  final String note;
  final String valeurEntree;
  final String valeurDepense;

  List<String> get enTetes => [date, type, montant, categorie, compte, note];
}

const Map<String, ColonnesCsv> colonnesCsvParLangue = {
  'fr': ColonnesCsv(
    date: 'Date',
    type: 'Type',
    montant: 'Montant (FCFA)',
    categorie: 'Catégorie',
    compte: 'Compte',
    note: 'Note',
    valeurEntree: 'Entrée',
    valeurDepense: 'Dépense',
  ),
  'en': ColonnesCsv(
    date: 'Date',
    type: 'Type',
    montant: 'Amount (FCFA)',
    categorie: 'Category',
    compte: 'Account',
    note: 'Note',
    valeurEntree: 'Income',
    valeurDepense: 'Expense',
  ),
};

ColonnesCsv colonnesCsvPour(String langue) =>
    colonnesCsvParLangue[langue] ?? colonnesCsvParLangue['fr']!;
