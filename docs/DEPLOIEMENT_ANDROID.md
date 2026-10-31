# Koudi Na — Guide de déploiement Google Play (Android)

*XNOVA Systems · Flutter 3.41 · applicationId `com.xnovasystems.koudi_na` · version `1.0.0+1`*

Les textes de la fiche (nom, description, mots-clés, FR et EN) sont dans [FICHE_STORE.md](FICHE_STORE.md). Ce guide est le pendant Android de [DEPLOIEMENT_IOS.md](DEPLOIEMENT_IOS.md) ; les deux partagent la même politique de confidentialité et la même fiche produit.

## État du projet

Déjà fait dans le dépôt :

- Signature de release configurée (`android/app/build.gradle.kts` charge `android/key.properties`, qui pointe vers un keystore). **Avant le premier build**, voir la section 1 : le keystore et `key.properties` existent déjà sur cette machine mais ne sont *pas* dans git (volontairement — voir pourquoi ci-dessous) et doivent être sauvegardés ailleurs.
- `android:screenOrientation="portrait"` posé sur `MainActivity` (cohérent avec le choix portrait-only pris côté iOS).
- `applicationId = "com.xnovasystems.koudi_na"` (confirmé — différent du bundle iOS `com.xnovasystems.koudiNa` uniquement parce qu'Apple interdit le `_`).
- `minSdk`/`targetSdk`/`compileSdk` gérés automatiquement par le plugin Gradle de Flutter (actuellement 24 / 36 / 36 avec Flutter 3.41) : rien à fixer à la main, ils suivent la version de Flutter installée.

Reste à faire, hors code : compte Google Play Console, fiche store complète, captures d'écran, questionnaires (voir section 3).

## 1. Signature de release — à sauvegarder immédiatement

Un keystore **`android/upload-keystore.jks`** a été généré pour XNOVA Systems (alias `koudi_na_upload`, validité 10 000 jours). Les mots de passe sont dans **`android/key.properties`** (fichier local, non versionné : `android/key.properties`, `android/*.jks` sont dans `.gitignore`).

**Pourquoi ces deux fichiers ne sont pas dans git** : un keystore de release contient la clé privée qui signe l'app ; s'il fuite dans l'historique git (même supprimé plus tard, l'historique le garde), n'importe qui peut publier une mise à jour malveillante qui se fait passer pour Koudi Na. Et si ce fichier est perdu sans sauvegarde, il devient impossible de publier une nouvelle version de l'app sous le même listing Google Play.

**À faire dès maintenant, avant de continuer** :
1. Copier `android/upload-keystore.jks` et `android/key.properties` vers un gestionnaire de mots de passe ou un stockage chiffré de l'équipe XNOVA (pas seulement sur ce Mac).
2. Si plusieurs personnes doivent pouvoir builder une release, leur transmettre ces deux fichiers par un canal sécurisé (jamais par e-mail en clair ni par Slack public) ; chacun les place à l'identique sous `android/`.
3. Lors de la création de la fiche sur Play Console, **activer Play App Signing** (actif par défaut pour toute nouvelle app) : Google conserve alors la clé de signature finale de l'app, et la clé d'upload (celle de ce keystore) peut être régénérée par Google si elle est perdue — ce qui n'est pas possible sans Play App Signing.

## 2. Construire et envoyer

Google Play exige un **Android App Bundle (.aab)**, pas un APK, pour toute nouvelle app :

```bash
cd /Users/a1111/Developer/koudi_na
flutter clean
flutter pub get
dart run flutter_launcher_icons        # seulement si l'icône a changé
flutter build appbundle --release
```

Résultat : `build/app/outputs/bundle/release/app-release.aab`.

**Version et build** : `pubspec.yaml` → `version: 1.0.0+1` ; `1.0.0` devient le nom de version visible, `1` devient le `versionCode`. **Le `versionCode` doit augmenter à chaque upload**, exactement comme le build number iOS — les deux peuvent d'ailleurs rester synchronisés en incrémentant le même nombre après le `+` dans `pubspec.yaml` pour les deux plateformes à la fois.

