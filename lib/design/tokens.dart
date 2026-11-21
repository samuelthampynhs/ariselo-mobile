import 'package:flutter/material.dart';

/// Every colour the app uses. The same values as the website (ariselo-app
/// frontend/src/design/tokens.css) and the Ariselo design system: change them together.
class Brand {
  // brand: calm teal and warm amber on cream paper, with slate ink.
  // `blue` is the main colour (teal); the name stays so every widget keeps working.
  static const blue = Color(0xFF0F766E);
  static const blueDeep = Color(0xFF115E59);
  static const blueSoft = Color(0xFFCCFBF1);
  static const sun = Color(0xFFF59E0B);
  static const sunSoft = Color(0xFFFEF3C7);
  static const coral = Color(0xFFEA6A52);
  static const coralSoft = Color(0xFFFDE8E3);
  static const grape = Color(0xFF6D5BD0);
  static const grapeSoft = Color(0xFFEEEBFB);

  // text and surfaces
  static const ink = Color(0xFF1E293B);
  static const ink2 = Color(0xFF334155);
  static const muted = Color(0xFF475569); // 7:1 on the cream page
  static const line = Color(0xFFE2E8F0); // decorative edges only
  static const lineStrong = Color(0xFFCBD5E1);
  static const edge = Color(0xFF64748B); // edges of things you type in or choose: 4.8:1 on white
  static const page = Color(0xFFFAF9F6);
  static const card = Color(0xFFFFFFFF);

  // feedback: use the -ink colours for text on the -soft grounds
  static const good = Color(0xFF15803D);
  static const goodSoft = Color(0xFFDCFCE7);
  static const goodInk = Color(0xFF166534);
  static const bad = Color(0xFFC2410C); // system errors and destructive actions only
  static const badSoft = Color(0xFFFFEDD5);
  static const badInk = Color(0xFF9A3412);
  static const warnInk = Color(0xFF92400E);
  static const blueInk = Color(0xFF0F766E);
  static const grapeInk = Color(0xFF5B47C2);

  // learning: a child's "not quite" is amber, never red; help always looks the same
  static const nudge = sunSoft;
  static const nudgeInk = warnInk;
  static const nudgeEdge = Color(0xFFB45309);
  static const hint = grapeSoft;
  static const hintInk = grapeInk;
}

/// Spacing in 8px steps (4px at the bottom), the same scale as the website.
class Space {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 24.0;
  static const s6 = 32.0;
  static const s7 = 48.0;
  static const s8 = 72.0;

  /// Side padding of a phone screen.
  static const gutter = 20.0;
}

/// Corner radii.
class Radii {
  static const sm = 10.0; // fields
  static const md = 14.0; // notices, answer options, stat tiles
  static const lg = 18.0; // cards, sheets
  static const xl = 24.0; // things that rise from the bottom edge
  static const pill = 999.0; // buttons, chips, pills
}

/// Sizes that keep things easy to tap.
class Sizes {
  static const touch = 56.0; // nothing you tap is shorter
  static const touchSmall = 44.0;
  static const answerMin = 72.0;
  static const bottomNav = 72.0;
  static const readWidth = 560.0; // the page column on a large phone or tablet
}
