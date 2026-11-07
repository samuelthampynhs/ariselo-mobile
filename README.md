# Ariselo for iPhone

The family app, in Flutter (one codebase for iPhone and, later, Android). It talks to the same
API as the website, at **https://dev.ariselo.co.uk** by default.

## What's in it

**Grown-ups**
- Log in (with the two-step code when it's on), start a free trial, reset a password
- The family: the family code, every child, add / change / remove a child (name, year group,
  picture, PIN)
- A child's progress: last 30 days, the last 14 days as a chart, Maths and English, latest answers
- **Start [child]**: hands the phone to that child, already signed in
- Plan: trial, monthly or yearly through Stripe (opens in the browser), change card or cancel
- Settings: sign out, sign out on every device; account and data pages open on the website

**Children**
- Family code → tap your picture → 4-number PIN (the code is remembered on the phone)
- Learning: today's practice, skills, lessons, mock tests and stars. For now these are the
  website's own child pages shown inside the app with the child's session, so questions,
  marking and stars are the same everywhere. "I'm done" signs the child out.

## Try it

You need Flutter (stable) and, for iPhone, a Mac with Xcode.

```bash
cd mobile
flutter create --platforms=ios,android --org uk.co.ariselo --project-name ariselo_mobile .   # once
flutter pub get
flutter run                                     # dev.ariselo.co.uk
flutter run --dart-define=ARISELO_URL=https://ariselo.co.uk   # prod, once it is live
flutter test
```

Without a Mac: **Actions → Mobile → Run workflow** builds it on GitHub's macOS machines and keeps
a simulator build (Ariselo-simulator.zip) to open in Xcode's Simulator.

## Before the App Store

- An Apple Developer account (£79 a year), the bundle id `uk.co.ariselo.ariseloMobile` or your
  choice, signing in CI (App Store Connect API key as a GitHub secret).
- Apple's rules for children's apps ("Kids" category): no third-party analytics or ads, a
  parental gate before links out of the app or payments. The Plan screen and outside links are
  only in the grown-ups' part; the children's part keeps them inside /learn.
- Payments: families pay on the website (Stripe). If the app itself sells the subscription,
  Apple requires in-app purchase; showing an existing plan and linking to manage it on the web
  needs care with App Review. Decide before submitting.
- Phase 2: the question engine (frontend/src/curriculum/engine.js) natively in the app, so
  practice works offline and feels fully native.
