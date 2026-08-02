import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../core/constants/hive_boxes.dart';
import '../models/compte.dart';

/// Accès à la Box des comptes. Aucune règle métier ici : juste lire et
/// écrire.
class CompteRepository {
  Box<Compte> get _box => Hive.box<Compte>(HiveBoxes.comptes);

  List<Compte> tous() => _box.values.toList();

  bool get estVide => _box.isEmpty;

  Future<void> ajouter(Compte compte) => _box.put(compte.id, compte);
}
