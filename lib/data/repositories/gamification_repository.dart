import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../core/constants/hive_boxes.dart';
import '../models/pilier.dart';

/// Accès à la série de jours actifs, aux badges débloqués et aux
/// alertes de dépassement déjà montrées (section gamification). Une
/// Box de chaînes clé → valeur, même principe que [ReglagesRepository] :
/// ces données n'ont pas besoin d'un modèle Hive dédié.
class GamificationRepository {
  static const _cleSerieCourante = 'serie_courante';
  static const _cleSerieRecord = 'serie_record';
  static const _cleDerniereActivite = 'derniere_activite';
  static const _cleBadgesDebloques = 'badges_debloques';

  Box<String> get _box => Hive.box<String>(HiveBoxes.gamification);

  int get serieCourante => int.tryParse(_box.get(_cleSerieCourante) ?? '') ?? 0;

  int get serieRecord => int.tryParse(_box.get(_cleSerieRecord) ?? '') ?? 0;

  DateTime? get derniereActivite =>
      DateTime.tryParse(_box.get(_cleDerniereActivite) ?? '');

  /// Persiste la nouvelle série après une saisie active (voir
  /// `progression_utilisateur.dart`) et met à jour le record si dépassé.
  Future<void> enregistrerActivite(DateTime date, int nouvelleSerie) {
    final record = nouvelleSerie > serieRecord ? nouvelleSerie : serieRecord;
    return _box.putAll({
      _cleSerieCourante: '$nouvelleSerie',
      _cleSerieRecord: '$record',
      _cleDerniereActivite: date.toIso8601String(),
    });
  }

  Set<String> get badgesDebloques => (_box.get(_cleBadgesDebloques) ?? '')
      .split(',')
      .where((id) => id.isNotEmpty)
      .toSet();

  Future<void> debloquerBadges(List<String> ids) {
    if (ids.isEmpty) return Future.value();
    final fusion = {...badgesDebloques, ...ids};
    return _box.put(_cleBadgesDebloques, fusion.join(','));
  }

  bool dejaAlertePourCeMois(Pilier pilier, DateTime maintenant) =>
      _box.get(_cleAlerte(pilier, maintenant)) == 'oui';

  Future<void> marquerAlertePourCeMois(Pilier pilier, DateTime maintenant) =>
      _box.put(_cleAlerte(pilier, maintenant), 'oui');

  String _cleAlerte(Pilier pilier, DateTime maintenant) =>
      'alerte_${pilier.name}_${maintenant.year}-'
      '${maintenant.month.toString().padLeft(2, '0')}';

  /// Expose le flux de changements de la Box, pour que l'UI (chip de
  /// série, écran des badges) se reconstruise automatiquement.
  ValueListenable<Box<String>> listenable() => _box.listenable();
}
