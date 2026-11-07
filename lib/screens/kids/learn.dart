import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config.dart';
import '../../theme.dart';
import '../../widgets.dart';

/// The child's learning space: today's practice, skills, lessons, mock tests and their stars.
///
/// For now this shows the website's own child pages (/learn) inside the app, signed in with
/// the child's session, so questions, marking and stars are exactly the same everywhere.
/// The app keeps the navigation: leaving /learn (signing out, the grown-ups' pages) comes
/// back to the app's own screens.
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  WebViewController? _web;
  bool _loading = true;
  String _error = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_web == null) _open();
  }

  Future<void> _open() async {
    final s = SessionScope.of(context);
    await s.api.shareSessionWithWebViews();
    final web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Brand.page)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _loading = true);
        },
        onPageFinished: (_) {
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
          // the child's pages stay here; anything else goes back to the app
          if (ours && (uri.path.startsWith('/learn') || uri.path.startsWith('/api/'))) return NavigationDecision.navigate;
          _leave();
          return NavigationDecision.prevent;
        },
      ));
    await web.loadRequest(Uri.parse('$baseUrl/learn'));
    if (mounted) setState(() => _web = web);
  }

  /// Signed out on the web page, or heading for the grown-ups' pages: back to the start.
  Future<void> _leave() async {
    await SessionScope.of(context).refresh();
  }

  Future<void> _finish() async {
    final s = SessionScope.of(context);
    await s.logout();
  }

  @override
  Widget build(BuildContext context) {
    final me = SessionScope.of(context).me;
    final web = _web;
    // Android's back button: back a page inside the lessons first, rather than closing the app.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (web != null && await web.canGoBack()) await web.goBack();
      },
      child: _scaffold(me?.name, web),
    );
  }

  Widget _scaffold(String? name, WebViewController? web) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Brand.page,
        title: Text(name == null ? 'Ariselo' : 'Hi $name!'),
        actions: [
          TextButton.icon(onPressed: _finish, icon: const Icon(Icons.logout), label: const Text("I'm done")),
        ],
      ),
      body: SafeArea(
        child: Stack(children: [
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
