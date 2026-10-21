# Koudi Na

Application Flutter de suivi des dépenses personnelles (Niger / Afrique de l'Ouest), construite autour de la règle 40/25/35 : chaque mois, les entrées sont réparties entre Épargne (40 %), Famille (25 %) et Vie (35 %).

- Stockage local Hive, aucun compte ni réseau.
- Disponible en français et en anglais (choix dans Réglages, ou langue du téléphone).
- Identifiant d'application : `com.xnovasystems.koudi_na`.

## Démarrer

```sh
flutter pub get          # génère aussi lib/l10n/app_localizations.dart
flutter run
```

## Traductions

Les textes vivent dans `lib/l10n/app_fr.arb` (référence) et `lib/l10n/app_en.arb`. Après modification : `flutter gen-l10n`.

## Icône de lancement

Source : `assets/icon/app_icon.svg`. Régénérer toutes les plateformes avec `dart run flutter_launcher_icons`.
