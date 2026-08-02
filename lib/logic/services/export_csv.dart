import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import '../../data/models/categorie.dart';
import '../../data/models/compte.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';

/// Construit le contenu CSV des transactions (section 4, écran D).
/// Fonction pure — aucun accès disque ici — pour rester facilement
/// testable indépendamment du système de fichiers.
String genererCsvTransactions(
  List<Transaction> transactions,
  Map<String, Categorie> categoriesParId,
  Map<String, Compte> comptesParId,
) {
  final formatDate = DateFormat('yyyy-MM-dd');
  final lignes = <List<dynamic>>[
    ['Date', 'Type', 'Montant (FCFA)', 'Catégorie', 'Compte', 'Note'],
    for (final transaction in transactions)
      [
        formatDate.format(transaction.date),
        transaction.type == TypeMouvement.entree ? 'Entrée' : 'Dépense',
        transaction.montant,
        categoriesParId[transaction.categorieId]?.libelle ?? '',
        comptesParId[transaction.compteId]?.libelle ?? '',
        transaction.note ?? '',
      ],
  ];

  // `addBom: true` : un tableur qui ouvre un CSV sans BOM devine parfois
  // le mauvais encodage et corrompt les accents (critère de recette n°6).
  return Csv(addBom: true).encode(lignes);
}
