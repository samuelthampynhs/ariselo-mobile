import 'package:flutter/material.dart';

import '../tokens.dart';

/// Four big number keys for a child's PIN; calls [onComplete] at four digits.
class PinPad extends StatelessWidget {
  const PinPad({super.key, required this.value, required this.onChanged, this.enabled = true});

  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    Widget key(String label, {VoidCallback? onTap, String? semantics}) => Padding(
          padding: const EdgeInsets.all(6),
          child: SizedBox(
            width: 76,
            height: 64,
            child: FilledButton.tonal(
              onPressed: enabled ? onTap : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(76, 64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Semantics(label: semantics, child: Text(label, style: const TextStyle(fontSize: 26))),
            ),
          ),
        );
    void add(String d) {
      if (value.length < 4) onChanged(value + d);
    }

    return Column(
      children: [
        Semantics(
          label: '${value.length} of 4 numbers entered',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 4; i++)
                Container(
                  margin: const EdgeInsets.all(8),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < value.length ? Brand.blue : Colors.white,
                    border: Border.all(color: Brand.blue, width: 2),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [for (final d in row) key(d, onTap: () => add(d))]),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 88),
            key('0', onTap: () => add('0')),
            key('⌫',
                semantics: 'Delete',
                onTap: value.isEmpty ? null : () => onChanged(value.substring(0, value.length - 1))),
          ],
        ),
      ],
    );
  }
}
