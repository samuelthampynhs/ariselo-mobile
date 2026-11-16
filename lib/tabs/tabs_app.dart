import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config.dart';
import '../screens/kids/kids_login.dart';
import '../widgets.dart';
import 'parental_gate.dart';
import 'speech_bridge.dart';

/// Ariselo Tabs: the tablet app for Reception and Year 1.
///
/// Only children sign in here (family code, picture, PIN). Then the website's /tabs page fills the
/// screen: their grown-ups' avatars read every question aloud. Grown-ups set the avatars up on the
/// website, reached through "For grown-ups" behind a parental gate.
class TabsHome extends StatelessWidget {
  const TabsHome({super.key});

  @override
  Widget build(BuildContext context) {
    final s = SessionScope.of(context);
    if (s.loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final me = s.me;
    if (me != null && me.isChild) return const TabsScreen();
    return const TabsWelcome();
  }
}

/// Before a child signs in. A parent signed in on this tablet is signed out: Tabs is for children.
class TabsWelcome extends StatefulWidget {
  const TabsWelcome({super.key});

  @override
  State<TabsWelcome> createState() => _TabsWelcomeState();
}

class _TabsWelcomeState extends State<TabsWelcome> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = SessionScope.of(context);
    if (s.me != null && !s.me!.isChild) s.logout();
  }

  Future<void> _grownUps() async {
    if (!await askAGrownUp(context)) return;
    await launchUrl(Uri.parse('$baseUrl/family/grown-ups'), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Brand.blueSoft,
      body: SafeArea(
        child: Stack(children: [
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Ariselo Tabs',
                  style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Brand.blue)),
              const SizedBox(height: 32),
              Semantics(
                button: true,
                label: "I'm learning",
                child: InkWell(
                  key: const Key('tabs-start'),
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const KidsLoginScreen())),
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(color: Brand.good, shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded, size: 130, color: Colors.white),
                  ),
                ),
              ),
            ]),
          ),
          Positioned(
            right: 16,
            top: 8,
            child: TextButton.icon(
              onPressed: _grownUps,
              icon: const Icon(Icons.lock_outline),
              label: const Text('For grown-ups'),
            ),
          ),
        ]),
      ),
    );
  }
}

/// The child's /tabs page, full screen, with the app's own voice for the avatars.
class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  WebViewController? _web;
  SpeechBridge? _speech;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_web == null) _open();
  }

  @override
  void dispose() {
    _speech?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _open() async {
    final s = SessionScope.of(context);
    await s.api.shareSessionWithWebViews();
    final web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Brand.blueSoft);
    final speech = SpeechBridge(web);
    await speech.attach();
    await web.setNavigationDelegate(NavigationDelegate(
      onPageStarted: (_) {
        speech.install();
        if (mounted) setState(() => _loading = true);
      },
      onPageFinished: (_) {
        speech.install();
        if (mounted) setState(() => _loading = false);
      },
      onWebResourceError: (e) {
        if ((e.isForMainFrame ?? true) && mounted) {
          setState(() => _error = "We can't reach Ariselo. Check your internet connection and try again.");
        }
      },
      onNavigationRequest: (req) {
        final uri = Uri.parse(req.url);
        final ours = uri.host == Uri.parse(baseUrl).host;
        if (ours && (uri.path.startsWith('/tabs') || uri.path.startsWith('/api/'))) {
          return NavigationDecision.navigate;
        }
        _leave();
        return NavigationDecision.prevent;
      },
      // the page moves itself (sign out goes to /kids) without loading a new page
      onUrlChange: (change) {
        final url = change.url;
        if (url != null && !Uri.parse(url).path.startsWith('/tabs')) _leave();
      },
    ));
    await web.loadRequest(Uri.parse('$baseUrl/tabs'));
    if (mounted) {
      setState(() {
        _web = web;
        _speech = speech;
      });
    }
  }

  Future<void> _leave() async {
    await _speech?.dispose();
    if (!mounted) return;
    final s = SessionScope.of(context);
    final me = await s.refresh();
    if (me != null && me.isChild && mounted) {
      await _web?.loadRequest(Uri.parse('$baseUrl/tabs')); // still signed in: stay in Tabs
    }
  }

  @override
  Widget build(BuildContext context) {
    final web = _web;
    return PopScope(
      canPop: false, // Android's back button doesn't drop a five-year-old out of the app
      child: Scaffold(
        backgroundColor: Brand.blueSoft,
        body: Stack(children: [
          if (web != null) WebViewWidget(controller: web),
          if (_error.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  ErrorNotice(_error),
                  FilledButton(
                    onPressed: () {
                      setState(() => _error = '');
                      web?.reload();
                    },
                    child: const Text('Try again'),
                  ),
                ]),
              ),
            ),
          if (_loading && _error.isEmpty) const LinearProgressIndicator(),
        ]),
      ),
    );
  }
}
