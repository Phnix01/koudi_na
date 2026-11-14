#!/usr/bin/env bash
# Release iOS : fiche générée par les agents → relecture → build → envoi.
#
#   tool/store/release_ios.sh                    tout : agents, relecture, build IPA, envoi IPA + fiche
#   tool/store/release_ios.sh --fiche-seulement  agents, relecture, envoi de la fiche seule
#   tool/store/release_ios.sh --sans-agents      réutilise la fiche déjà présente (après retouche à la main)
#
# Rien ne part chez Apple sans un « o » tapé après lecture du diff.
set -euo pipefail
cd "$(dirname "$0")/../.."

LANE=release
GENERER=1
for arg in "$@"; do
  case "$arg" in
    --fiche-seulement) LANE=fiche ;;
    --sans-agents) GENERER=0 ;;
    *) sed -n '2,8p' "$0"; exit 2 ;;
  esac
done

META=ios/fastlane/metadata

if [[ $GENERER == 1 ]]; then
  if ! python3 tool/store/generer_fiche.py; then
    echo
    echo "Au moins une langue a échoué (voir build/fiche_store/<langue>.md)."
    echo "Les langues validées sont écrites ; relance avec --locales pour réessayer les autres."
    exit 1
  fi
fi

echo
echo "================ Changements de la fiche ================"
git --no-pager diff --stat -- "$META"
git --no-pager diff -- "$META"
while IFS= read -r fichier; do
  [[ -n "$fichier" ]] || continue
  echo
  echo "+++ nouveau : $fichier"
  cat "$fichier"
  echo
done < <(git ls-files --others --exclude-standard -- "$META")
if compgen -G "build/fiche_store/*.md" >/dev/null; then
  echo
  echo "Remarques des relecteurs : build/fiche_store/<langue>.md"
fi
echo "=========================================================="

# Prérequis vérifiés avant de demander quoi que ce soit : un build de
# plusieurs minutes ne doit pas échouer à l'envoi pour une clé manquante.
[[ -f ios/fastlane/.env ]] && set -a && source ios/fastlane/.env && set +a
manque=()
[[ -n "${ASC_KEY_ID:-}" && -n "${ASC_ISSUER_ID:-}" ]] || manque+=("ASC_KEY_ID / ASC_ISSUER_ID (voir ios/fastlane/.env.exemple)")
if [[ -n "${ASC_KEY_ID:-}" ]]; then
  cle="${ASC_KEY_PATH:-$HOME/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8}"
  [[ -f "$cle" ]] || manque+=("fichier de clé $cle")
fi
(cd ios && bundle check >/dev/null 2>&1) || manque+=("fastlane : lancer « cd ios && bundle install »")
if (( ${#manque[@]} )); then
  echo
  echo "Fiche prête dans $META, mais envoi impossible, il manque :"
  printf '  - %s\n' "${manque[@]}"
  exit 0
fi

echo
read -r -p "Envoyer vers App Store Connect ($LANE) ? [o/N] " reponse
if [[ "$reponse" != "o" && "$reponse" != "O" ]]; then
  echo "Rien n'a été envoyé. La fiche reste modifiable dans $META (relancer avec --sans-agents)."
  exit 0
fi

if [[ $LANE == release ]]; then
  # Flutter 3.41 réutilise build/native_assets/ios (objective_c.framework,
  # tiré par path_provider_foundation) sans distinguer iPhone et simulateur :
  # après un lancement sur simulateur, l'IPA embarquerait la version
  # simulateur et planterait au démarrage sur tout iPhone réel.
  rm -rf build/native_assets/ios
  flutter build ipa --release --export-method app-store-connect
  fw=build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/Frameworks/objective_c.framework/objective_c
  if [[ -f "$fw" ]] && ! xcrun vtool -show-build "$fw" | grep -qE "platform IOS$"; then
    echo "objective_c.framework n'est pas compilé pour iPhone dans l'archive : envoi annulé."
    exit 1
  fi
  # Sinon le prochain lancement sur simulateur reprendrait la version iPhone.
  rm -rf build/native_assets/ios
fi
cd ios && bundle exec fastlane "$LANE"
