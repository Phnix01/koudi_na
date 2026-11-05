import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Écrit des octets quelconques (CSV, PDF, Excel...) dans le dossier
/// temporaire de l'app puis ouvre la feuille de partage native —
/// WhatsApp, mail, Drive... `texte` est le message qui accompagne le
/// fichier, déjà traduit par l'appelant.
Future<void> partagerFichier(
  Uint8List octets,
  String nomFichier, {
  required String texte,
}) async {
  final dossier = await getTemporaryDirectory();
  final fichier = File('${dossier.path}/$nomFichier');
  await fichier.writeAsBytes(octets);
  await SharePlus.instance.share(
    ShareParams(files: [XFile(fichier.path)], text: texte),
  );
}
