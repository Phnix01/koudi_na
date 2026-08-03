import 'package:intl/intl.dart';

import '../../core/utils/formatters.dart';
import '../../data/models/categorie.dart';
import '../../data/models/compte.dart';
import '../../data/models/pilier.dart';
import '../../data/models/transaction.dart';
import 'calcul_piliers.dart';
import 'comparaison_mensuelle.dart';
import 'indicateurs_analyse.dart';

/// Génère de courtes phrases d'observation en français (section 5.3) :
/// aucune IA, aucun réseau, juste des comparaisons de seuils sur les
/// calculs déjà faits ailleurs (comparaison mensuelle, indicateurs,
/// règle 40/25/35). Contrairement aux autres services de ce dossier,
/// celui-ci produit directement des chaînes prêtes à afficher — c'est
/// tout son rôle, pas un détail d'implémentation à cacher à l'appelant.
List<String> genererObservations(
  List<Transaction> transactions,
  List<Categorie> categories,
  List<Compte> comptes, {
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
      'Tes dépenses en ${plusForteHausse.categorie.libelle} ont augmenté de ${plusForteHausse.variationPourcent!.round()} % ce mois-ci.',
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
    observations.add(
      "Au rythme actuel, tu dépasseras tes entrées de ${formaterMontant(depassement)} d'ici la fin du mois.",
    );
  }

  final moisConsecutifs = _moisConsecutifsObjectifEpargne(
    transactions,
    categories,
    reference,
  );
  if (moisConsecutifs >= 2) {
    observations.add(
      "Tu as respecté ton objectif d'épargne $moisConsecutifs mois de suite.",
    );
  }

  if (indicateurs.autonomieFinanciereMois > 0) {
    observations.add(
      'Ton épargne couvre désormais ${NumberFormat('0.0', 'fr_FR').format(indicateurs.autonomieFinanciereMois)} mois de dépenses.',
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
