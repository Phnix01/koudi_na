# Koudi Na — Guide de déploiement App Store (iOS)

*XNOVA Systems · Flutter 3.41 · Xcode 27.1 (SDK iOS 27) · bundle `com.xnovasystems.koudiNa` · version `1.0.0+1`*
*Exigences Apple vérifiées le 21 octobre 2026 (developer.apple.com : versions minimales, spécifications des captures, outils d'upload).*

Les textes de la fiche (nom, sous-titre, description, mots-clés, FR et EN) sont dans [FICHE_STORE.md](FICHE_STORE.md).

## État du projet

Déjà fait dans le dépôt :

- `ITSAppUsesNonExemptEncryption = false` et `CFBundleLocalizations` fr/en dans `ios/Runner/Info.plist`.
- Cible iOS 15.0 (`ios/Podfile` et `IPHONEOS_DEPLOYMENT_TARGET` dans le pbxproj).
- `ios/Runner/PrivacyInfo.xcprivacy` créé. **À ajouter à la cible Runner dans Xcode** (glisser le fichier dans le groupe Runner, cocher « Runner » dans Target Membership) : un fichier hors cible n'est pas embarqué.

Reste à décider (choix produit, voir section 2) : iPhone seul ou iPad aussi, portrait seul ou paysage autorisé, polices embarquées.

## 1. Prérequis compte et signature

- **Apple Developer Program** (99 $/an) au nom de XNOVA Systems, de préférence en **Organisation** (nom d'éditeur « XNOVA Systems » sur la fiche ; un compte Individuel afficherait le nom de la personne). Un numéro D-U-N-S est exigé pour une organisation.
- **Team ID** : le projet contient déjà `DEVELOPMENT_TEAM = D262K6T5XJ` et `CODE_SIGN_STYLE = Automatic` (`ios/Runner.xcodeproj/project.pbxproj`). Vérifier que c'est bien l'équipe XNOVA et que le compte est ajouté dans Xcode → Settings → Accounts.
- **Signature automatique** : laisser Xcode créer le certificat *Apple Distribution* et le profil *App Store*. Rien à créer à la main. Pour un Mac de CI, exporter le certificat en `.p12` ou utiliser une clé API App Store Connect.
- **App ID** : enregistrer l'identifiant explicite `com.xnovasystems.koudiNa` dans Certificates, Identifiers & Profiles (ou laisser Xcode le faire au premier archive). **Aucune capability** à cocher (pas de push, iCloud, Sign in with Apple…).
- **Bundle ID** : Apple n'accepte que lettres, chiffres, points et tirets ; le `_` de l'ID Android (`com.xnovasystems.koudi_na`) est interdit. Le camelCase `koudiNa` est correct et déjà en place ; **ne plus jamais le changer** après création de la fiche (il est définitif).
- **Créer la fiche** dans App Store Connect → Apps → + : nom « Koudi Na », langue principale Français, Bundle ID `com.xnovasystems.koudiNa`, SKU libre (`KOUDINA-IOS-001`).

## 2. Réglages du projet avant archive

**Exigences Apple en vigueur** : depuis le 28 avril 2026, tout upload doit être compilé avec **Xcode 26+ et le SDK iOS 26+** (Xcode 27.1 est installé : OK). Depuis le 9 septembre 2026, l'app doit **cibler iOS 13 ou plus**.

### Cible iOS minimale → iOS 15.0 (fait)
Flutter 3.41 et les plugins fonctionnent dès iOS 13, mais la branche stable de Flutter ne garantit plus que iOS 15+ : 15.0 évite une migration forcée à la prochaine mise à jour du SDK.

### iPhone uniquement (à décider)
L'app est pensée pour le téléphone. Passer `TARGETED_DEVICE_FAMILY = "1,2";` à `TARGETED_DEVICE_FAMILY = 1;` dans les 3 configurations du pbxproj. Conséquences : plus de captures iPad obligatoires et plus d'obligation de supporter toutes les orientations iPad. L'app reste installable sur iPad en mode compatibilité : vérifier qu'elle ne plante pas (les reviewers testent souvent sur iPad).

### Orientation (à décider)
L'écran de saisie et les graphiques ne sont pas conçus pour le paysage. Pour verrouiller le portrait, remplacer dans `Info.plist` le tableau `UISupportedInterfaceOrientations` par le seul `UIInterfaceOrientationPortrait`, et supprimer `UISupportedInterfaceOrientations~ipad` si l'app devient iPhone-only. Faire la même chose côté Android (`android:screenOrientation="portrait"` dans le manifest) pour rester cohérent.

### Info.plist
Déjà présent et correct : `CFBundleDisplayName` = `Koudi Na`, `CFBundleShortVersionString = $(FLUTTER_BUILD_NAME)`, `CFBundleVersion = $(FLUTTER_BUILD_NUMBER)`, `ITSAppUsesNonExemptEncryption = false` (aucun chiffrement propriétaire ; l'app n'utilise même pas HTTPS, qui serait de toute façon exempté), `CFBundleLocalizations` fr/en.
**Aucune clé `NS…UsageDescription`** : l'app ne demande aucune permission (`file_picker` et `share_plus` passent par les pickers système, hors sandbox, sans autorisation).

### Version et build
`pubspec.yaml` → `version: 1.0.0+1` : `1.0.0` devient `CFBundleShortVersionString` (visible sur le store), `1` devient `CFBundleVersion`. **Le build number doit augmenter à chaque upload** vers App Store Connect, même pour une même version marketing : `1.0.0+2`, `1.0.0+3`… Un build déjà utilisé est rejeté à l'upload. Ne pas toucher `MARKETING_VERSION`/`CURRENT_PROJECT_VERSION` dans le pbxproj (ils ne concernent que `RunnerTests`).

### Manifeste de confidentialité (`PrivacyInfo.xcprivacy`)
Obligatoire depuis mai 2024 pour les **API à motif requis** (horodatage de fichiers, UserDefaults, espace disque, boot time). État du projet, vérifié dans le cache pub et le moteur :
- **Flutter.framework** embarque son manifeste : `FileTimestamp` (C617.1, 0A2A.1) et `SystemBootTime` (35F9.1). Cela couvre les accès fichiers de `dart:io` utilisés par Hive et le CSV.
- **share_plus 12.0.2** et **file_picker 11.0.3** : manifestes présents (aucune API à motif requis, `NSPrivacyTracking = false`).
- **path_provider_foundation 2.6.0** : manifeste ajouté par le plugin.
- **hive_ce_flutter, fl_chart, flutter_animate, intl, google_fonts** : Dart pur, pas de code natif, rien à déclarer.
- **Code natif du Runner** (`AppDelegate.swift`, `SceneDelegate.swift`) : n'appelle aucune API listée.

L'app n'est donc **pas tenue** d'avoir son propre manifeste. Par sécurité (et pour que le rapport de confidentialité généré par Xcode soit propre), `ios/Runner/PrivacyInfo.xcprivacy` existe avec quatre sections vides. Si un jour l'app lit `UserDefaults` (ex. `shared_preferences`), ajouter la catégorie `NSPrivacyAccessedAPICategoryUserDefaults` avec le motif `CA92.1`. Contrôle : Xcode → Organizer → archive → **Generate Privacy Report** ; aucun avertissement `ITMS-91053` ne doit arriver par mail après l'upload.

### Google Fonts : supprimer le seul appel réseau (à faire)
`google_fonts` télécharge Inter et Sora au premier lancement (`lib/core/theme/app_theme.dart`) : contradiction avec « 100 % hors ligne » et police système affichée si l'utilisateur n'a pas de réseau au premier lancement. Correctif :
1. Télécharger les `.ttf` (Inter, Sora, licence OFL) dans `google_fonts/` et les déclarer dans `pubspec.yaml` (`flutter: assets: - google_fonts/`) ; le package détecte les fichiers embarqués et ne fait plus de requête.
2. Dans `main()` : `GoogleFonts.config.allowRuntimeFetching = false;` (lève une erreur en debug si une police manque, au lieu de la télécharger).
3. Ajouter les licences OFL au `LicenseRegistry` (le package le propose dans son README).

### App Transport Security
Rien à ajouter : aucune connexion réseau, donc aucune exception `NSAppTransportSecurity`. Ne pas en ajouter « au cas où » (cela déclenche une question de review).

## 3. Construire et envoyer l'archive

```bash
cd /Users/a1111/Documents/Projets_Clients_XNOVA/koudi_na
flutter clean
flutter pub get
dart run flutter_launcher_icons        # seulement si l'icône a changé
flutter build ipa --release --export-method app-store-connect
```
`flutter build ipa` exécute `pod install`, archive, signe et exporte. Résultats :
- Archive : `build/ios/archive/Runner.xcarchive`
- IPA : `build/ios/ipa/koudi_na.ipa`

Un `ExportOptions.plist` n'est nécessaire que pour forcer des options (signature manuelle, `uploadSymbols`) : `--export-options-plist=ios/ExportOptions.plist`. Avec la signature automatique, inutile.

**Upload — trois voies valides en 2026 :**
1. **Transporter** (Mac App Store, gratuit) : glisser `koudi_na.ipa`, *Deliver*. Le plus simple et le plus fiable.
2. **Xcode Organizer** : ouvrir `Runner.xcarchive` → *Distribute App* → *App Store Connect* → *Upload*.
3. **Ligne de commande** : `xcrun altool --upload-app` est **déprécié** ; Apple le remplace par `--upload-package` (`notarytool` ne sert qu'à la notarisation macOS, pas à l'App Store) :
```bash
xcrun altool --upload-package build/ios/ipa/koudi_na.ipa --type ios \
  --apple-id <Apple ID numérique de l'app, visible dans App Store Connect > App Information> \
  --bundle-id com.xnovasystems.koudiNa \
  --bundle-short-version-string 1.0.0 --bundle-version 1 \
  --apiKey <KEY_ID> --apiIssuer <ISSUER_ID>
```
(clé API App Store Connect placée dans `~/.appstoreconnect/private_keys/AuthKey_<KEY_ID>.p8`). Alternative sans altool : `xcodebuild -exportArchive` avec `destination = upload` dans l'ExportOptions.

**TestFlight avant review** : le build apparaît sous *TestFlight* après 10–30 min de traitement. Installer sur un iPhone réel sans réseau (mode avion) : onboarding, saisie, graphiques, export CSV via feuille de partage, import CSV via le picker, changement de langue. Puis seulement l'attacher à la version 1.0.0 et soumettre.

## 4. Fiche App Store Connect

| Champ | Limite | Koudi Na |
|---|---|---|
| Nom | 30 car. | voir FICHE_STORE.md |
| Sous-titre | 30 | voir FICHE_STORE.md |
| Texte promotionnel | 170 | Modifiable sans nouvelle version ; voir FICHE_STORE.md |
| Description | 4000 | voir FICHE_STORE.md ; pas de promesses chiffrées |
| Mots-clés | 100 (virgules, sans espace) | voir FICHE_STORE.md |
| URL d'assistance | **obligatoire** | Page XNOVA avec un e-mail de contact fonctionnel |
| URL marketing | optionnel | |
| URL politique de confidentialité | **obligatoire** (5.1.1 i) | Voir ci-dessous |
| Copyright | | `2026 XNOVA Systems` |
| Catégorie | | Principale **Finance** ; secondaire **Productivité** (facultatif) |

**Politique de confidentialité** (une page, FR + EN, hébergée sur un domaine XNOVA) : identité de l'éditeur ; « Koudi Na ne collecte, ne transmet et ne partage aucune donnée ; toutes les données sont stockées uniquement sur l'appareil, dans la base locale de l'application » ; aucun compte, aucun service tiers, aucun suivi publicitaire ; les fichiers CSV exportés sont sous le contrôle de l'utilisateur ; suppression = désinstallation de l'app ; contact ; date. Le lien doit aussi être **accessible dans l'app** (écran Réglages, section À propos à ajouter) — guideline 5.1.1 (i).

**Confidentialité de l'app (App Privacy)** : répondre **« Non, nous ne collectons pas de données »** → étiquette *Data Not Collected*. C'est honnête car le critère d'Apple est la sortie des données de l'appareil : Hive est local, aucune requête réseau (une fois les polices embarquées), aucun analytics ni rapport de plantage. Si un SDK (Firebase, Sentry…) est ajouté plus tard, l'étiquette devra être refaite.

**Classification par âge** (questionnaire 2026, obligatoire : 4+/9+/13+/16+/18+) : tout à « Aucun / Non » : pas de jeux de hasard simulés ni réels, pas de concours, pas de contenu médical, pas d'accès web illimité, pas de contenu généré par les utilisateurs, pas de messagerie, pas de publicité, aucun contrôle intégré. Résultat attendu : **4+**. « Made for Kids » : *Non applicable*.

**Conformité à l'exportation** : « Non » (ou la question n'apparaît plus grâce à `ITSAppUsesNonExemptEncryption=false`). **Droits de contenu** : « Non, l'app ne contient pas de contenu tiers » (polices OFL incluses sous licence, ce n'est pas du « contenu »). **Publicité (IDFA)** : Non.

