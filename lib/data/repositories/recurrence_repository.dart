import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../core/constants/hive_boxes.dart';
import '../models/recurrence.dart';

/// Accès à la Box des récurrences. Aucune règle métier ici : la
/// génération des transactions mensuelles vit dans
/// `data/recurrence/generation_recurrences.dart`.
class RecurrenceRepository {
  Box<Recurrence> get _box => Hive.box<Recurrence>(HiveBoxes.recurrences);

  List<Recurrence> tous() => _box.values.toList();

  Future<void> enregistrer(Recurrence recurrence) => _box.put(recurrence.id, recurrence);

  Future<void> supprimer(String id) => _box.delete(id);

  ValueListenable<Box<Recurrence>> listenable() => _box.listenable();
}
