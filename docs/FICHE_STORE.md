# Fiche App Store — Koudi Na

La fiche App Store vit dans `ios/fastlane/metadata/`, un dossier par langue, un fichier `.txt` par champ (`name`, `subtitle`, `promotional_text`, `description`, `keywords`, `release_notes`, `privacy_url`). C'est ce dossier que fastlane envoie à App Store Connect.

> Avant toute modification, relire la section « Formulations à éviter » de [DEPLOIEMENT_IOS.md](DEPLOIEMENT_IOS.md). Les agents s'en servent aussi : elle est lue directement depuis ce fichier.

## Qui écrit quoi

| Langue | Dossier | Écrite par |
|---|---|---|
| Français (langue principale) | `fr-FR` | À la main : **source** de toutes les autres |
| Anglais | `en-US` | À la main, sert de référence aux agents |
| Espagnol (Espagne / Amérique latine) | `es-ES`, `es-MX` | Agents |
| Portugais (Brésil) | `pt-BR` | Agents |
| Arabe | `ar-SA` | Agents |
| Allemand | `de-DE` | Agents |
| Italien | `it` | Agents |

Pour changer le message de la fiche : modifier `fr-FR` (et `en-US`), puis relancer les agents. Ne pas retoucher une langue générée à la main sans raison : la retouche serait écrasée à la génération suivante.

L'interface de l'app n'existe qu'en français et en anglais. Les fiches des autres langues le disent honnêtement ; l'ajout de ces langues dans l'app est une étape séparée.

## Lancer la génération

```bash
tool/store/release_ios.sh --fiche-seulement   # générer, relire, envoyer la fiche seule
tool/store/release_ios.sh                     # générer, relire, construire l'IPA, envoyer IPA + fiche
python3 tool/store/generer_fiche.py --locales pt-BR,it   # régénérer quelques langues, sans envoi
```

Pour chaque langue, un agent **rédacteur** adapte la fiche française au marché (consignes dans `tool/store/marches.json`), un script vérifie les règles mesurables (limites de caractères, format des mots-clés, termes interdits), puis un agent **relecteur** natif juge la conformité Apple et la qualité de la langue. Tant qu'il reste un problème bloquant, le rédacteur réécrit avec ses retours, en 3 tours au maximum. Une langue qui échoue n'est jamais écrite.

Les notes de version (« Nouveautés ») sont rédigées à partir des commits depuis le dernier tag git ; à la première version, il n'y en a pas (Apple ne les affiche pas). **Taguer chaque version publiée** (`git tag v1.0.0`) pour que la suivante ait ses notes.

Rien ne part chez Apple sans un « o » tapé après lecture du diff dans le terminal. Le détail des remarques des relecteurs est dans `build/fiche_store/<langue>.md`.

## Ce qui fait foi

- `tool/store/faits_produit.md` : seules fonctionnalités que la fiche a le droit d'affirmer. **À mettre à jour à chaque nouvelle fonctionnalité visible**, sinon les agents ne la mentionneront pas (ou le relecteur la refusera).
- `tool/store/marches.json` : public, ton et devises à mettre en avant par langue. Ajouter une langue = ajouter une entrée ici.
- `tool/store/prompts/` : consignes des trois agents.

## Prérequis

- La CLI `claude` connectée (abonnement Claude Code). Modèle : alias `opus` par défaut, modifiable via `KOUDI_STORE_MODELE`. `claude update` pour profiter du dernier modèle.
- Pour l'envoi : clé API App Store Connect dans `ios/fastlane/.env` (modèle : `ios/fastlane/.env.exemple`) et `cd ios && bundle install`.
- Hors fiche, une seule fois dans App Store Connect : URL d'assistance, catégorie d'âge, App Privacy, prix. Les captures d'écran ne sont pas encore envoyées par ce pipeline : sans captures propres à une langue, Apple affiche celles de la langue principale.