**Notes pour la review** (2.3.1 a — être précis) :
> Koudi Na est un gestionnaire de budget personnel entièrement hors ligne. Aucun compte, aucune connexion : ouvrez l'app, passez l'onboarding (4 écrans) et commencez à saisir. Les données sont stockées localement (base Hive). La « règle 40/25/35 » est une méthode de répartition du revenu mensuel en trois piliers (Épargne 40 %, Famille 25 %, Vie 35 %) ; l'app classe les dépenses dans ces piliers et affiche les écarts. Montants en FCFA (franc CFA). Export CSV via la feuille de partage iOS ; import CSV via le sélecteur de fichiers. L'app ne propose ni transfert d'argent, ni prêt, ni compte bancaire, ni conseil financier : « mobile money » y désigne seulement un type de compte que l'utilisateur suit lui-même. Interface disponible en français et en anglais (réglable dans Réglages). Contact : <email>.

**Captures d'écran** (spécifications Apple vérifiées, max 10 par taille, PNG/JPEG **sans couche alpha**, prises dans l'app réelle — 2.3.3) :
- **Obligatoire** : *iPhone avec Dynamic Island (écran moyen)* : **1179 × 2556** ou **1206 × 2622** px (portrait).
- Recommandé en plus : *Dynamic Island (grand écran)* : 1290 × 2796 ou 1320 × 2868 px ; sinon Apple met à l'échelle automatiquement les autres tailles iPhone.
- **iPad 13"** (2064 × 2752 ou 2048 × 2732) : obligatoire **uniquement si l'app tourne sur iPad** → avec `TARGETED_DEVICE_FAMILY = 1`, rien à fournir.
- À venir : captures « iPhone Duo » (pliable) exigées à partir d'avril 2027 pour les apps compilées avec le SDK iOS 27.1+.
- Fournir un jeu **français** et un jeu **anglais** (localisation de la fiche). Prendre les captures sur simulateur iPhone 17 Pro (`Cmd+S`) ou via `flutter screenshot`.
- **Aperçu vidéo** : optionnel ; s'il est fourni, uniquement de la capture d'écran de l'app (2.3.4), 15–30 s.

