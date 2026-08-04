import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/categorie.dart';
import '../../data/models/compte.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';

/// Résultat d'une lecture de CSV (section 4, écran D, Phase 4) : les
/// transactions reconnues, prêtes à enregistrer, et le nombre de
/// lignes qui n'ont pas pu être rattachées à une catégorie/un compte
/// existant ou dont le format était invalide.
typedef ResultatImportCsv = ({
  List<Transaction> transactions,
  int lignesIgnorees,
});

/// Lit un CSV au même format que celui produit par `genererCsvTransactions`
/// (Date, Type, Montant (FCFA), Catégorie, Compte, Note) : conçu avant
/// tout pour réimporter un export KUDI, pas un format de tableur
/// arbitraire — la catégorie et le compte doivent correspondre à des
/// libellés déjà connus de l'application.
///
/// Ne touche pas à Hive : c'est à l'appelant d'enregistrer les
/// transactions retournées, une fois que l'utilisateur a confirmé.
ResultatImportCsv parserCsvTransactions(
  String contenuCsv,
  List<Categorie> categories,
  List<Compte> comptes,
) {
  // Un CSV exporté par KUDI commence par un BOM (U+FEFF, ecrit ici via
  // String.fromCharCode pour eviter toute ambiguite visuelle) : sans le
  // retirer, il resterait colle au nom de la premiere colonne ("Date")
  // et empecherait de la retrouver par son nom.
  final bom = String.fromCharCode(0xFEFF);
  final contenuSansBom = contenuCsv.startsWith(bom)
      ? contenuCsv.substring(1)
      : contenuCsv;

  final categorieParCle = {
    for (final c in categories)
      '${c.type.name}|${c.libelle.trim().toLowerCase()}': c,
  };
  final compteParLibelle = {
    for (final c in comptes) c.libelle.trim().toLowerCase(): c,
  };
  final formatDate = DateFormat('yyyy-MM-dd');

  List<dynamic> lignes;
  try {
    lignes = Csv().decodeWithHeaders(contenuSansBom);
  } catch (_) {
    return (transactions: const [], lignesIgnorees: 0);
  }

  final transactions = <Transaction>[];
  var lignesIgnorees = 0;

  for (final ligne in lignes) {
    try {
      final typeTexte = ligne['Type'].toString().trim().toLowerCase();
      final type = typeTexte.startsWith('entr')
          ? TypeMouvement.entree
          : TypeMouvement.depense;

      final categorie =
          categorieParCle['${type.name}|${ligne['Catégorie'].toString().trim().toLowerCase()}'];
      final compte =
          compteParLibelle[ligne['Compte'].toString().trim().toLowerCase()];
      final montant = int.parse(ligne['Montant (FCFA)'].toString().trim());
      final date = formatDate.parse(ligne['Date'].toString().trim());
      final note = ligne['Note']?.toString().trim();

      if (categorie == null || compte == null || montant <= 0) {
        lignesIgnorees++;
        continue;
      }

      transactions.add(
        Transaction(
          id: const Uuid().v4(),
          date: date,
          type: type,
          montant: montant,
          categorieId: categorie.id,
          compteId: compte.id,
          note: (note == null || note.isEmpty) ? null : note,
        ),
      );
    } catch (_) {
      lignesIgnorees++;
    }
  }

  return (transactions: transactions, lignesIgnorees: lignesIgnorees);
}
