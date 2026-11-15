import 'package:flutter/material.dart';

import '../tokens.dart';

/// The four steps a skill grows through. Growth never goes down.
const growthSteps = ['Starting', 'Growing', 'Strong', 'Shining'];

/// A skill's growth as four pills and a word, read out as "Times tables: Strong, step 3 of 4".
class GrowthBand extends StatelessWidget {
  const GrowthBand({super.key, required this.skill, required this.step, this.note}) : assert(step >= 1 && step <= 4);

  final String skill;
  final int step;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final word = growthSteps[step - 1];
    const label = TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Brand.muted);
    return Semantics(
      label: '$skill: $word, step $step of 4',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (var n = 1; n <= 4; n++)
                Expanded(
                  child: Container(
                    height: 10,
                    margin: EdgeInsets.only(right: n < 4 ? Space.s1 : 0),
                    decoration: BoxDecoration(
                      color: n == 4 && step == 4 ? Brand.grape : (n <= step ? Brand.blue : Brand.blueSoft),
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: Text(note ?? skill, style: label)),
              Text(word, style: label.copyWith(color: Brand.ink)),
            ],
          ),
        ],
      ),
    );
  }
}
