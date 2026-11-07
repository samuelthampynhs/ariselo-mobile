import 'package:ariselo_mobile/screens/welcome.dart';
import 'package:ariselo_mobile/theme.dart';
import 'package:ariselo_mobile/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the PIN pad adds numbers and deletes them', (tester) async {
    var pin = '';
    await tester.pumpWidget(MaterialApp(
      theme: ariseloTheme(),
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, set) => SingleChildScrollView(
            child: PinPad(value: pin, onChanged: (v) => set(() => pin = v)),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();
    expect(pin, '12');
    await tester.tap(find.text('⌫'));
    await tester.pump();
    expect(pin, '1');
    for (final d in ['3', '4', '5', '6']) {
      await tester.tap(find.text(d));
      await tester.pump();
    }
    expect(pin, '1345'); // never more than four
  });

  testWidgets('the welcome screen offers both ways in', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: ariseloTheme(), home: const WelcomeScreen()));
    expect(find.text("I'm learning"), findsOneWidget);
    expect(find.text("I'm a grown-up"), findsOneWidget);
    expect(find.textContaining('free trial'), findsOneWidget);
  });
}
