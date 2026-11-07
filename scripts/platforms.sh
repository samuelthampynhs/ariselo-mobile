#!/usr/bin/env bash
# Makes the ios/ and android/ folders (flutter create) and gives them Ariselo's name and the
# permissions the app needs. Safe to run again. Used by CI; run it once on your own machine too.
set -euo pipefail
cd "$(dirname "$0")/.."
platforms="${1:-ios,android}"

flutter create --platforms="$platforms" --org uk.co.ariselo --project-name ariselo_mobile . >/dev/null

if [ -f android/app/src/main/AndroidManifest.xml ]; then
  m=android/app/src/main/AndroidManifest.xml
  # the app's name under its icon
  sed -i.bak 's/android:label="[^"]*"/android:label="Ariselo"/' "$m"
  # release builds need the internet permission in the main manifest (debug has it already)
  grep -q 'android.permission.INTERNET' "$m" ||
    sed -i.bak 's|<application|<uses-permission android:name="android.permission.INTERNET"/>\n    <application|' "$m"
  rm -f "$m.bak"
fi

if [ -f ios/Runner/Info.plist ] && command -v /usr/libexec/PlistBuddy >/dev/null; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName Ariselo" ios/Runner/Info.plist
  /usr/libexec/PlistBuddy -c "Set :CFBundleName Ariselo" ios/Runner/Info.plist
fi
echo "Platform folders ready: $platforms"
