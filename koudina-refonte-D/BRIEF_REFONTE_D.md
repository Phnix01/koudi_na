# Koudi Na — Brief de refonte « D · Fusion » pour Claude Code

> À lire en entier avant de toucher au code. Les fichiers `reference/*.dc.html` sont les maquettes validées : ce sont des pages HTML statiques/interactives qui contiennent **toutes les valeurs exactes** (couleurs, tailles, espacements, rayons, textes). En cas de doute entre ce brief et la maquette, **la maquette fait foi**. Les captures d'écran envoyées par Omar servent de vue d'ensemble.

## 0. Objectif

Refondre l'UI de Koudi Na (Flutter, 100 % hors ligne) selon la direction **D · Fusion** :
- l'esthétique **claire, sobre, typographique** de la direction A (fond cassé #F5F5F2, encre #111113, un seul accent vert, police Geist, chiffres tabulaires) ;
- la **structure** de la direction B (écran d'accueil riche, barre d'onglets avec bouton **+** central, saisie en écran dédié avec grille de catégories visible sans défilement).

Contraintes produit :
- **Saisir une dépense en moins de 15 s**, sans défilement, pour des utilisateurs peu habitués aux apps.
- Usage local (Niger, FCFA) **et** international (FR/EN) — aucun texte en dur.
- **Aucune** dépendance réseau ajoutée (l'app est « 100 % hors ligne »).
- **Ne pas modifier la logique métier ni le schéma de données** sauf où ce brief le demande explicitement (§6).

## 1. Méthode de travail (obligatoire)

Travaille par phases. **À la fin de chaque phase : `flutter analyze` propre, tests existants verts, captures iPhone (390×844 logique) de chaque écran touché, puis arrêt pour validation d'Omar.** Ne passe pas à la phase suivante sans son feu vert.

- **Phase 0 — Exploration (aucune modification).** Lis le repo et rends un rapport court : arborescence `lib/`, gestion d'état utilisée, navigation (Navigator/go_router…), stockage local, modèles (transaction, catégorie, compte, récurrence, badge), où vit la règle 40/25/35 et le mapping catégorie → enveloppe, où sont calculés solde/projection, librairie de graphiques, l10n en place (ARB ?), thème actuel. Liste les fichiers que tu comptes modifier/créer. Propose le plan détaillé. **Stop.**
- **Phase 1 — Fondations.** Tokens de design (§2) dans un `ThemeExtension` + `ThemeData` clair ; police Geist **embarquée en assets** (pas de chargement réseau) ; helpers de formatage montant ; composants de base (§3). Aucun écran ne change encore visuellement, sauf si nécessaire. **Stop.**
- **Phase 2 — Navigation + Saisie.** Shell avec barre d'onglets à 5 positions et bouton + ; bottom sheet « Nouvelle opération » ; nouvel écran Saisie (§4.2, §4.3). C'est la phase la plus importante : teste la saisie de bout en bout (enregistrement réel en base). **Stop.**
- **Phase 3 — Accueil** (§4.1) avec les vrais calculs (§5). **Stop.**
- **Phase 4 — Journal** (§4.4). **Stop.**
- **Phase 5 — Analyse** (§4.5) + correction du graphique. **Stop.**
- **Phase 6 — Données & libellés** (§6) : catégories localisées, comptes Mobile money / Coffre, migration. **Stop.**
- **Phase 7 — Finitions** : états vides, accessibilité (§8), revue des écrans non refondus (Réglages, badges…) pour qu'ils ne détonnent pas (tokens uniquement, pas de refonte). **Stop.**

Règles : commits petits et nommés par phase ; pas de nouvelle dépendance sans le signaler ; pas de suppression de fonctionnalité existante (streak, badges, récurrences, export/import CSV, rappels, langue, devise).

## 2. Design tokens

### Couleurs — thème clair (actif)
| Token | Valeur | Usage |
|---|---|---|
| `bg` | `#F5F5F2` | fond d'écran |
| `surface` | `#FFFFFF` | cartes, touches du pavé, chips non sélectionnés |
| `surfaceMuted` | `#EAEAE5` | segmented control, fond d'icône neutre, bouton rond |
| `track` | `#E4E4DF` | rail des barres de progression |
| `line` | `#E6E6E1` | bordures, séparateurs (1 px) |
| `lineStrong` | `#E0E0DA` | bordure chips comptes non sélectionnés |
| `ink` | `#111113` | texte principal, CTA, bouton +, sélection |
| `ink2` | `#3A3A3F` | texte secondaire fort |
| `muted` | `#6E6E73` | libellés, sous-titres (contraste ≥ 4.5:1 sur `bg`) |
| `disabled` | `#B5B5B0` | montant à 0 |
| `positive` | `#0E7A4F` | entrées, « reste », projection favorable, enveloppe Épargne |
| `positiveTint` | `#DDEFE5` | fond d'icône d'une entrée |
| `family` | `#2F5BD3` | enveloppe Famille |
| `streak` | `#C2410C` | flamme du streak |
| `scrim` | `rgba(17,17,19,0.40)` | fond derrière le bottom sheet |

### Couleurs de catégories (icône / fond teinté quand sélectionné)
Alimentation `#B45309`/`#FDF1DF` · Transport `#2F5BD3`/`#E6EDFB` · Data & Télécom `#7C4DCC`/`#F0E9FB` · Loyer & charges `#C2410C`/`#FCEAE2` · Famille `#BE3A78`/`#FBE7F0` · Épargne `#0E7A4F`/`#E0F1E8` · Projets `#0F766E`/`#DEF2EF` · Formation `#1D4ED8`/`#E4ECFC` · Santé `#BE123C`/`#FBE4E9` · Vêtements `#A16207`/`#FBF1D9` · Sadaqa & Deen `#8A6A2F`/`#F3ECDF` · Divers `#5F5F66`/`#ECECE8`.
Catégories d'entrée : Salaire `#0E7A4F` · Freelance `#2F5BD3` · Don reçu `#BE3A78` · Autre `#5F5F66` (mêmes teintes).
→ Stocker la couleur **dans le modèle catégorie** (ou une table de correspondance par id), pas dans les widgets.

### Thème sombre (à préparer, pas à livrer)
Déclarer les mêmes tokens en sombre pour la suite : `bg #09090B`, `surface #141417`, `surfaceMuted #1C1C21`, `line #26262C`, `ink`(texte) `#F5F5F4`, `muted #9A9AA3`, `positive #5EE08F`. Le CTA devient clair sur sombre. Ne pas activer tant qu'Omar n'a pas validé.

### Typographie
- **Geist** (400/500/600/700), fichiers TTF dans `assets/fonts/`, déclarés dans `pubspec.yaml`. Si `google_fonts` est utilisé : `GoogleFonts.config.allowRuntimeFetching = false` + fichiers en assets.
- **Tous les montants** : `FontFeature.tabularFigures()`.
- Échelle : montant héro 54–60 (w600, letterSpacing ≈ −2.6) · titres d'écran 26 (w600, −0.6) · titres de section 15 (w600) · corps 14–15 (w500) · libellés 12–13 (w400/500, `muted`) · tab labels 11.
- Unité « FCFA » toujours plus petite (17–18, w500, `muted`) que le nombre.

### Formes & espacements
- Marges latérales d'écran : **20** (Saisie : 16).
- Rayons : cartes 18–20 · CTA et touches 14–16 · chips 12 ou pill · sheet 28 (haut) · tuiles catégorie 16.
- Pas d'ombres portées, sauf le segment actif : `0 1px 2px rgba(0,0,0,.08)` ; touches du pavé : liseré bas `0 1px 0 #E0E0DA`.
- **Interdits** (pour éviter le « look app IA ») : dégradés décoratifs, glassmorphism, anneaux de progression, emoji, cartes avec bordure gauche colorée, grille bento systématique.
- Zones tactiles ≥ 44 px.

## 3. Composants à créer (réutilisables)

1. `AppScaffoldShell` — barre d'onglets : **Accueil · Journal · [+] · Analyse · Réglages**. Hauteur 84 (dont safe area), fond `bg`, filet haut `line`. Onglet actif : icône + label `ink` w600 ; inactifs `muted`. Le **+** : bouton 56×46, rayon 16, fond `ink`, icône blanche ; il ouvre le sheet (pas un onglet).
2. `NewOperationSheet` — bottom sheet blanc, rayon 28 en haut, poignée 36×5, titre « Nouvelle opération », 2 lignes de 72 px (fond `bg`, rayon 18) : **Dépense** (pastille `ink`, icône −, sous-titre « Repas, transport, data, famille… ») et **Entrée** (pastille `positive`, icône +, « Salaire, freelance, don reçu… »), chevron à droite. Tap → ouvre Saisie avec le type correspondant **pré-sélectionné**.
3. `AmountText` — nombre + unité, formatage §5.1.
4. `ProgressLine` — rail 4 ou 8 px, rayon plein, remplissage couleur, option marqueur vertical (cf. barre de rythme).
5. `TransactionRow` — 52–56 px : pastille 36–38 (fond teinté catégorie, icône couleur catégorie ; entrée = `positiveTint`/`positive`), titre w500, sous-titre « Catégorie · Compte » ou « Date · Compte » en `muted`, montant à droite w600 (entrée en `positive` avec « + », dépense en `ink` avec « − »). Séparateur 1 px `line`.
6. `SegmentedPill` — fond `surfaceMuted`, padding 3, segment actif blanc + ombre légère.
7. `CategoryTile` — voir §4.3.
8. `NumericKeypad` — 3×4 : 1-9, **000**, 0, ⌫. Touches 50 px, fond `surface`, rayon 14, liseré bas. Retour haptique léger (`HapticFeedback.selectionClick`).

Icônes : un seul set linéaire cohérent (trait ~1.8), p.ex. Lucide (`lucide_icons`) ou Phosphor *regular* — choisis celui déjà présent s'il y en a un, sinon propose-le en Phase 1. Correspondances : Alimentation = bol/utensils, Transport = voiture, Data = wifi, Loyer = maison, Famille = users, Épargne = tirelire, Projets = trending-up, Formation = livre ouvert, Santé = cœur, Vêtements = t-shirt, Sadaqa & Deen = croissant de lune, Divers = 3 points.

## 4. Écrans

### 4.1 Accueil (`reference/D-Accueil.dc.html`)
De haut en bas, **sans grille bento** :
1. **En-tête** : sélecteur de mois « Novembre 2026 ▾ » (16 w600) à gauche ; pastille streak « 🔥-icône 12 jours » à droite (fond blanc, bordure `line`, flamme `streak`).
2. **Héros** : « Solde du mois » (13 `muted`) puis le solde en très grand (54, w600) + « FCFA ». Solde négatif → affiché avec « − » (couleur `ink`, pas de rouge criard).
3. **Entrées | Dépenses** sur 2 colonnes séparées par un filet vertical : « +350 000 » en `positive`, « −186 500 » en `ink`.
4. **Barre de rythme** (8 px) : remplissage `ink` = dépenses ÷ entrées ; **marqueur vertical vert** = jour du mois ÷ nb de jours. Dessous, gauche : « 53 % des entrées dépensées » ; droite (vert) : « jour 24 / 30 · tu es en avance » (ou « attention au rythme » en `streak` si ratio dépenses > ratio temps).
5. **Deux cartes** (blanc, bordure `line`, rayon 18) :
   - **Fin de mois** : « ≈ 212 000 », sous-titre « 138 000 sous tes entrées » (vert) ou « X au-dessus de tes entrées » ; flèche ↗ ; tap → Analyse.
   - **Moyenne par jour** : « 7 770 », sous-titre « 3 600 hors épargne ».
6. **Enveloppes** (titre + « 40 · 25 · 35 » à droite) : 3 lignes « Épargne · 71 % — reste 40 000 » avec `ProgressLine` 4 px (Épargne `positive`, Famille `family`, Vie `ink`).
7. **Récents** (titre + « Tout voir » → Journal) : 2 dernières opérations.
Tout doit tenir au-dessus de la barre d'onglets sur un iPhone 390×844 ; sur petits écrans, l'écran défile (le contenu est dans un `ListView`/`CustomScrollView`, pas de `overflow`).

### 4.2 Sheet « Nouvelle opération »
Voir composant 2. Ouvert par le **+** depuis Accueil, Journal et Analyse.

### 4.3 Saisie (`reference/D-Saisie.dc.html`) — **ZÉRO défilement**
Écran plein (route modale), de haut en bas :
1. **Barre** : bouton rond « ✕ » (40, fond `surfaceMuted`) · segmented **Dépense | Entrée** (2×96) · bouton rond calendrier (date, défaut aujourd'hui → date picker).
2. **Montant** centré : signe (− `muted` / + `positive`) + nombre 60 w600 + « FCFA ». À 0 : couleur `disabled`. Dessous : « Alimentation · il te restera **151 000** » (valeur verte, recalculée en direct = solde du mois ∓ montant saisi).
3. **Grille de catégories 4 colonnes** (12 tuiles en dépense, 4 en entrée), tuiles 62 px : icône 21 colorée + libellé court 11. Non sélectionnée : fond blanc, bordure invisible, libellé `#55555B`. **Sélectionnée : fond teinté de la catégorie + bordure 1.5 px de la couleur catégorie + libellé `ink` w600.** Libellés courts : Repas, Transport, Data, Logement, Famille, Épargne, Projets, Formation, Santé, Habits, Sadaqa, Divers.
4. **Comptes** (4 chips égaux, 38 px) : Banque · Mobile money · Espèces · Coffre ; sélectionné = fond `ink` texte blanc. + bouton carré « note » (ouvre un champ texte en sheet).
5. **Pavé numérique** collé en bas (`Spacer` au-dessus).
6. **CTA** 56 px : « Enregistrer −2 500 FCFA » (fond `ink` en dépense, `positive` en entrée) ; désactivé si montant = 0 (« Saisis un montant », fond `#E3E3DE`).

Comportements :
- Type pré-sélectionné selon le choix du sheet.
- **Pré-sélection de la dernière catégorie et du dernier compte utilisés** (par type) → une dépense répétée = 3 gestes.
- Saisie : max 9 chiffres ; « 000 » ignoré si montant vide ; ⌫ efface le dernier chiffre.
- Après enregistrement : retour à l'écran d'origine + SnackBar « Dépense enregistrée · Annuler » (annulation = suppression de l'opération créée). Mettre à jour le streak comme aujourd'hui.
- Le layout doit tenir sur iPhone SE (667 px) : si la hauteur manque, réduire hauteur tuiles (54) et touches (44) via `LayoutBuilder`, **jamais** de scroll.

### 4.4 Journal (`reference/D-Journal.dc.html`)
Titre « Journal » + loupe (recherche plein texte sur titre/note). Sélecteur de mois dans une barre blanche (‹ Novembre 2026 ›). Ligne de 3 chiffres : Entrées / Dépenses / Solde. Filtres pills : **Tout · Dépenses · Entrées** (fonctionnels) + « Filtres ▾ » (catégorie, compte — réutilise les filtres existants). Liste groupée par jour : en-tête « Aujourd'hui · mar. 24 nov. » + total du jour à droite, puis `TransactionRow`. Tap sur une ligne → édition (existant). Swipe gauche → supprimer (avec confirmation) si déjà supporté.

### 4.5 Analyse (`reference/D-Analyse.dc.html`)
Titre « Analyse » + segmented **Mois · 6 mois · Année**.
1. **Projection** : sur-titre vert « ↗ PROJECTION », phrase 21 px : « Au rythme actuel, tu termineras novembre à environ **212 000 FCFA** de dépenses, soit **138 000 sous tes entrées**. » (variante si au-dessus).
2. **Carte « Entrées et dépenses »** : **histogramme groupé** (pas de courbe) par mois, barres 14 px rayon haut 4 : entrées `#D6D6D0`, dépenses `ink`, **mois courant en `positive`**. Légende carrée en haut à droite, mois en bas, mois courant en gras.
3. **« Où va l'argent · novembre »** : top 4 catégories, chaque ligne = nom, montant + « · 54 % », barre 6 px `ink` proportionnelle à la plus grosse. « Tout voir » → liste complète.
4. Conserver l'« Astuce du jour » existante sous ces blocs si elle existe (style : texte simple, icône ampoule, pas de carte jaune).

## 5. Calculs (réutiliser l'existant quand il existe)

5.1 **Formatage** : séparateur de milliers = espace insécable fine ` ` (FR) via `NumberFormat.decimalPattern('fr')` ; EN suit la locale. Signe moins typographique `−` (U+2212). Unité selon la devise des Réglages.
5.2 **Solde du mois** = Σ entrées − Σ dépenses du mois sélectionné.
5.3 **Rythme** : `ratioDépense = dépenses / entrées` (si entrées = 0 → masquer la barre, cf. §7) ; `ratioTemps = jourCourant / joursDuMois` ; « en avance » si `ratioDépense ≤ ratioTemps`.
5.4 **Projection fin de mois** = `dépenses / jourCourant × joursDuMois` (pour un mois passé : total réel). Arrondi au millier.
5.5 **Moyenne par jour** = `dépenses / jourCourant` ; « hors épargne » exclut la (les) catégorie(s) de l'enveloppe Épargne et les transferts vers le Coffre.
5.6 **Enveloppes 40/25/35** : budget = entrées × 40 % / 25 % / 35 % ; consommé = Σ dépenses des catégories mappées à l'enveloppe (**utilise le mapping déjà codé** ; s'il n'existe pas, propose-le à Omar en Phase 0 au lieu de l'inventer). Reste = budget − consommé (peut être négatif → afficher « dépassé de X » en `streak`).
5.7 Tous ces calculs dans une couche de services/view-models testée (tests unitaires sur 5.2–5.6).

## 6. Données & libellés

- **Catégories** : aujourd'hui en anglais (« Food », « Bank account »…) alors que l'UI est en FR → passer par l'l10n (ARB FR/EN) avec des **clés stables** (`cat_food`, …). FR : Alimentation, Transport, Data & Télécom, Loyer & charges, Famille, Épargne, Projets, Formation, Santé, Vêtements, Sadaqa & Deen, Divers (+ libellés courts pour la grille). Les catégories personnalisées créées par l'utilisateur gardent leur nom.
- **Comptes** : renommer « Savings » → **Coffre** (lève l'ambiguïté avec la catégorie Épargne), « Bank account » → Banque, « Cash » → Espèces ; **ajouter « Mobile money »**. Migration sans perte : on garde les IDs, on change les libellés ; vérifier que l'import CSV accepte anciens et nouveaux noms.
- Catégories d'entrée : Salaire, Freelance, Don reçu, Autre (si le modèle ne distingue pas encore catégories de dépense/entrée, le signaler en Phase 0).

## 7. Bugs de l'existant à corriger

1. Saisie : le bouton Enregistrer recouvre la 2ᵉ rangée de catégories (libellés invisibles) et il faut défiler → résolu par §4.3.
2. Graphique 12 mois : la courbe lissée passe **sous zéro** (dépassement de spline) → remplacé par l'histogramme ; si une courbe reste ailleurs : `isCurved: false` ou `preventCurveOverShooting: true` (fl_chart).
3. Donut « Répartition » : le texte central chevauche l'anneau → remplacé par les barres horizontales.
4. Règle 40/25/35 affiche « 0 FCFA / 0 FCFA » sans entrée → état vide : « Ajoute ta première entrée du mois pour activer la règle 40 · 25 · 35 » + bouton « Ajouter une entrée ».
5. En-tête actuel surchargé (streak + solde + 3 icônes) → remplacé par la barre d'onglets.

## 8. Accessibilité & qualité

- Libellés sémantiques (`Semantics`) sur boutons icône (+, ✕, calendrier, note, loupe, ⌫).
- Contraste texte ≥ 4.5:1 (déjà respecté par les tokens).
- Respecter le `textScaleFactor` jusqu'à 1.3 sans casse (l'écran Saisie peut réduire les tailles, pas déborder).
- Pas de bannière DEBUG sur les captures de validation.

## 9. Critères d'acceptation

- [ ] Saisir « 2 500, Repas, Espèces » depuis l'Accueil en ≤ 4 taps après le +, sans défilement, sur iPhone 17 Pro **et** iPhone SE.
- [ ] Les 4 écrans correspondent visuellement aux maquettes (comparaison côte à côte des captures).
- [ ] Solde, rythme, projection, moyenne, enveloppes : valeurs justes, couvertes par des tests unitaires.
- [ ] Aucune chaîne en dur ; FR et EN complets.
- [ ] Données existantes intactes après migration ; export/import CSV OK.
- [ ] `flutter analyze` sans warning, tests verts.

## 10. Hors périmètre (prochaines itérations)
Thème sombre, onboarding / visite guidée, écran badges, Réglages refondus, widgets iOS/Android de saisie rapide.

---

### Prompt de démarrage à coller dans Claude Code

> Lis `BRIEF_REFONTE_D.md` et les maquettes `reference/*.dc.html` (ouvre-les comme du HTML : les styles inline donnent les valeurs exactes). Exécute uniquement la **Phase 0** : explore le projet sans rien modifier et rends-moi le rapport + le plan détaillé décrits au §1. Attends ma validation avant toute modification.
