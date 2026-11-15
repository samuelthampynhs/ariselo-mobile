import 'package:ariselo_mobile/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a growth band says its step in words for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
      theme: ariseloTheme(),
      home: const Scaffold(body: GrowthBand(skill: 'Times tables', step: 3)),
    ));
    expect(find.text('Strong'), findsOneWidget);
    expect(find.bySemanticsLabel('Times tables: Strong, step 3 of 4'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('an error notice uses the readable red and is announced', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ErrorNotice('That PIN does not match'))));
    final text = tester.widget<Text>(find.text('That PIN does not match'));
    expect(text.style?.color, Brand.badInk);
    expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.liveRegion == true), findsOneWidget);
  });

  testWidgets('an empty error notice takes no space', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ErrorNotice(''))));
    expect(
        find.byType(Semantics).evaluate().where((e) => (e.widget as Semantics).properties.liveRegion == true), isEmpty);
  });
}
