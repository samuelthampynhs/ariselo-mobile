/// Where the app talks to, set when it is built:
///   Ariselo Dev  --dart-define-from-file=env/dev.json   (dev.ariselo.co.uk)
///   Ariselo      --dart-define-from-file=env/prod.json  (ariselo.co.uk)
const String baseUrl = String.fromEnvironment('ARISELO_URL', defaultValue: 'https://dev.ariselo.co.uk');

/// The dev app wears a "DEV" ribbon so it is never mistaken for the real one.
bool get isDevApp => Uri.parse(baseUrl).host != 'ariselo.co.uk';

/// Builds for the App Store and Google Play. Their rules don't allow buying a subscription
/// outside the store from inside the app, so these builds show the plan but no way to buy.
const bool storeBuild = bool.fromEnvironment('STORE_BUILD');
