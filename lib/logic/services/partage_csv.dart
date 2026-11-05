import 'dart:convert';

import 'partage_fichier.dart';

/// Partage le CSV généré par [genererCsvTransactions] (section 4,
/// écran D). Fin wrapper autour de [partagerFichier] : l'encodage
/// UTF-8 transforme le caractère BOM (U+FEFF) ajouté par
/// genererCsvTransactions en ses 3 octets EF BB BF réels sur le disque.
Future<void> partagerCsv(
  String contenuCsv,
  String nomFichier, {
  required String texte,
}) => partagerFichier(utf8.encode(contenuCsv), nomFichier, texte: texte);
