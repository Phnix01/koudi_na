import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'core/constants/icones.dart';
import 'core/theme/app_theme.dart';
import 'data/hive_init.dart';
import 'data/repositories/categorie_repository.dart';
import 'data/repositories/compte_repository.dart';

Future<void> main() async {
  // Nécessaire dès qu'on fait un travail asynchrone (ici : ouvrir Hive
  // et écrire le seed) avant runApp() : ça prépare le moteur Flutter à
  // recevoir des appels de plugins natifs avant que l'UI n'existe.
  WidgetsFlutterBinding.ensureInitialized();
  await initialiserHive();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KUDI',
      // Sombre par défaut (section 3.1) : le thème clair viendra plus tard.
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const BancDEssaiSeed(),
    );
  }
}

/// Écran temporaire pour vérifier que le seed (section 2.4) a bien
/// peuplé les comptes et catégories par défaut. Sera remplacé par
/// l'écran Capture à l'étape suivante.
class BancDEssaiSeed extends StatelessWidget {
  const BancDEssaiSeed({super.key});

  @override
  Widget build(BuildContext context) {
    final comptes = CompteRepository().tous();
    final categories = CategorieRepository().tous()..sort((a, b) => a.ordre.compareTo(b.ordre));

    return Scaffold(
      appBar: AppBar(title: const Text('KUDI — test du seed')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Comptes (${comptes.length})', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: comptes.map((c) => _PucePreview(libelle: c.libelle, iconeCode: c.iconeCode, couleurHex: c.couleurHex)).toList()),
          const SizedBox(height: 24),
          Text('Catégories (${categories.length})', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: categories.map((c) => _PucePreview(libelle: c.libelle, iconeCode: c.iconeCode, couleurHex: c.couleurHex)).toList()),
        ],
      ),
    );
  }
}

class _PucePreview extends StatelessWidget {
  const _PucePreview({required this.libelle, required this.iconeCode, required this.couleurHex});

  final String libelle;
  final String iconeCode;
  final String couleurHex;

  @override
  Widget build(BuildContext context) {
    final couleur = Color(int.parse(couleurHex.replaceFirst('#', '0xFF')));
    return Chip(
      avatar: PhosphorIcon(icones[iconeCode] ?? PhosphorIconsFill.question, color: couleur, size: 18),
      label: Text(libelle),
    );
  }
}