## 5. Formulations à éviter (risque de rejet)

| Formulation à éviter | Guideline | Pourquoi | Alternative sûre |
|---|---|---|---|
| « L'app n°1 », « la meilleure app de budget » | 2.3.7 | Affirmation invérifiable | « Une app de budget simple, pensée pour le FCFA » |
| « Économisez 50 000 FCFA par mois », « résultats garantis » | 2.3.1 (a) | Promesse de résultat trompeuse | « Visualisez où part votre argent chaque mois » |
| « Votre banque », « portefeuille », « wallet » pour désigner l'app | 3.2.1 (viii) / 3.1.5 | Laisse croire que l'app détient ou transfère des fonds ; exigerait des licences | « Suivi de budget », « carnet de dépenses » ; « compte » uniquement pour décrire un compte que l'utilisateur suit |
| « Conseils financiers », « nous vous disons quoi investir » | 3.2.1 (viii) | Conseil/gestion financière réservés aux établissements agréés | « Outil de suivi et de répartition de votre budget » |
| « Prêt », « crédit », « transfert d'argent », « crypto » | 3.2.2 (ix), 3.1.5, 5.3 | Activités réglementées ; mention sans licence = rejet ou demande de justificatifs | Ne pas mentionner ; l'app n'en fait pas |
| « Disponible sur Android », « Google Play », « Play Store » | 2.3.10 | Interdit dans les métadonnées iOS | Rien, ou « Disponible sur iPhone » |
| « Bêta », « version test », « bientôt disponible », « démo », « à venir » | 2.1, 2.3.1 | L'app doit être complète ; les fonctions annoncées doivent exister | Décrire uniquement ce qui est livré |
| « Lorem ipsum », « TODO », « Description à venir » | 2.1 / 2.3.1 | Fiche incomplète = rejet immédiat | Texte final relu |
| « Gratuit pour toujours », « 0 FCFA » dans captures ou sous-titre | 2.3.7 | Le prix ne doit pas figurer dans les métadonnées non tarifaires | Prix géré dans l'onglet Tarification uniquement |
| « Koudi Na pour iPhone », « Apple Budget » dans le nom | 2.3.7, 5.2.5 | Marques Apple interdites dans le nom/icône | Nom = « Koudi Na » |
| Mots-clés : « Wave », « Orange Money », « Mint », « YNAB », « Revolut » | 2.3.7 | Bourrage avec marques tierces | Mots génériques : budget, dépenses, fcfa |
| Captures retouchées, maquettes, écrans qui n'existent pas, écran de connexion | 2.3.3 | Les captures montrent l'app réelle en usage | Captures brutes + éventuel texte d'accroche superposé |
| « Nous analysons vos données pour… », « synchronisation cloud » | 5.1.1 / 5.1.2 | Contredit l'étiquette *Data Not Collected* | « Vos données restent sur votre téléphone » |
| « Pour enfants », « For kids » | 2.3.8 | Réservé à la catégorie Kids | Ne pas cibler les enfants |
| Montants/chiffres sensibles dans captures (RIB, vrais noms) | 2.3.8, 5.1 | Métadonnées tout public, pas de données personnelles | Données fictives, prénoms génériques |

