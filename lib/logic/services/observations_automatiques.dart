import '../../core/utils/formatters.dart';
import '../../data/models/categorie.dart';
import '../../data/models/compte.dart';
import '../../data/models/pilier.dart';
import '../../data/models/transaction.dart';
import '../../l10n/app_localizations.dart';
import 'calcul_piliers.dart';
import 'comparaison_mensuelle.dart';
import 'indicateurs_analyse.dart';

/// Génère de courtes phrases d'observation (section 5.3) : aucune IA,
/// aucun réseau, juste des comparaisons de seuils sur les calculs déjà
/// faits ailleurs (comparaison mensuelle, indicateurs, règle 40/25/35).
/// Contrairement aux autres services de ce dossier, celui-ci produit
/// directement des chaînes prêtes à afficher — c'est tout son rôle,
/// pas un détail d'implémentation à cacher à l'appelant. Les phrases
/// viennent de [l10n], dans la langue courante de l'application.
List<String> genererObservations(
  List<Transaction> transactions,
  List<Categorie> categories,
  List<Compte> comptes,
  AppLocalizations l10n, {
  DateTime? maintenant,
}) {
  final reference = maintenant ?? DateTime.now();
  final observations = <String>[];

  final comparaison = calculerComparaisonMensuelle(
    transactions,
    categories,
    maintenant: reference,
  );
  final hausses =
      comparaison
          .where(
            (c) => c.variationPourcent != null && c.variationPourcent! >= 20,
          )
          .toList()
        ..sort((a, b) => b.variationPourcent!.compareTo(a.variationPourcent!));
  if (hausses.isNotEmpty) {
    final plusForteHausse = hausses.first;
    observations.add(
      l10n.obsHausse(
        plusForteHausse.categorie.libelle,
        plusForteHausse.variationPourcent!.round(),
      ),
    );
  }

  final indicateurs = calculerIndicateurs(
    transactions,
    categories,
    comptes,
    maintenant: reference,
  );
  if (indicateurs.projectionDepasseEntrees) {
    final depassement =
        indicateurs.projectionFinDeMois - indicateurs.entreesMois;
    observations.add(l10n.obsDepassement(formaterMontant(depassement)));
  }

  final moisConsecutifs = _moisConsecutifsObjectifEpargne(
    transactions,
    categories,
    reference,
  );
  if (moisConsecutifs >= 2) {
    observations.add(l10n.obsObjectifEpargne(moisConsecutifs));
  }

  if (indicateurs.autonomieFinanciereMois > 0) {
    observations.add(
      l10n.obsAutonomie(formaterDecimal(indicateurs.autonomieFinanciereMois)),
    );
  }

  return observations;
}

/// Compte, en remontant depuis le mois de référence, combien de mois
/// consécutifs le pilier épargne a atteint sa cible (40 % des entrées
/// par défaut) — s'arrête au premier mois manqué.
int _moisConsecutifsObjectifEpargne(
  List<Transaction> transactions,
  List<Categorie> categories,
  DateTime reference,
) {
  var compte = 0;
  for (var i = 0; i < 12; i++) {
    final mois = DateTime(reference.year, reference.month - i);
    final progression = calculerProgressionPiliers(
      transactions,
      categories,
      maintenant: mois,
    );
    final epargne = progression.firstWhere((p) => p.pilier == Pilier.epargne);
    if (epargne.objectifMontant > 0 && epargne.progression >= 1.0) {
      compte++;
    } else {
      break;
    }
  }
  return compte;
}
