import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import '../../data/models/categorie.dart';
import '../../data/models/compte.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';
import 'csv_colonnes.dart';

/// Construit le contenu CSV des transactions (section 4, écran D), avec
/// les en-têtes et les valeurs de type dans la langue demandée (voir
/// csv_colonnes.dart). Fonction pure — aucun accès disque ici — pour
/// rester facilement testable indépendamment du système de fichiers.
String genererCsvTransactions(
  List<Transaction> transactions,
  Map<String, Categorie> categoriesParId,
  Map<String, Compte> comptesParId, {
  String langue = 'fr',
}) {
  final colonnes = colonnesCsvPour(langue);
  // Format de date fixe (ISO), indépendant de la langue : un tableur
  // le reconnaît partout, et l'import le relit sans ambiguïté.
  final formatDate = DateFormat('yyyy-MM-dd');
  final lignes = <List<dynamic>>[
    colonnes.enTetes,
    for (final transaction in transactions)
      [
        formatDate.format(transaction.date),
        transaction.type == TypeMouvement.entree
            ? colonnes.valeurEntree
            : colonnes.valeurDepense,
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
