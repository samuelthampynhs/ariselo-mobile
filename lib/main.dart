import 'package:flutter/material.dart';

import 'api.dart';
import 'config.dart';
import 'screens/kids/learn.dart';
import 'screens/parent/parent_home.dart';
import 'screens/welcome.dart';
import 'session.dart';
import 'theme.dart';
import 'widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final session = Session(await Api.create());
  session.refresh();
  runApp(AriseloApp(session: session));
}

class AriseloApp extends StatelessWidget {
  const AriseloApp({super.key, required this.session});
  final Session session;

  @override
  Widget build(BuildContext context) {
    return SessionScope(
      session: session,
      child: MaterialApp(
        title: 'Ariselo',
        debugShowCheckedModeBanner: false,
        theme: ariseloTheme(),
        home: const Home(),
        builder: (context, child) => isDevApp
            ? Banner(message: 'DEV', location: BannerLocation.topEnd, child: child ?? const SizedBox.shrink())
            : child ?? const SizedBox.shrink(),
      ),
    );
  }
}

/// Shows the right place for whoever is signed in.
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final s = SessionScope.of(context);
    if (s.loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final me = s.me;
    if (me == null) return const WelcomeScreen();
    if (me.isChild) return const LearnScreen();
    if (me.isParent) return const ParentHome();
    return AppPage(title: 'Ariselo', children: [
      const Text('Team accounts use the website for now.', style: TextStyle(fontSize: 18)),
      const SizedBox(height: 16),
      OutlinedButton(onPressed: s.logout, child: const Text('Sign out')),
    ]);
  }
}
