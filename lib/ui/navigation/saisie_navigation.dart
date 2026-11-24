import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/badges.dart';
import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';
import '../../l10n/l10n.dart';
import '../../logic/providers/repositories_providers.dart';
import '../screens/saisie_screen.dart';
import '../widgets/dialogue_badge_debloque.dart';

/// La Saisie monte du bas en fondu, comme une feuille qui prend tout
/// l'écran (route modale : pas de barre d'onglets en dessous).
Route<ResultatSaisie> routeSaisie(Widget ecran) => PageRouteBuilder<ResultatSaisie>(
  fullscreenDialog: true,
  transitionDuration: const Duration(milliseconds: 340),
  reverseTransitionDuration: const Duration(milliseconds: 240),
  pageBuilder: (_, _, _) => ecran,
  transitionsBuilder: (_, animation, _, child) {
    final courbe = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
    return FadeTransition(
      opacity: courbe,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(courbe),
        child: child,
      ),
    );
  },
);

/// Ouvre la Saisie d'une nouvelle opération, puis gère son résultat.
Future<void> ouvrirSaisie(BuildContext context, TypeMouvement type) async {
  final resultat = await Navigator.of(context, rootNavigator: true).push(
    routeSaisie(SaisieScreen.nouvelle(type: type)),
  );
  if (resultat != null && context.mounted) await gererResultatSaisie(context, resultat);
}

/// Ouvre une opération existante dans la Saisie (modifier ou supprimer).
Future<void> ouvrirEdition(BuildContext context, Transaction transaction) async {
  final resultat = await Navigator.of(context, rootNavigator: true).push(
    routeSaisie(SaisieScreen.modifier(transaction: transaction)),
  );
  if (resultat != null && context.mounted) await gererResultatSaisie(context, resultat);
}

/// Après la Saisie : carte de badge s'il y en a un, puis une SnackBar
/// qui permet d'annuler (brief §4.3) : supprimer l'opération créée, ou
/// restaurer celle qui vient d'être supprimée.
Future<void> gererResultatSaisie(BuildContext context, ResultatSaisie resultat) async {
  final l10n = context.l10n;
  final repo = ProviderScope.containerOf(context, listen: false).read(transactionRepositoryProvider);
  final transaction = resultat.transaction;

  if (resultat.nouveauxBadges.isNotEmpty) {
    final langue = Localizations.localeOf(context).languageCode;
    final badge = badgesDisponibles.firstWhere((b) => b.id == resultat.nouveauxBadges.first);
    await afficherDeblocageBadge(context, badge, langue);
    if (!context.mounted) return;
  }

  final String message;
  final Future<void> Function()? annuler;
  if (resultat.suppression) {
    message = l10n.transactionSupprimee;
    annuler = () => repo.enregistrer(transaction);
  } else if (resultat.modification) {
    message = l10n.saisieOperationModifiee;
    annuler = null;
  } else {
    message = transaction.type == TypeMouvement.depense
        ? l10n.saisieDepenseEnregistree
        : l10n.saisieEntreeEnregistree;
    annuler = () => repo.supprimer(transaction.id);
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        action: annuler == null ? null : SnackBarAction(label: l10n.annuler, onPressed: annuler),
      ),
    );
}
