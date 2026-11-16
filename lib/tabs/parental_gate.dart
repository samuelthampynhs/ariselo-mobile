import 'dart:math';

import 'package:flutter/material.dart';

import '../theme.dart';

/// "Ask a grown-up": a sum a five-year-old can't do yet, before anything that leaves the
/// children's part of the app (the App Store and Google Play ask for this in apps for children).
///
/// Returns true if the answer was right.
Future<bool> askAGrownUp(BuildContext context, {Random? random}) async {
  final r = random ?? Random();
  final a = 6 + r.nextInt(4); // 6..9
  final b = 6 + r.nextInt(4);
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => ParentalGate(a: a, b: b),
  );
  return ok ?? false;
}

class ParentalGate extends StatefulWidget {
  const ParentalGate({super.key, required this.a, required this.b});
  final int a;
  final int b;

  @override
  State<ParentalGate> createState() => _ParentalGateState();
}

class _ParentalGateState extends State<ParentalGate> {
  final _answer = TextEditingController();
  String _error = '';

  void _check() {
    if (int.tryParse(_answer.text.trim()) == widget.a * widget.b) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = "That's not it. Ask a grown-up to help.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('For grown-ups'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('What is ${widget.a} × ${widget.b}?', style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 12),
        TextField(
          key: const Key('gate-answer'),
          controller: _answer,
          keyboardType: TextInputType.number,
          autofocus: true,
          onSubmitted: (_) => _check(),
          decoration: const InputDecoration(labelText: 'Answer'),
        ),
        if (_error.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(_error, style: const TextStyle(color: Brand.bad)),
        ],
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        FilledButton(onPressed: _check, child: const Text('Continue')),
      ],
    );
  }
}
