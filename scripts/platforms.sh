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
flutter pub get >/dev/null

# The app icon: the kite, with a "DEV" band on the dev app so the two are easy to tell apart.
icon="assets/icon/icon.png"; [ "$env" = dev ] && icon="assets/icon/icon-dev.png"
cfg="$(mktemp -d)/icons.yaml"
cat > "$cfg" <<YAML
flutter_launcher_icons:
  android: true
  ios: $([[ "$platforms" == *ios* ]] && echo true || echo false)
  image_path: "$icon"
  remove_alpha_ios: true
YAML
dart run flutter_launcher_icons -f "$cfg" >/dev/null
rm -rf "$(dirname "$cfg")"

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
  # Lint's release check crashes on some plugins (url_launcher_android) with the current
  # build tools, and it adds nothing to the store upload. Skip it; the tests and CI still run.
  cat >> android/build.gradle.kts <<'LINT' 2>/dev/null || true
// Ariselo: the release lint check crashes on some plugins; skipped (see scripts/platforms.sh)
subprojects {
    tasks.matching { it.name.startsWith("lintVital") }.configureEach { enabled = false }
}
LINT
fi

if [ -d ios ] && [[ "$platforms" == *ios* ]]; then
  # the app's own ID (the test target keeps its .RunnerTests suffix)
  pbx=ios/Runner.xcodeproj/project.pbxproj
  # perl, not sed: the same on Linux and on macOS
  perl -pi -e "s/PRODUCT_BUNDLE_IDENTIFIER = [A-Za-z0-9.]+\.RunnerTests;/PRODUCT_BUNDLE_IDENTIFIER = $id.RunnerTests;/; s/PRODUCT_BUNDLE_IDENTIFIER = (?![A-Za-z0-9.]+\.RunnerTests;)[A-Za-z0-9.]+;/PRODUCT_BUNDLE_IDENTIFIER = $id;/" "$pbx"
  if command -v /usr/libexec/PlistBuddy >/dev/null; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $name" ios/Runner/Info.plist
    /usr/libexec/PlistBuddy -c "Set :CFBundleName $name" ios/Runner/Info.plist
    # standard HTTPS only: no export-compliance questions on each upload
    /usr/libexec/PlistBuddy -c "Delete :ITSAppUsesNonExemptEncryption" ios/Runner/Info.plist 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :ITSAppUsesNonExemptEncryption bool false" ios/Runner/Info.plist
  fi
  # Signing for the App Store: Xcode manages certificates and profiles for this team.
  if [ -n "${APPLE_TEAM_ID:-}" ]; then
    perl -pi -e "s/^(\s*)(PRODUCT_BUNDLE_IDENTIFIER = $id;)/\1\2\n\1DEVELOPMENT_TEAM = $APPLE_TEAM_ID;\n\1CODE_SIGN_STYLE = Automatic;/" "$pbx"
  fi
fi
echo "$name ($id): $platforms ready"
