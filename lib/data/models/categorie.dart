import 'package:hive_ce/hive.dart';

import 'pilier.dart';
import 'type_mouvement.dart';

part 'categorie.g.dart';

/// Une catégorie de dépense ou d'entrée (section 2.3). Toutes les
/// catégories sont modifiables et désactivables par l'utilisateur :
/// aucune n'est figée dans le code, seul le seed initial (étape
/// suivante) en propose une liste de départ.
@HiveType(typeId: 4)
class Categorie extends HiveObject {
  Categorie({
    required this.id,
    required this.libelle,
    required this.type,
    required this.iconeCode,
    required this.couleurHex,
    this.pilier,
    this.ordre = 0,
    this.active = true,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String libelle;

  @HiveField(2)
  TypeMouvement type;

  /// Clé vers [icones] (`core/constants/icones.dart`), ex. `"bowlFood"`.
  @HiveField(3)
  String iconeCode;

  @HiveField(4)
  String couleurHex;

  /// `null` pour les catégories d'entrées : seules les dépenses
  /// alimentent la règle 40/25/35.
  @HiveField(5)
  Pilier? pilier;

  @HiveField(6)
  int ordre;

  @HiveField(7)
  bool active;
}
