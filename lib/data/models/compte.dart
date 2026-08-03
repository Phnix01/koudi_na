import 'package:hive_ce/hive.dart';

part 'compte.g.dart';

/// Les quatre familles de comptes du contexte ouest-africain (section 1.3) :
/// le mobile money est traité au même rang que les espèces et la banque,
/// jamais comme une option secondaire.
@HiveType(typeId: 2)
enum TypeCompte {
  @HiveField(0)
  especes,
  @HiveField(1)
  banque,
  @HiveField(2)
  mobileMoney,
  @HiveField(3)
  epargne,
}

/// Un compte (section 2.3). `extends HiveObject` donne accès à
/// `.save()` et `.delete()` directement sur l'instance une fois qu'elle
/// est stockée dans une Box, sans avoir à repasser par la clé.
@HiveType(typeId: 5)
class Compte extends HiveObject {
  Compte({
    required this.id,
    required this.libelle,
    required this.type,
    required this.iconeCode,
    required this.couleurHex,
    this.soldeInitial = 0,
    this.actif = true,
    this.objectifMontant,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String libelle;

  @HiveField(2)
  TypeCompte type;

  /// Clé vers [icones] (`core/constants/icones.dart`), ex. `"bank"`.
  @HiveField(3)
  String iconeCode;

  @HiveField(4)
  String couleurHex;

  @HiveField(5)
  int soldeInitial;

  @HiveField(6)
  bool actif;

  /// Objectif d'épargne à long terme (section 4, écran D), utilisé
  /// comme ligne de référence dans le graphique "Trajectoire d'épargne"
  /// (section 5.1). `null` : pas d'objectif fixé, seulement pertinent
  /// pour un compte de type [TypeCompte.epargne].
  @HiveField(7)
  int? objectifMontant;
}
