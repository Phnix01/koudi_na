import 'package:flutter/material.dart' show DateUtils;
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

/// « Novembre 2026 » (majuscule initiale, `DateFormat` écrit « novembre »).
String libelleMois(DateTime mois) {
  final brut = DateFormat.yMMMM().format(mois);
  return brut.isEmpty ? brut : brut[0].toUpperCase() + brut.substring(1);
}

/// « novembre » seul, pour les phrases (« tu termineras novembre… »).
String nomMois(DateTime mois) => DateFormat.MMMM().format(mois);

/// « Aujourd'hui », « Hier », sinon « 20 nov. ».
String libelleJourCourt(DateTime jour, AppLocalizations l10n, {DateTime? maintenant}) {
  final ref = maintenant ?? DateTime.now();
  if (DateUtils.isSameDay(jour, ref)) return l10n.aujourdhui;
  if (DateUtils.isSameDay(jour, ref.subtract(const Duration(days: 1)))) return l10n.hier;
  return DateFormat.MMMd().format(jour);
}

/// En-tête de groupe du Journal : « Aujourd'hui · mar. 24 nov. »,
/// « Hier · lun. 23 nov. », « ven. 20 nov. ».
String libelleJourComplet(DateTime jour, AppLocalizations l10n, {DateTime? maintenant}) {
  final ref = maintenant ?? DateTime.now();
  final date = DateFormat.MMMEd().format(jour);
  if (DateUtils.isSameDay(jour, ref)) return '${l10n.aujourdhui} · $date';
  if (DateUtils.isSameDay(jour, ref.subtract(const Duration(days: 1)))) return '${l10n.hier} · $date';
  return date;
}
