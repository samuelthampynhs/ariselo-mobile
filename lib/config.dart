/// Where the app talks to. Dev by default; a release build for the App Store passes
/// --dart-define=ARISELO_URL=https://ariselo.co.uk
const String baseUrl = String.fromEnvironment('ARISELO_URL', defaultValue: 'https://dev.ariselo.co.uk');
