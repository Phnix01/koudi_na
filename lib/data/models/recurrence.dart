import 'package:hive_ce/hive.dart';

import 'type_mouvement.dart';

part 'recurrence.g.dart';

/// Une charge ou une entrée récurrente (section 2.3, Phase 4) : chaque
/// mois, une transaction est générée automatiquement à partir de ces
/// données (voir `data/recurrence/generation_recurrences.dart`).
@HiveType(typeId: 6)
class Recurrence extends HiveObject {
  Recurrence({
    required this.id,
    required this.libelle,
    required this.type,
    required this.montant,
    required this.categorieId,
    required this.compteId,
    required this.jourDuMois,
    this.active = true,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String libelle;

  @HiveField(2)
  TypeMouvement type;

  @HiveField(3)
  int montant;

  @HiveField(4)
  String categorieId;

  @HiveField(5)
  String compteId;

  /// 1 à 31. Si le mois est plus court (ex. 30 jours et jourDuMois à
  /// 31), la transaction générée est datée du dernier jour du mois.
  @HiveField(6)
  int jourDuMois;

  @HiveField(7)
  bool active;
}
