import 'package:flutter/material.dart';

import '../tokens.dart';

/// A page with a comfortable width on any phone, scrolling when the keyboard is up.
class AppPage extends StatelessWidget {
  const AppPage({super.key, required this.children, this.title, this.actions});
  final List<Widget> children;
  final String? title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null && actions == null
          ? null
          : AppBar(title: title == null ? null : Text(title!), actions: actions),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Sizes.readWidth),
            child: ListView(padding: const EdgeInsets.all(Space.gutter), children: children),
          ),
        ),
      ),
    );
  }
}
