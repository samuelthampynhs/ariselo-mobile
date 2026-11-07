import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api.dart';
import '../../config.dart';
import '../../widgets.dart';

class ParentSignupScreen extends StatefulWidget {
  const ParentSignupScreen({super.key});

  @override
  State<ParentSignupScreen> createState() => _ParentSignupScreenState();
}

class _ParentSignupScreenState extends State<ParentSignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _promo = TextEditingController();
  bool _agree = false;
  bool _busy = false;
  String _error = '';

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = '';
    });
    final s = SessionScope.of(context);
    try {
      await s.api.post('identity', '/signup', {
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'password': _password.text,
        'promo_code': _promo.text.trim(),
        'accept_terms': _agree,
      });
      await s.refresh();
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(title: 'Start a free trial', children: [
      const Text('For the grown-up. You add your children next.'),
      const SizedBox(height: 20),
      TextField(controller: _name, decoration: const InputDecoration(labelText: 'Your name'), autofillHints: const [AutofillHints.name]),
      const SizedBox(height: 14),
      TextField(
        controller: _email,
        decoration: const InputDecoration(labelText: 'Email'),
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _password,
        decoration: const InputDecoration(labelText: 'Password', helperText: 'At least 10 characters'),
        obscureText: true,
        autofillHints: const [AutofillHints.newPassword],
      ),
      const SizedBox(height: 14),
      TextField(controller: _promo, decoration: const InputDecoration(labelText: 'Promo code (if you have one)')),
      const SizedBox(height: 8),
      CheckboxListTile(
        value: _agree,
        onChanged: (v) => setState(() => _agree = v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        title: const Text('I agree to the terms and the privacy notice'),
      ),
      Wrap(spacing: 8, children: [
        TextButton(onPressed: () => launchUrl(Uri.parse('$baseUrl/terms')), child: const Text('Terms')),
        TextButton(onPressed: () => launchUrl(Uri.parse('$baseUrl/privacy')), child: const Text('Privacy notice')),
      ]),
      ErrorNotice(_error),
      const SizedBox(height: 8),
      FilledButton(onPressed: _busy || !_agree ? null : _submit, child: const Text('Create my account')),
    ]);
  }
}
