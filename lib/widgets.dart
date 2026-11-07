import 'package:flutter/material.dart';

import 'avatars.dart';
import 'session.dart';
import 'theme.dart';

/// The signed-in session, available to every screen.
class SessionScope extends InheritedNotifier<Session> {
  const SessionScope({super.key, required Session session, required super.child}) : super(notifier: session);

  static Session of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<SessionScope>()!.notifier!;
}

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
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Brand.badSoft, borderRadius: BorderRadius.circular(12)),
        child: Text(text, style: const TextStyle(color: Brand.bad, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

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
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [for (final d in row) key(d, onTap: () => add(d))]),
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

/// A page with a comfortable width on any phone, scrolling when the keyboard is up.
class AppPage extends StatelessWidget {
  const AppPage({super.key, required this.children, this.title, this.actions});
  final List<Widget> children;
  final String? title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null && actions == null ? null : AppBar(title: title == null ? null : Text(title!), actions: actions),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(padding: const EdgeInsets.all(20), children: children),
          ),
        ),
      ),
    );
  }
}
