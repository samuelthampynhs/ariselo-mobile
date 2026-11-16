import 'package:ariselo_mobile/tabs/parental_gate.dart';
import 'package:ariselo_mobile/tabs/speech_bridge.dart';
import 'package:ariselo_mobile/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<bool?> openGate(WidgetTester tester) async {
    bool? result;
    await tester.pumpWidget(MaterialApp(
      theme: ariseloTheme(),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await showDialog<bool>(
            context: context,
            builder: (_) => const ParentalGate(a: 7, b: 8),
          ),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('the grown-ups gate stays shut for a wrong answer', (tester) async {
    await openGate(tester);
    expect(find.text('What is 7 × 8?'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('gate-answer')), '54');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.textContaining('Ask a grown-up'), findsOneWidget);
    expect(find.byType(ParentalGate), findsOneWidget);
  });

  testWidgets('the grown-ups gate opens for the right answer', (tester) async {
    await openGate(tester);
    await tester.enterText(find.byKey(const Key('gate-answer')), '56');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(ParentalGate), findsNothing);
  });

  test('the page gets a stand-in speech engine that talks to the app', () {
    const js = SpeechBridge.polyfill;
    expect(js, contains('${SpeechBridge.channel}.postMessage'));
    expect(js, contains("defineProperty(window, 'speechSynthesis'"));
    expect(js, contains('window.SpeechSynthesisUtterance = Utterance'));
    // the page's handlers are called as on<type>: onstart, onboundary, onend, onerror
    expect(js, contains("u['on' + type]"));
    expect(js, contains("type === 'end' || type === 'error'"));
  });
}
