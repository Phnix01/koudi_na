import 'package:flutter/material.dart' show DateTimeRange;

import '../../data/models/transaction.dart';

/// Les trois façons de borner un export (écran Export, Réglages).
enum PeriodeExport { moisCourant, tout, personnalisee }

/// Filtre pur — aucun accès disque ni widget — pour rester testable
/// indépendamment de l'écran qui l'appelle. `plage` n'est utilisée que
/// pour [PeriodeExport.personnalisee] ; les bornes sont inclusives et
/// comparées au jour près (pas à l'heure exacte).
List<Transaction> filtrerParPeriode(
  List<Transaction> transactions,
  PeriodeExport periode,
  DateTimeRange? plage,
) {
  switch (periode) {
    case PeriodeExport.tout:
      return transactions;
    case PeriodeExport.moisCourant:
      final maintenant = DateTime.now();
      return transactions
          .where(
            (t) =>
                t.date.year == maintenant.year &&
                t.date.month == maintenant.month,
          )
          .toList();
    case PeriodeExport.personnalisee:
      if (plage == null) return const [];
      final debut = DateTime(plage.start.year, plage.start.month, plage.start.day);
      final fin = DateTime(
        plage.end.year,
        plage.end.month,
        plage.end.day,
        23,
        59,
        59,
      );
      return transactions
          .where((t) => !t.date.isBefore(debut) && !t.date.isAfter(fin))
          .toList();
  }
}
