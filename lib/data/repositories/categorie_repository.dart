import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../core/constants/hive_boxes.dart';
import '../models/categorie.dart';

/// Accès à la Box des catégories. Aucune règle métier ici (pas de calcul
/// de totaux, pas de tri par pilier) : juste lire et écrire.
class CategorieRepository {
  Box<Categorie> get _box => Hive.box<Categorie>(HiveBoxes.categories);

  List<Categorie> tous() => _box.values.toList();

  bool get estVide => _box.isEmpty;

  Future<void> ajouter(Categorie categorie) => _box.put(categorie.id, categorie);
}
