import 'package:flutter/material.dart';

import '../tokens.dart';

/// A problem the person must know about, announced to screen readers as it appears.
class ErrorNotice extends StatelessWidget {
  const ErrorNotice(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: Space.s2),
        padding: const EdgeInsets.symmetric(horizontal: Space.s4, vertical: Space.s3),
        decoration: BoxDecoration(color: Brand.badSoft, borderRadius: BorderRadius.circular(Radii.md)),
        child: Text(text, style: const TextStyle(color: Brand.badInk, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
