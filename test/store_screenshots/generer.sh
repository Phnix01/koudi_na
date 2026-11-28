#!/usr/bin/env bash
# Régénère les captures App Store 6,9" (1320×2868) FR et EN, à partir du
# vrai rendu de l'app : ios/fastlane/screenshots/{fr-FR,en-US}/*.png
set -euo pipefail
cd "$(dirname "$0")/../.."
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
for langue in fr en; do
  flutter test test/store_screenshots/captures_store_test.dart \
    --dart-define=LANGUE_CAPTURES=$langue --dart-define=SORTIE_CAPTURES="$tmp"
done
rm -f ios/fastlane/screenshots/fr-FR/*.png ios/fastlane/screenshots/en-US/*.png
python3 -I test/store_screenshots/rgba_vers_png.py "$tmp/fr" ios/fastlane/screenshots/fr-FR
python3 -I test/store_screenshots/rgba_vers_png.py "$tmp/en" ios/fastlane/screenshots/en-US
