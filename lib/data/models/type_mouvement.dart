import 'package:hive_ce/hive.dart';

part 'type_mouvement.g.dart';

/// Sens d'un mouvement d'argent. Partagé entre [Transaction] et
/// [Categorie] : une catégorie de dépense n'apparaît jamais dans le
/// sélecteur d'entrée, et inversement (écran Capture, section 4).
///
/// typeId Hive réservés pour ce projet : 0=TypeMouvement, 1=Pilier,
/// 2=TypeCompte, 3=Transaction, 4=Categorie, 5=Compte.
@HiveType(typeId: 0)
enum TypeMouvement {
  @HiveField(0)
  depense,
  @HiveField(1)
  entree,
}
