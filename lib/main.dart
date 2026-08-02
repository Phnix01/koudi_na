import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'data/hive_init.dart';
import 'ui/screens/capture_screen.dart';

Future<void> main() async {
  // Nécessaire dès qu'on fait un travail asynchrone (ici : ouvrir Hive,
  // charger les symboles de date fr_FR) avant runApp().
  WidgetsFlutterBinding.ensureInitialized();
  await initialiserHive();
  // Charge les noms de mois/jours en français ("2 août" plutôt que
  // "Aug 2") : sans cet appel, DateFormat('...', 'fr_FR') lève une
  // exception au premier usage.
  await initializeDateFormatting('fr_FR');
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
      home: const CaptureScreen(),
    );
  }
}
