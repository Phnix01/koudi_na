import 'package:hive_ce/hive.dart';

part 'pilier.g.dart';

/// Les trois piliers de la règle 40/25/35 (sections 2.3 et 5.2).
/// Seules les catégories de dépenses en portent un ; les catégories
/// d'entrées laissent ce champ à `null` dans [Categorie].
@HiveType(typeId: 1)
enum Pilier {
  @HiveField(0)
  epargne,
  @HiveField(1)
  famille,
  @HiveField(2)
  vie,
}
