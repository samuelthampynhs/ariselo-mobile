import 'package:flutter/material.dart';

import '../theme.dart';
import 'kids/kids_login.dart';
import 'parent/login.dart';
import 'parent/signup.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void go(Widget w) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Ariselo',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Brand.blue)),
                  const SizedBox(height: 8),
                  const Text('Maths and English, 10 minutes a day.',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Brand.muted)),
                  const SizedBox(height: 48),
                  FilledButton(
                    onPressed: () => go(const KidsLoginScreen()),
                    style: FilledButton.styleFrom(backgroundColor: Brand.sun, foregroundColor: Brand.ink),
                    child: const Text("I'm learning"),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(onPressed: () => go(const ParentLoginScreen()), child: const Text("I'm a grown-up")),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: () => go(const ParentSignupScreen()),
                    child: const Text('New to Ariselo? Start a free trial'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
