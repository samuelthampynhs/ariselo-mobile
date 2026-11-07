#!/usr/bin/env bash
# Makes the ios/ and android/ folders (flutter create) for one of the two apps:
#
#   scripts/platforms.sh dev  [ios,android]   "Ariselo Dev"  uk.co.ariselo.app.dev  dev.ariselo.co.uk
#   scripts/platforms.sh prod [ios,android]   "Ariselo"      uk.co.ariselo.app      ariselo.co.uk
#
# Same code, different app: its own name, store listing and ID, so both fit on one phone.
# The site it talks to is chosen when building (--dart-define-from-file=env/<env>.json).
# Safe to run again; switching env rewrites the IDs.
set -euo pipefail
cd "$(dirname "$0")/.."
env="${1:-dev}"
platforms="${2:-ios,android}"

case "$env" in
  dev)  id="uk.co.ariselo.app.dev"; name="Ariselo Dev" ;;
  prod) id="uk.co.ariselo.app";     name="Ariselo" ;;
  *) echo "env is dev or prod" >&2; exit 1 ;;
esac

flutter create --platforms="$platforms" --org uk.co.ariselo --project-name ariselo_mobile . >/dev/null

sedi() { sed -i.bak "$@"; rm -f "${@: -1}.bak"; }

if [ -d android ]; then
  m=android/app/src/main/AndroidManifest.xml
  sedi "s/android:label=\"[^\"]*\"/android:label=\"$name\"/" "$m"
  # release builds need the internet permission in the main manifest (debug has it already)
  grep -q 'android.permission.INTERNET' "$m" ||
    sedi 's|<application|<uses-permission android:name="android.permission.INTERNET"/>\
    <application|' "$m"
  for g in android/app/build.gradle.kts android/app/build.gradle; do
    [ -f "$g" ] && sedi -E "s/applicationId( =)? \"[^\"]*\"/applicationId\1 \"$id\"/" "$g"
  done
fi

if [ -d ios ]; then
  # the app's own ID (the test target keeps its .RunnerTests suffix)
  pbx=ios/Runner.xcodeproj/project.pbxproj
  sedi -E "/RunnerTests;/ s/PRODUCT_BUNDLE_IDENTIFIER = [A-Za-z0-9.]+;/PRODUCT_BUNDLE_IDENTIFIER = $id.RunnerTests;/" "$pbx"
  sedi -E "/RunnerTests;/! s/PRODUCT_BUNDLE_IDENTIFIER = [A-Za-z0-9.]+;/PRODUCT_BUNDLE_IDENTIFIER = $id;/" "$pbx"
  if command -v /usr/libexec/PlistBuddy >/dev/null; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $name" ios/Runner/Info.plist
    /usr/libexec/PlistBuddy -c "Set :CFBundleName $name" ios/Runner/Info.plist
  fi
fi
echo "$name ($id): $platforms ready"
