import 'package:hive_ce/hive.dart';

import 'type_mouvement.dart';

part 'transaction.g.dart';

/// L'entité centrale de KUDI (section 2.3) : une transaction unique,
/// dépense ou entrée.
@HiveType(typeId: 3)
class Transaction extends HiveObject {
  Transaction({
    required this.id,
    required this.date,
    required this.type,
    required this.montant,
    required this.categorieId,
    required this.compteId,
    this.note,
    this.recurrenteId,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  TypeMouvement type;

  /// En FCFA entiers, jamais en `double` : les arrondis binaires des
  /// flottants sont inacceptables sur de l'argent réel (section 2.3).
  @HiveField(3)
  int montant;

  @HiveField(4)
  String categorieId;

  @HiveField(5)
  String compteId;

  @HiveField(6)
  String? note;

  /// Renseigné si la transaction a été générée automatiquement par une
  /// récurrence (Phase 4) — `null` pour toute saisie manuelle.
  @HiveField(7)
  String? recurrenteId;
}
