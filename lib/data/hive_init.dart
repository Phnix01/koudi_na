import 'package:hive_ce_flutter/hive_flutter.dart';

import '../core/constants/hive_boxes.dart';
import '../hive_registrar.g.dart';
import '../l10n/locale_utils.dart';
import 'models/categorie.dart';
import 'models/compte.dart';
import 'models/recurrence.dart';
import 'models/transaction.dart';
import 'recurrence/generation_recurrences.dart';
import 'repositories/categorie_repository.dart';
import 'repositories/compte_repository.dart';
import 'repositories/recurrence_repository.dart';
import 'repositories/reglages_repository.dart';
import 'repositories/transaction_repository.dart';
import 'seed/seed_initial.dart';

/// Initialise le stockage local : à appeler une seule fois, avant
/// runApp(). Si un écran essaie de lire une Box avant cet appel,
/// l'application plante au démarrage — c'est volontaire, une donnée
/// financière ne doit jamais être lue depuis un stockage non prêt.
Future<void> initialiserHive() async {
  await Hive.initFlutter();
  Hive.registerAdapters();

  await Hive.openBox<Transaction>(HiveBoxes.transactions);
  await Hive.openBox<Categorie>(HiveBoxes.categories);
  await Hive.openBox<Compte>(HiveBoxes.comptes);
  await Hive.openBox<Recurrence>(HiveBoxes.recurrences);
  await Hive.openBox<String>(HiveBoxes.reglages);

  // La langue est fixée ici, avant le seed : les catégories et comptes
  // de départ sont créés dans la langue de l'utilisateur, et `intl`
  // formate dates et montants correctement dès le premier écran.
  final locale = resoudreLocale(ReglagesRepository().langue);
  appliquerLocaleIntl(locale);

  await seedSiPremierLancement(
    comptes: CompteRepository(),
    categories: CategorieRepository(),
    langue: locale.languageCode,
  );

  await genererTransactionsRecurrentesSiNecessaire(
    recurrences: RecurrenceRepository(),
    transactions: TransactionRepository(),
  );
}
