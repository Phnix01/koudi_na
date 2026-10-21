import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../core/constants/hive_boxes.dart';

/// Accès aux préférences de l'application (section 4, écran D). Une
/// Box de chaînes suffit : chaque réglage est une paire clé → valeur,
/// pas un objet à sérialiser.
class ReglagesRepository {
  static const _cleLangue = 'langue';

  Box<String> get _box => Hive.box<String>(HiveBoxes.reglages);

  /// Code de langue choisi par l'utilisateur (`fr`, `en`), ou `null`
  /// pour suivre la langue du téléphone.
  String? get langue => _box.get(_cleLangue);

  Future<void> enregistrerLangue(String? code) =>
      code == null ? _box.delete(_cleLangue) : _box.put(_cleLangue, code);
}
