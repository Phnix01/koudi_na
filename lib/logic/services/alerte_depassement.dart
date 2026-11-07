import '../../data/models/pilier.dart';
import 'calcul_piliers.dart';

/// Fonction pure : parmi les piliers en dépassement ce mois-ci
/// (`progression > 1.0`), renvoie ceux pour lesquels aucune alerte n'a
/// encore été montrée ce mois-ci (selon [dejaAlerte]). Chaque pilier
/// n'est donc alerté qu'une seule fois par mois, quel que soit le
/// nombre de retours au premier plan de l'app.
List<Pilier> piliersEnDepassementNonAlertes(
  List<ProgressionPilier> progressions,
  bool Function(Pilier pilier) dejaAlerte,
) {
  return progressions
      .where((p) => p.progression > 1.0 && !dejaAlerte(p.pilier))
      .map((p) => p.pilier)
      .toList();
}
