import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Écrit le CSV dans le dossier temporaire de l'app puis ouvre la
/// feuille de partage native — WhatsApp, mail, Drive... (section 4,
/// écran D). Contrairement à [genererCsvTransactions], cette fonction
/// fait de l'I/O (disque + plateforme native) : elle ne peut pas être
/// testée aussi simplement qu'un calcul pur, d'où la séparation en
/// deux fichiers.
Future<void> partagerCsv(String contenuCsv, String nomFichier) async {
  final dossier = await getTemporaryDirectory();
  final fichier = File('${dossier.path}/$nomFichier');
  // encoding: utf8 transforme le caractère BOM (U+FEFF) ajouté par
  // genererCsvTransactions en ses 3 octets EF BB BF réels sur le disque.
  await fichier.writeAsString(contenuCsv, encoding: utf8);
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(fichier.path)],
      text: 'Export KUDI — $nomFichier',
    ),
  );
}
