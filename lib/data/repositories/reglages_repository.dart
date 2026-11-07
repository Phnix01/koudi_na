import 'package:flutter/material.dart' show TimeOfDay;
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../core/constants/devises.dart' show deviseParDefautCode;
import '../../core/constants/hive_boxes.dart';

/// Accès aux préférences de l'application (section 4, écran D). Une
/// Box de chaînes suffit : chaque réglage est une paire clé → valeur,
/// pas un objet à sérialiser.
class ReglagesRepository {
  static const _cleLangue = 'langue';
  static const _cleDevise = 'devise';
  static const _cleOnboardingTermine = 'onboarding_termine';
  static const _cleRappelQuotidienHeure = 'rappel_quotidien_heure';
  static const _cleRecapHebdomadaireActif = 'recap_hebdomadaire_actif';

  Box<String> get _box => Hive.box<String>(HiveBoxes.reglages);

  /// Code de langue choisi par l'utilisateur (`fr`, `en`), ou `null`
  /// pour suivre la langue du téléphone.
  String? get langue => _box.get(_cleLangue);

  Future<void> enregistrerLangue(String? code) =>
      code == null ? _box.delete(_cleLangue) : _box.put(_cleLangue, code);

  /// Code ISO de la devise choisie (`XOF`, `EUR`...), ou celui de la
  /// devise par défaut si l'utilisateur n'a encore rien choisi — ce qui
  /// couvre aussi les installations antérieures à ce réglage.
  String get devise => _box.get(_cleDevise) ?? deviseParDefautCode;

  Future<void> enregistrerDevise(String code) => _box.put(_cleDevise, code);

  /// Vrai une fois que l'utilisateur a passé l'onboarding : il ne doit
  /// le voir qu'au tout premier lancement.
  bool get onboardingTermine => _box.get(_cleOnboardingTermine) == 'oui';

  Future<void> marquerOnboardingTermine() =>
      _box.put(_cleOnboardingTermine, 'oui');

  /// Heure du rappel quotidien (`HH:mm`), ou `null` si désactivé.
  TimeOfDay? get rappelQuotidienHeure {
    final valeur = _box.get(_cleRappelQuotidienHeure);
    if (valeur == null) return null;
    final parties = valeur.split(':');
    if (parties.length != 2) return null;
    final heure = int.tryParse(parties[0]);
    final minute = int.tryParse(parties[1]);
    if (heure == null || minute == null) return null;
    return TimeOfDay(hour: heure, minute: minute);
  }

  Future<void> enregistrerRappelQuotidien(TimeOfDay? heure) => heure == null
      ? _box.delete(_cleRappelQuotidienHeure)
      : _box.put(_cleRappelQuotidienHeure, '${heure.hour}:${heure.minute}');

  bool get recapHebdomadaireActif =>
      _box.get(_cleRecapHebdomadaireActif) == 'oui';

  Future<void> enregistrerRecapHebdomadaire(bool actif) => actif
      ? _box.put(_cleRecapHebdomadaireActif, 'oui')
      : _box.delete(_cleRecapHebdomadaireActif);
}
