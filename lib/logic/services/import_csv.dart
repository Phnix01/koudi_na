import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/categorie.dart';
import '../../data/models/compte.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';
import 'csv_colonnes.dart';

/// Résultat d'une lecture de CSV (section 4, écran D, Phase 4) : les
/// transactions reconnues, prêtes à enregistrer, et le nombre de
/// lignes qui n'ont pas pu être rattachées à une catégorie/un compte
/// existant ou dont le format était invalide.
typedef ResultatImportCsv = ({
  List<Transaction> transactions,
  int lignesIgnorees,
});

/// Lit un CSV au même format que celui produit par `genererCsvTransactions`,
/// quelle que soit la langue de l'export (les en-têtes français et
/// anglais sont tous reconnus, voir csv_colonnes.dart) : conçu avant
/// tout pour réimporter un export Koudi Na, pas un format de tableur
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
  // Un CSV exporté par Koudi Na commence par un BOM (U+FEFF, ecrit ici
  // via String.fromCharCode pour eviter toute ambiguite visuelle) : sans
  // le retirer, il resterait colle au nom de la premiere colonne ("Date")
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
      final champs = _ChampsLigne(ligne as CsvRow);
      final type = _lireType(champs.lire((c) => c.type));
      final libelleCategorie = champs.lire((c) => c.categorie).toLowerCase();
      final categorie = categorieParCle['${type.name}|$libelleCategorie'];
      final compte =
          compteParLibelle[champs.lire((c) => c.compte).toLowerCase()];
      final montant = int.parse(champs.lire((c) => c.montant));
      final date = formatDate.parse(champs.lire((c) => c.date));
      final note = champs.lire((c) => c.note);

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
          note: note.isEmpty ? null : note,
        ),
      );
    } catch (_) {
      lignesIgnorees++;
    }
  }

  return (transactions: transactions, lignesIgnorees: lignesIgnorees);
}

/// Une valeur de type est une entrée si elle correspond au mot
/// « Entrée »/« Income » d'une des langues connues ; tout le reste est
/// une dépense (comportement d'origine, tolérant aux variantes
/// d'accent ou de casse : « entree », « ENTRÉE »...).
TypeMouvement _lireType(String valeur) {
  final v = valeur.toLowerCase();
  for (final colonnes in colonnesCsvParLangue.values) {
    final entree = colonnes.valeurEntree.toLowerCase();
    if (v == entree || v.startsWith(entree.substring(0, 3))) {
      return TypeMouvement.entree;
    }
  }
  return TypeMouvement.depense;
}

/// Lit une colonne d'une ligne décodée en essayant son nom dans chaque
/// langue connue : un export anglais se réimporte sur un téléphone en
/// français, et inversement. `CsvRow` renvoie `null` pour un en-tête
/// absent, ce qui permet d'essayer les variantes sans exception.
class _ChampsLigne {
  _ChampsLigne(this._ligne);

  final CsvRow _ligne;

  String lire(String Function(ColonnesCsv) nomColonne) {
    for (final colonnes in colonnesCsvParLangue.values) {
      final valeur = _ligne[nomColonne(colonnes)];
      if (valeur != null) return valeur.toString().trim();
    }
    return '';
  }
}
