import 'package:hive_ce_flutter/hive_flutter.dart';

import '../core/constants/hive_boxes.dart';
import '../hive_registrar.g.dart';
import 'models/categorie.dart';
import 'models/compte.dart';
import 'models/transaction.dart';
import 'repositories/categorie_repository.dart';
import 'repositories/compte_repository.dart';
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

  await seedSiPremierLancement(
    comptes: CompteRepository(),
    categories: CategorieRepository(),
  );
}