**Upload** : Play Console → votre app → *Production* (ou *Test interne* d'abord, recommandé) → *Créer une version* → glisser le `.aab`.

**Test avant publication** : créer une piste de *test interne* (jusqu'à 100 testeurs par e-mail, pas de délai de review), installer sur un téléphone Android réel en mode avion : onboarding, saisie, graphiques, export CSV via le partage, import CSV via le sélecteur de fichiers, changement de langue. Promouvoir ensuite vers *Production*.

## 3. Fiche Google Play Console

| Champ | Où | Koudi Na |
|---|---|---|
| Nom de l'app | Présence sur le Store | voir FICHE_STORE.md (30 car.) |
| Description courte | Présence sur le Store | voir FICHE_STORE.md (80 car. max — réutiliser le texte promotionnel iOS, raccourci si besoin) |
| Description complète | Présence sur le Store | voir FICHE_STORE.md (4000 car. max) |
| Catégorie | Présence sur le Store | **Finance** |
| Coordonnées (e-mail) | Présence sur le Store | `contact@xnovasystems.com` — **à remplacer par une boîte réellement surveillée avant soumission** |
| URL politique de confidentialité | Présence sur le Store | Même URL que côté iOS, voir DEPLOIEMENT_IOS.md section 4 : `https://claude.ai/artifact/Y3yFsKPSZjrWnGNcpFRgis` (provisoire, à migrer vers un domaine XNOVA) |
| Icône | Présence sur le Store | PNG 512×512, 32 bits, générée par `flutter_launcher_icons` (reprendre `assets/icon/app_icon.png` à l'export) |
| Image de présentation (feature graphic) | Présence sur le Store | **Obligatoire**, 1024×500 PNG/JPEG, pas de texte essentiel (recadrée selon l'appareil) — à créer, aucun équivalent requis côté Apple |
| Captures d'écran téléphone | Présence sur le Store | **2 minimum, 8 max** recommandées ; JPEG/PNG 24 bits, chaque côté entre 320 px et 3840 px, ratio entre 16:9 et 9:16. Les captures iPhone ne sont pas réutilisables (ratio différent) : en prendre des nouvelles sur un émulateur/téléphone Android, FR et EN. |

**Data safety (sécurité des données)** : le questionnaire équivalent à *App Privacy* d'Apple. Répondre : l'app **ne collecte aucune donnée** et **ne partage aucune donnée** avec des tiers. Cocher qu'aucune donnée n'est chiffrée en transit (vrai : il n'y a pas de transit, aucune requête réseau) et qu'il n'y a pas de mécanisme de suppression de compte (pas de compte). Cette déclaration doit rester cohérente avec `DEPLOIEMENT_IOS.md` (*Data Not Collected*) — toute SDK ajoutée plus tard (crash reporting, analytics) oblige à refaire les deux déclarations.

**Classification du contenu (IARC)** : questionnaire rempli en ligne sur Play Console, mêmes réponses que la classification d'âge Apple (aucune violence, aucun contenu généré par les utilisateurs, aucune transaction d'argent réel entre utilisateurs, aucune publicité). Résultat attendu : **PEGI 3 / Tout public**.

**Audience cible et contenu pour enfants** : tranche d'âge **18 ans et plus / tout public sauf enfants**, « Cette application n'est pas conçue principalement pour les enfants ».

**Publicités** : déclarer **« Non, mon application ne contient pas de publicités »**.

**Accès aux données et autorisations** : l'app ne demande aucune permission Android sensible (pas de caméra, localisation, contacts, stockage externe au-delà du sélecteur de fichiers système) — rien à déclarer de particulier dans la section *Permissions*.

**Conformité de la famille d'applications aux États-Unis (US export)** : non applicable, pas de chiffrement propriétaire.

## 4. Points communs avec iOS à garder synchronisés

- **Politique de confidentialité** : même page, même contenu FR/EN pour les deux stores (voir DEPLOIEMENT_IOS.md section 4). Toute modification du texte doit être republiée aux deux endroits (Réglages → À propos dans l'app pointe vers une seule URL partagée entre iOS et Android, dans `lib/ui/screens/reglages_screen.dart`).
- **Contact** : même adresse `contact@xnovasystems.com` utilisée dans l'app, les deux fiches store et la politique de confidentialité.
- **Version marketing** : garder `1.0.0` identique sur les deux plateformes au lancement ; les numéros de build (`+N`) peuvent diverger ensuite selon le rythme de publication de chaque store.
- **Formulations à éviter** : le tableau de la section 5 de `DEPLOIEMENT_IOS.md` s'applique aussi à la fiche Google Play (mêmes risques de rejet : promesses chiffrées, mots « wallet »/« banque », marques tierces dans les mots-clés, mentions Android/iOS croisées à retirer selon la plateforme).

## 5. Checklist finale avant publication

1. Keystore et `key.properties` sauvegardés hors de cette machine (section 1). **(à faire avant tout — bloquant)**
2. Play App Signing activé sur la fiche Play Console.
3. `flutter build appbundle --release` sans erreur ; `.aab` signé avec le bon keystore (vérifiable avec `jarsigner -verify` ou en comparant l'empreinte SHA-256 affichée par Play Console à celle du keystore).
4. `pubspec.yaml` `versionCode` incrémenté si une version a déjà été envoyée.
5. Testé en piste interne sur un appareil Android réel (FR et EN, onboarding, export + import CSV, mode avion).
6. Fiche complète : nom, descriptions courte/longue, catégorie Finance, icône 512×512, feature graphic 1024×500, captures Android réelles (FR et EN), e-mail de contact fonctionnel, URL politique de confidentialité en ligne.
7. Data safety = aucune collecte/partage, classification de contenu IARC remplie, audience cible réglée, publicités = non.
8. Soumission pour review (délai Google Play généralement de quelques heures à quelques jours, variable).
