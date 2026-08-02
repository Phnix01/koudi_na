import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../core/constants/hive_boxes.dart';
import '../models/compte.dart';

/// Accès à la Box des comptes. Aucune règle métier ici : juste lire et
/// écrire.
class CompteRepository {
  Box<Compte> get _box => Hive.box<Compte>(HiveBoxes.comptes);

  List<Compte> tous() => _box.values.toList();

  bool get estVide => _box.isEmpty;

  /// `put` avec la même clé écrase l'existant : sert à la fois à la
  /// création (nouvel id) et à la modification (id existant).
  Future<void> enregistrer(Compte compte) => _box.put(compte.id, compte);

  ValueListenable<Box<Compte>> listenable() => _box.listenable();
}
