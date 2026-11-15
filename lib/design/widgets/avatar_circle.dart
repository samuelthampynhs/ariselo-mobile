import 'package:flutter/material.dart';

import '../../avatars.dart';
import '../tokens.dart';

/// A child's picture: an animal on a round sun-soft disc, hidden from screen readers (the name
/// beside it says who).
class AvatarCircle extends StatelessWidget {
  const AvatarCircle(this.name, {super.key, this.size = 56});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: Brand.sunSoft, shape: BoxShape.circle),
        child: Text(avatarFor(name), style: TextStyle(fontSize: size * 0.58)),
      ),
    );
  }
}
