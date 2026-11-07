/// Calcule la nouvelle série de jours actifs consécutifs après une
/// saisie. Fonction pure : compare des dates calendaires (sans
/// l'heure), ne touche à aucun stockage.
///
/// - Pas de série précédente : on en démarre une (`1`).
/// - Même jour calendaire que la dernière activité : série inchangée
///   (ou démarrée à `1` si elle était encore à `0`).
/// - Exactement un jour d'écart : la série continue (`+1`).
/// - Plus d'un jour d'écart : la série est rompue, on repart à `1`.
int calculerNouvelleSerie(
  DateTime? derniereActivite,
  DateTime aujourdHui,
  int serieActuelle,
) {
  if (derniereActivite == null) return 1;

  final ecart = _joursEntre(derniereActivite, aujourdHui);
  if (ecart == 0) return serieActuelle == 0 ? 1 : serieActuelle;
  if (ecart == 1) return serieActuelle + 1;
  return 1;
}

int _joursEntre(DateTime a, DateTime b) {
  final jourA = DateTime(a.year, a.month, a.day);
  final jourB = DateTime(b.year, b.month, b.day);
  return jourB.difference(jourA).inDays;
}
