import 'package:flutter/widgets.dart';

import '../data/models/compte.dart';
import '../data/models/pilier.dart';
import '../data/models/type_mouvement.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

/// Raccourci : `context.l10n.enregistrer` plutôt que
/// `AppLocalizations.of(context).enregistrer` dans chaque widget.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Libellés traduits des énumérations du modèle. Les enums eux-mêmes
/// (data/models) ne connaissent aucune langue : ils sont stockés dans
/// Hive et ne doivent dépendre de rien côté affichage.
extension LibellesEnums on AppLocalizations {
  String libellePilier(Pilier pilier) => switch (pilier) {
    Pilier.epargne => pilierEpargne,
    Pilier.famille => pilierFamille,
    Pilier.vie => pilierVie,
  };

  String libelleTypeCompte(TypeCompte type) => switch (type) {
    TypeCompte.especes => typeCompteEspeces,
    TypeCompte.banque => typeCompteBanque,
    TypeCompte.mobileMoney => typeCompteMobileMoney,
    TypeCompte.epargne => typeCompteEpargne,
  };

  String libelleTypeMouvement(TypeMouvement type) => switch (type) {
    TypeMouvement.depense => depense,
    TypeMouvement.entree => entree,
  };
}
