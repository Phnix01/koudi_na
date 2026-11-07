import 'package:flutter/foundation.dart';

/// Une astuce financière courte, affichée sur l'écran Analyse. Même
/// principe que `devises.dart`/`badges.dart` : les textes sont des
/// champs Dart simples, pas des clés ARB — inutile d'alourdir les
/// fichiers de traduction pour ~25 phrases statiques.
@immutable
class AstuceInfo {
  const AstuceInfo({required this.texteFr, required this.texteEn});

  final String texteFr;
  final String texteEn;
}

const List<AstuceInfo> astucesDisponibles = [
  AstuceInfo(
    texteFr:
        'La règle 40/25/35 fonctionne mieux quand elle est appliquée dès '
        "que l'argent arrive, pas à la fin du mois.",
    texteEn:
        'The 40/25/35 rule works best when applied as soon as money comes '
        'in, not at the end of the month.',
  ),
  AstuceInfo(
    texteFr:
        'Enregistrer une dépense tout de suite prend moins de temps que de '
        "s'en souvenir le soir.",
    texteEn:
        'Recording an expense right away takes less time than trying to '
        'remember it in the evening.',
  ),
  AstuceInfo(
    texteFr:
        "Une petite dépense répétée chaque jour pèse souvent plus qu'une "
        'grosse dépense ponctuelle.',
    texteEn:
        'A small expense repeated every day often weighs more than one '
        'big one-off expense.',
  ),
  AstuceInfo(
    texteFr:
        "L'épargne mise de côté en premier a plus de chances d'être "
        'respectée que celle qui reste "si possible" en fin de mois.',
    texteEn:
        'Savings set aside first are more likely to stick than savings '
        'left for "whatever is left" at the end of the month.',
  ),
  AstuceInfo(
    texteFr:
        "Comparer deux mois d'affilée révèle souvent une habitude qu'un "
        'seul mois ne montre pas.',
    texteEn:
        'Comparing two consecutive months often reveals a habit a single '
        "month doesn't show.",
  ),
  AstuceInfo(
    texteFr:
        'Classer une transaction dans la bonne catégorie, même approximative, '
        'vaut mieux que la laisser sans catégorie.',
    texteEn:
        'Filing a transaction under a roughly-right category beats '
        'leaving it uncategorized.',
  ),
  AstuceInfo(
    texteFr:
        'Un objectif de dépense atteint deux mois de suite devient '
        'beaucoup plus facile à tenir le troisième mois.',
    texteEn:
        'A spending target hit two months in a row becomes much easier to '
        'keep the third month.',
  ),
  AstuceInfo(
    texteFr:
        "Les dépenses liées à la famille varient plus que celles liées à "
        "la vie quotidienne : c'est normal, le pilier famille absorbe les "
        'imprévus.',
    texteEn:
        'Family-related expenses vary more than everyday ones: that is '
        'normal, the family pillar absorbs the unexpected.',
  ),
  AstuceInfo(
    texteFr:
        'Revoir ses comptes récurrents une fois par mois évite les '
        'abonnements oubliés.',
    texteEn:
        'Reviewing recurring transactions once a month helps catch '
        'forgotten subscriptions.',
  ),
  AstuceInfo(
    texteFr:
        "Un dépassement ponctuel n'annule pas un mois : ce qui compte est "
        'la tendance sur plusieurs mois.',
    texteEn:
        "A one-off overspend doesn't ruin a month: what matters is the "
        'trend across several months.',
  ),
  AstuceInfo(
    texteFr:
        "Noter une courte note sur une grosse dépense aide à s'en souvenir "
        "au moment de l'analyse, des semaines plus tard.",
    texteEn:
        'A short note on a big expense helps you remember why, weeks '
        'later, when reviewing it.',
  ),
  AstuceInfo(
    texteFr:
        'Séparer les comptes (espèces, mobile money, banque) donne une '
        'vision plus honnête de ce qui reste réellement disponible.',
    texteEn:
        'Separating accounts (cash, mobile money, bank) gives a more '
        "honest picture of what's actually available.",
  ),
  AstuceInfo(
    texteFr:
        'Exporter ses transactions en PDF une fois par mois crée une trace '
        "utile, même sans l'utiliser tout de suite.",
    texteEn:
        'Exporting transactions to PDF once a month creates a useful '
        'record, even if unused right away.',
  ),
  AstuceInfo(
    texteFr:
        "Le pilier vie quotidienne est souvent celui qui dérive le plus "
        'discrètement : les petites dépenses répétées passent inaperçues.',
    texteEn:
        'The everyday-life pillar often drifts the most quietly: small '
        'repeated expenses go unnoticed.',
  ),
  AstuceInfo(
    texteFr:
        'Se fixer un jour fixe dans la semaine pour relire ses dépenses '
        "vaut mieux que de ne jamais s'y replonger.",
    texteEn:
        'Picking one fixed day a week to review spending beats never '
        'looking back at it.',
  ),
  AstuceInfo(
    texteFr:
        'Une entrée ponctuelle exceptionnelle (prime, cadeau) ne devrait '
        "pas changer durablement le rythme de dépense habituel.",
    texteEn:
        "A one-off exceptional income (bonus, gift) shouldn't permanently "
        'change your usual spending rhythm.',
  ),
  AstuceInfo(
    texteFr:
        "Comparer ses dépenses à un objectif chiffré motive plus qu'un "
        'simple "je devrais dépenser moins".',
    texteEn:
        'Comparing spending to a concrete target motivates more than a '
        'vague "I should spend less".',
  ),
  AstuceInfo(
    texteFr:
        'Un compte qui ne sert presque jamais vaut la peine d\'être '
        "archivé plutôt que de rester dans la liste.",
    texteEn:
        "An account that's almost never used is worth archiving rather "
        'than left cluttering the list.',
  ),
  AstuceInfo(
    texteFr:
        "Les dépenses de début de mois donnent souvent le ton du mois "
        "entier : les surveiller tôt change plus de choses qu'à la fin.",
    texteEn:
        'Early-month spending often sets the tone for the whole month: '
        'watching it early changes more than watching it late.',
  ),
  AstuceInfo(
    texteFr:
        "Un budget tenu à 90% reste un succès : viser 100% au centime "
        'près décourage plus souvent qu\'il n\'aide.',
    texteEn:
        'A budget kept at 90% is still a success: aiming for an exact '
        '100% discourages more often than it helps.',
  ),
  AstuceInfo(
    texteFr:
        'Les catégories trop larges ("divers") cachent souvent la vraie '
        'source de dépassement.',
    texteEn:
        'Overly broad categories ("misc") often hide the real source of '
        'overspending.',
  ),
  AstuceInfo(
    texteFr:
        "Décider à l'avance du pilier d'une dépense inhabituelle est plus "
        'fiable que de la classer après coup, à chaud.',
    texteEn:
        "Deciding an unusual expense's pillar in advance is more reliable "
        'than classifying it after the fact, in the heat of the moment.',
  ),
  AstuceInfo(
    texteFr:
        "L'écran Analyse montre des tendances sur plusieurs mois : un seul "
        "mois inhabituel ne doit pas inquiéter à lui seul.",
    texteEn:
        "The Analysis screen shows multi-month trends: a single unusual "
        "month shouldn't be alarming on its own.",
  ),
  AstuceInfo(
    texteFr:
        "Donner un nom clair à chaque compte (plutôt que « Compte 1 ») "
        "évite les erreurs de saisie au fil des mois.",
    texteEn:
        'Giving each account a clear name (rather than "Account 1") '
        'avoids entry mistakes over the months.',
  ),
  AstuceInfo(
    texteFr:
        "Un petit excédent d'épargne un mois peut compenser un léger "
        'dépassement le mois suivant : la vue d\'ensemble compte.',
    texteEn:
        'A small savings surplus one month can offset a slight overspend '
        'the next: the big picture is what matters.',
  ),
];

String astuceDuJour(DateTime maintenant, String langue) {
  final jourDeLAnnee = maintenant
      .difference(DateTime(maintenant.year, 1, 1))
      .inDays;
  final astuce =
      astucesDisponibles[jourDeLAnnee % astucesDisponibles.length];
  return langue == 'en' ? astuce.texteEn : astuce.texteFr;
}
