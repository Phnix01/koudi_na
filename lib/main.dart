import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'data/hive_init.dart';
import 'l10n/l10n.dart';
import 'logic/providers/langue_provider.dart';
import 'logic/providers/notifications_provider.dart';
import 'logic/services/notifications_service.dart';
import 'ui/screens/splash_screen.dart';

Future<void> main() async {
  // Nécessaire dès qu'on fait un travail asynchrone (ici : ouvrir Hive,
  // charger les symboles de date) avant runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Geist est embarquée dans assets/google_fonts/ (voir AppTheme) : l'app
  // reste 100 % hors ligne, aucune police n'est téléchargée.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    final licence = await rootBundle.loadString(
      'assets/google_fonts/OFL-Geist.txt',
    );
    yield LicenseEntryWithLineBreaks(['google_fonts'], licence);
  });

  await initialiserHive();
  // Charge les noms de mois/jours de chaque langue supportée ("2 août"
  // plutôt que "Aug 2") : sans cet appel, DateFormat lève une exception
  // au premier usage dans cette langue.
  for (final locale in AppLocalizations.supportedLocales) {
    await initializeDateFormatting(locale.languageCode);
  }

  final notifications = NotificationsService(FlutterLocalNotificationsPlugin());
  await notifications.init();

  runApp(
    ProviderScope(
      overrides: [
        notificationsServiceProvider.overrideWithValue(notifications),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Changer la langue dans Réglages reconstruit MaterialApp avec la
    // nouvelle locale : tous les écrans ouverts se retraduisent.
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitre,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Refonte D : thème clair uniquement. La variante sombre des jetons
      // existe (KoudiTokens.sombre) mais n'est pas encore activée.
      theme: AppTheme.clair,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      // Icônes de barre d'état sombres partout : les onglets n'ont pas
      // d'AppBar pour les imposer, et un iPhone en mode sombre les
      // afficherait en blanc, invisibles sur le fond clair.
      builder: (context, enfant) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
        child: enfant!,
      ),
      home: const SplashScreen(),
    );
  }
}
