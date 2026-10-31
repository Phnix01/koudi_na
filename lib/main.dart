import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'data/hive_init.dart';
import 'l10n/l10n.dart';
import 'logic/providers/langue_provider.dart';
import 'ui/screens/capture_screen.dart';
import 'ui/screens/onboarding_screen.dart';

Future<void> main() async {
  // Nécessaire dès qu'on fait un travail asynchrone (ici : ouvrir Hive,
  // charger les symboles de date) avant runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Inter et Sora sont embarquées dans assets/google_fonts/ (voir
  // AppTheme) : l'app reste 100 % hors ligne, aucune police n'est
  // téléchargée au premier lancement.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    final interLicense = await rootBundle.loadString(
      'assets/google_fonts/OFL-Inter.txt',
    );
    yield LicenseEntryWithLineBreaks(['google_fonts'], interLicense);
    final soraLicense = await rootBundle.loadString(
      'assets/google_fonts/OFL-Sora.txt',
    );
    yield LicenseEntryWithLineBreaks(['google_fonts'], soraLicense);
  });

  await initialiserHive();
  // Charge les noms de mois/jours de chaque langue supportée ("2 août"
  // plutôt que "Aug 2") : sans cet appel, DateFormat lève une exception
  // au premier usage dans cette langue.
  for (final locale in AppLocalizations.supportedLocales) {
    await initializeDateFormatting(locale.languageCode);
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Changer la langue dans Réglages reconstruit MaterialApp avec la
    // nouvelle locale : tous les écrans ouverts se retraduisent.
    final locale = ref.watch(localeProvider);
    // L'onboarding ne s'affiche qu'au tout premier lancement ; ensuite
    // l'app s'ouvre directement sur la Capture, son cœur (section 4).
    final onboardingTermine = ref
        .read(reglagesRepositoryProvider)
        .onboardingTermine;

    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitre,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Sombre par défaut (section 3.1) : le thème clair viendra plus tard.
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: onboardingTermine
          ? const CaptureScreen()
          : const OnboardingScreen(),
    );
  }
}
