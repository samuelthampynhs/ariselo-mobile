import 'package:flutter/material.dart';

/// Every colour the app uses. The same values as the website (ariselo-app
/// frontend/src/design/tokens.css) and the Ariselo design system: change them together.
class Brand {
  // brand: the four kite colours
  static const blue = Color(0xFF2F6FDB);
  static const blueDeep = Color(0xFF1F55B8);
  static const blueSoft = Color(0xFFE6EFFF);
  static const sun = Color(0xFFFFC23D);
  static const sunSoft = Color(0xFFFFF4D6);
  static const coral = Color(0xFFFF6B57);
  static const coralSoft = Color(0xFFFFE8E4);
  static const grape = Color(0xFF7C4DDB);
  static const grapeSoft = Color(0xFFEFE8FF);

  // text and surfaces
  static const ink = Color(0xFF1F2A55);
  static const ink2 = Color(0xFF4A5683);
  static const muted = Color(0xFF576389); // 4.9:1 on page, card and blue-soft
  static const line = Color(0xFFD9E1F2); // decorative edges only
  static const lineStrong = Color(0xFFB9C6E4);
  static const edge = Color(0xFF7A86AA); // edges of things you type in or choose: 3.6:1 on white
  static const page = Color(0xFFF7FBFF);
  static const card = Color(0xFFFFFFFF);

  // feedback: use the -ink colours for text on the -soft grounds
  static const good = Color(0xFF13854F);
  static const goodSoft = Color(0xFFE1F6EA);
  static const goodInk = Color(0xFF0E6B3F);
  static const bad = Color(0xFFD0313F); // system errors and destructive actions only
  static const badSoft = Color(0xFFFDE7E9);
  static const badInk = Color(0xFFB32634);
  static const warnInk = Color(0xFF7A5300);
  static const blueInk = Color(0xFF2559C4);
  static const grapeInk = Color(0xFF6A3FC4);

  // learning: a child's "not quite" is amber, never red; help always looks the same
  static const nudge = sunSoft;
  static const nudgeInk = warnInk;
  static const nudgeEdge = Color(0xFFA87300);
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
  static const md = 16.0; // notices, answer options, stat tiles
  static const lg = 24.0; // cards, sheets
  static const xl = 32.0; // things that rise from the bottom edge
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
