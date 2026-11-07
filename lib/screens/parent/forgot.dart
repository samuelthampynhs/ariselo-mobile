import 'package:flutter/material.dart';

import '../../api.dart';
import '../../widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  String _error = '';
  String _sent = '';
  bool _busy = false;

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      final r = await SessionScope.of(context).api.post('identity', '/password/forgot', {'email': _email.text.trim()});
      setState(() => _sent = (r is Map ? r['message'] : null)?.toString() ?? 'Check your email for a link.');
    } catch (e) {
      setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(title: 'Reset your password', children: [
      if (_sent.isNotEmpty)
        Text(_sent, style: const TextStyle(fontSize: 18))
      else ...[
        const Text("We'll email you a link to set a new password. It opens on the website."),
        const SizedBox(height: 16),
        TextField(
          controller: _email,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          onSubmitted: (_) => _submit(),
        ),
        ErrorNotice(_error),
        const SizedBox(height: 12),
        FilledButton(onPressed: _busy ? null : _submit, child: const Text('Send the link')),
      ],
    ]);
  }
}
