import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api.dart';
import '../../config.dart';
import '../../widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _error = '';

  Future<void> _signOut({bool everywhere = false}) async {
    final s = SessionScope.of(context);
    final nav = Navigator.of(context);
    try {
      if (everywhere) await s.api.post('identity', '/me/sign-out-everywhere');
      await s.logout();
      nav.popUntil((r) => r.isFirst);
    } catch (e) {
      setState(() => _error = errorText(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = SessionScope.of(context).me;
    return AppPage(title: 'Settings', children: [
      ListTile(title: Text(me?.name ?? ''), subtitle: Text(me?.email ?? '')),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.open_in_new),
        title: const Text('Account, privacy and data'),
        subtitle: const Text('Two-step sign-in, downloading or deleting your data: on the website'),
        onTap: () => launchUrl(Uri.parse('$baseUrl/family/settings'), mode: LaunchMode.externalApplication),
      ),
      ListTile(
        leading: const Icon(Icons.help_outline),
        title: const Text('Help'),
        onTap: () => launchUrl(Uri.parse('$baseUrl/help'), mode: LaunchMode.externalApplication),
      ),
      const Divider(),
      ErrorNotice(_error),
      ListTile(leading: const Icon(Icons.logout), title: const Text('Sign out'), onTap: _signOut),
      ListTile(
        leading: const Icon(Icons.devices_other),
        title: const Text('Sign out on every device'),
        onTap: () => _signOut(everywhere: true),
      ),
    ]);
  }
}