## 6. Checklist finale avant « Soumettre »

1. Polices Inter/Sora embarquées, `allowRuntimeFetching = false`, test en mode avion OK.
2. `Podfile` → `platform :ios, '15.0'` ; `IPHONEOS_DEPLOYMENT_TARGET = 15.0` (fait) ; `TARGETED_DEVICE_FAMILY = 1` si iPhone seul.
3. `Info.plist` : `ITSAppUsesNonExemptEncryption=false`, `CFBundleLocalizations` fr/en (fait) ; orientation tranchée.
4. `ios/Runner/PrivacyInfo.xcprivacy` ajouté à la cible Runner ; rapport de confidentialité Xcode sans avertissement.
5. `pubspec.yaml` version incrémentée (`1.0.0+N`, N jamais réutilisé).
6. `flutter clean && flutter pub get && flutter build ipa --release --export-method app-store-connect` sans erreur ; upload via Transporter.
7. Build testé sur TestFlight sur iPhone réel (FR et EN, onboarding, export + import CSV, iPad en compatibilité).
8. Fiche : nom, sous-titre, description, mots-clés, URL support, URL politique de confidentialité (en ligne et testée), catégorie Finance, copyright — en FR et EN.
9. Captures 1179 × 2556 (ou 1206 × 2622) sans alpha, FR et EN, montrant l'app réelle.
10. Questionnaire d'âge 2026 complété (4+), App Privacy = « Data Not Collected », export compliance = Non, droits de contenu = Non.
11. Notes pour la review rédigées (hors ligne, règle 40/25/35, FCFA, aucune identification requise).
12. Relecture anti-rejet avec le tableau de la section 5, puis **Soumettre pour examen** (prévoir 24–48 h).
