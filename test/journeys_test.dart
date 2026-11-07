// Behaviour the app must keep: a parent's home and tabs on a phone and a tablet, the plan
// screen, the referral card, and a child logging in with their picture and PIN. The API is a
// stand-in with the website's real answer shapes; nothing goes over the network.
import 'dart:convert';

import 'package:ariselo_mobile/api.dart';
import 'package:ariselo_mobile/main.dart';
import 'package:ariselo_mobile/screens/parent/family.dart';
import 'package:ariselo_mobile/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers requests from a table: "GET /api/identity/me" -> (status, body), the way the
/// backend does (an error status becomes ApiError with the backend's message).
class Backend {
  Backend(this.routes);
  final Map<String, (int, Object?)> routes;
  final List<String> seen = [];

  Future<dynamic> call(String method, String path, Object? body) async {
    final key = '$method $path';
    seen.add(key);
    final (status, out) = routes[key] ?? (404, {'error': 'not_found', 'message': 'Not found'});
    if (status >= 400) {
      final m = out as Map;
      throw ApiError(status, m['error'] as String, m['message'] as String);
    }
    return jsonDecode(jsonEncode(out)); // plain maps and lists, as from the network
  }
}

const parent = {'id': 'u1', 'role': 'parent', 'name': 'Rosa Silva', 'email': 'rosa@example.test', 'email_verified': true};
const family = {
  'id': 'f1',
  'family_code': 'YAK-7635',
  'delete_after': null,
  'children': [
    {'id': 'c1', 'name': 'Tomasz', 'year': 3, 'avatar': 'owl'},
  ],
};
const account = {
  'status': 'trialing',
  'plan': null,
  'trial_days_left': 6,
  'full_access': true,
  'quote': {'monthly': 499, 'yearly': 4499, 'yearly_saving': 1489},
  'cancel_at_period_end': false,
  'current_period_end': null,
  'payments_mode': 'stripe',
  'free_daily_questions': 5,
  'referral_code': 'RISE-N54AD',
  'referral_link': 'https://dev.ariselo.co.uk/signup?code=RISE-N54AD',
  'referral_free_months': 1,
  'referrals': {'joined': 2, 'paid': 1},
  'free_months': 1,
};

Future<Session> signedInAs(Backend backend) async {
  final s = Session(Api.forTests(backend.call));
  await s.refresh();
  return s;
}

Future<void> showAt(WidgetTester t, Size size, Session s) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(AriseloApp(session: s));
  await t.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('a parent on a phone: tabs along the bottom, family, plan and account', (t) async {
    final backend = Backend({
      'GET /api/identity/me': (200, parent),
      'GET /api/identity/family': (200, family),
      'GET /api/billing/account': (200, account),
    });
    await showAt(t, const Size(390, 844), await signedInAs(backend));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Hello, Rosa'), findsOneWidget);
    expect(find.text('YAK-7635'), findsOneWidget);
    expect(find.text('Tomasz'), findsOneWidget);
    expect(find.text('Start Tomasz'), findsOneWidget);

    // the referral card: code, link, how many friends joined
    await t.scrollUntilVisible(
      find.text('Copy link'),
      200,
      scrollable: find.descendant(of: find.byType(FamilyScreen), matching: find.byType(Scrollable)).first,
    );
    expect(find.textContaining('RISE-N54AD'), findsWidgets);
    expect(find.text('2 joined, 1 started a plan.'), findsOneWidget);

    // the Plan tab
    await t.tap(find.text('Plan').last);
    await t.pumpAndSettle();
    expect(find.text('Free trial: 6 days left'), findsOneWidget);
    expect(find.text('Monthly · £4.99'), findsOneWidget);
    expect(find.text('Yearly · £44.99'), findsOneWidget);

    // the Account tab
    await t.tap(find.text('Account').last);
    await t.pumpAndSettle();
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('rosa@example.test'), findsOneWidget);
  });

  testWidgets('a parent on a tablet: a rail down the side instead of bottom tabs', (t) async {
    final backend = Backend({
      'GET /api/identity/me': (200, parent),
      'GET /api/identity/family': (200, family),
      'GET /api/billing/account': (200, account),
    });
    await showAt(t, const Size(1180, 820), await signedInAs(backend));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await t.tap(find.text('Plan'));
    await t.pumpAndSettle();
    expect(find.text('Monthly · £4.99'), findsOneWidget);
  });

  testWidgets('a parent on a small Android phone: nothing overflows', (t) async {
    final backend = Backend({
      'GET /api/identity/me': (200, parent),
      'GET /api/identity/family': (200, family),
      'GET /api/billing/account': (200, account),
    });
    await showAt(t, const Size(360, 640), await signedInAs(backend));
    expect(t.takeException(), isNull); // a RenderFlex overflow would be reported here
    await t.tap(find.text('Plan').last);
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  });

  testWidgets('a child logs in: family code, their picture, their PIN', (t) async {
    final backend = Backend({
      'GET /api/identity/me': (401, {'error': 'unauthorised', 'message': 'Please log in.'}),
      'GET /api/identity/kids/YAK-7635': (200, {
        'children': [
          {'id': 'c1', 'name': 'Tomasz', 'year': 3, 'avatar': 'owl'},
        ],
      }),
      'POST /api/identity/kids/login': (200, {'id': 'c1', 'role': 'child', 'name': 'Tomasz'}),
    });
    final s = await signedInAs(backend);
    await showAt(t, const Size(390, 844), s);
    await t.tap(find.text("I'm learning"));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'yak-7635');
    await t.tap(find.text('Next'));
    await t.pumpAndSettle();
    expect(find.text("Who's learning?"), findsOneWidget);
    await t.tap(find.text('Tomasz'));
    await t.pumpAndSettle();
    expect(find.text('Hi Tomasz! Type your PIN.'), findsOneWidget);
    for (final d in ['2', '4', '6', '8']) {
      await t.tap(find.text(d));
      await t.pump();
    }
    await t.pump(const Duration(milliseconds: 100));
    expect(backend.seen, contains('POST /api/identity/kids/login'));
    expect(backend.seen, contains('GET /api/identity/kids/YAK-7635')); // the code is sent in capitals
  });

  testWidgets('a wrong PIN: told so, and the dots clear', (t) async {
    final semantics = t.ensureSemantics();
    addTearDown(semantics.dispose);
    final backend = Backend({
      'GET /api/identity/me': (401, {'error': 'unauthorised', 'message': 'Please log in.'}),
      'GET /api/identity/kids/YAK-7635': (200, {
        'children': [
          {'id': 'c1', 'name': 'Tomasz', 'year': 3, 'avatar': 'owl'},
        ],
      }),
      'POST /api/identity/kids/login': (401, {'error': 'unauthorised', 'message': "That PIN isn't right. Try again."}),
    });
    await showAt(t, const Size(390, 844), await signedInAs(backend));
    await t.tap(find.text("I'm learning"));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'YAK-7635');
    await t.tap(find.text('Next'));
    await t.pumpAndSettle();
    await t.tap(find.text('Tomasz'));
    await t.pumpAndSettle();
    for (final d in ['1', '1', '1', '1']) {
      await t.tap(find.text(d));
      await t.pump();
    }
    await t.pumpAndSettle();
    expect(find.text("That PIN isn't right. Try again."), findsOneWidget);
    expect(find.bySemanticsLabel('0 of 4 numbers entered'), findsOneWidget);
  });
}
