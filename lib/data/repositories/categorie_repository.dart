import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../core/constants/hive_boxes.dart';
import '../models/categorie.dart';

/// Accès à la Box des catégories. Aucune règle métier ici (pas de calcul
/// de totaux, pas de tri par pilier) : juste lire et écrire.
class CategorieRepository {
  Box<Categorie> get _box => Hive.box<Categorie>(HiveBoxes.categories);

  List<Categorie> tous() => _box.values.toList();

  bool get estVide => _box.isEmpty;

  /// `put` avec la même clé écrase l'existant : sert à la fois à la
  /// création (nouvel id) et à la modification (id existant).
  Future<void> enregistrer(Categorie categorie) =>
      _box.put(categorie.id, categorie);

  ValueListenable<Box<Categorie>> listenable() => _box.listenable();
}
