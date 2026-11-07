import 'package:flutter/material.dart';

import '../../api.dart';
import '../../widgets.dart';
import 'forgot.dart';

/// Parent log in, with the two-step code when the account has it switched on.
class ParentLoginScreen extends StatefulWidget {
  const ParentLoginScreen({super.key});

  @override
  State<ParentLoginScreen> createState() => _ParentLoginScreenState();
}

class _ParentLoginScreenState extends State<ParentLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  bool _busy = false;
  bool _twoStep = false;
  String _error = '';

  Future<void> _done() async {
    final s = SessionScope.of(context);
    await s.refresh();
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = '';
    });
    final api = SessionScope.of(context).api;
    try {
      if (_twoStep) {
        await api.post('identity', '/login/two-factor', {'code': _code.text.trim()});
        await _done();
      } else {
        final r = await api.post('identity', '/login', {
          'email': _email.text.trim(),
          'password': _password.text,
          'portal': 'family',
        });
        if (r is Map && r['step'] == 'two_factor') {
          setState(() => _twoStep = true);
        } else {
          await _done();
        }
      }
    } catch (e) {
      setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(title: 'Grown-ups', children: [
      Text(_twoStep ? 'Enter your code' : 'Welcome back', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      Text(_twoStep ? 'The 6 numbers from your authenticator app.' : "Log in to see your children's progress."),
      const SizedBox(height: 24),
      if (!_twoStep) ...[
        TextField(
          controller: _email,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _password,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          onSubmitted: (_) => _submit(),
        ),
      ] else
        TextField(
          controller: _code,
          decoration: const InputDecoration(labelText: 'Code'),
          keyboardType: TextInputType.number,
          autofillHints: const [AutofillHints.oneTimeCode],
          onSubmitted: (_) => _submit(),
        ),
      ErrorNotice(_error),
      const SizedBox(height: 12),
      FilledButton(onPressed: _busy ? null : _submit, child: Text(_busy ? 'One moment…' : 'Log in')),
      if (!_twoStep)
        TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
          child: const Text('Forgotten your password?'),
        ),
    ]);
  }
}
