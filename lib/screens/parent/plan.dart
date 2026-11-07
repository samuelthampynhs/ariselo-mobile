import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api.dart';
import '../../models.dart';
import '../../theme.dart';
import '../../widgets.dart';

/// The family's plan. Paying happens on Stripe's own page, in the browser.
class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  Account? _account;
  String _error = '';
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_account == null && _error.isEmpty) _load();
  }

  Future<void> _load() async {
    try {
      final a = await SessionScope.of(context).api.get('billing', '/account');
      setState(() => _account = Account.fromJson(a as Map<String, dynamic>));
    } catch (e) {
      setState(() => _error = errorText(e));
    }
  }

  Future<void> _open(String path, [Map<String, Object?>? body]) async {
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      final r = await SessionScope.of(context).api.post('billing', path, body);
      final url = r is Map ? r['url'] as String? : null;
      if (url != null) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else if (r is Map && r['message'] != null) {
        setState(() => _error = r['message'].toString());
      }
      await _load();
    } catch (e) {
      setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _status(Account a) => switch (a.status) {
        'trialing' => 'Free trial: ${a.trialDaysLeft} days left',
        'active' => a.cancelAtPeriodEnd ? 'Ends at the end of this period' : 'Active (${a.plan ?? ''})',
        'past_due' => 'Payment failed: please update your card',
        'cancelled' => 'Cancelled',
        _ => 'Free: ${a.freeDailyQuestions} questions a day',
      };

  @override
  Widget build(BuildContext context) {
    final a = _account;
    return AppPage(title: 'Plan', children: [
      ErrorNotice(_error),
      if (a == null && _error.isEmpty) const Center(child: CircularProgressIndicator()),
      if (a != null) ...[
        Card(
          color: a.status == 'past_due' ? Brand.badSoft : Brand.blueSoft,
          child: ListTile(title: Text(_status(a), style: const TextStyle(fontWeight: FontWeight.w700))),
        ),
        if (a.paymentsMode == 'test')
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('This is the test site: no real payments are taken.', style: TextStyle(color: Brand.muted)),
          ),
        const SizedBox(height: 12),
        if (a.status != 'active' || a.cancelAtPeriodEnd) ...[
          FilledButton(
            onPressed: _busy ? null : () => _open('/checkout', {'interval': 'monthly'}),
            child: Text('Monthly · ${pounds(a.monthlyPence)}'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _busy ? null : () => _open('/checkout', {'interval': 'yearly'}),
            child: Text('Yearly · ${pounds(a.yearlyPence)}'),
          ),
        ] else
          OutlinedButton(
            onPressed: _busy ? null : () => _open('/portal'),
            child: const Text('Change card, plan or cancel'),
          ),
        const SizedBox(height: 16),
        const Text('Payments open on Stripe in your browser; come back here when you are done.',
            style: TextStyle(color: Brand.muted)),
      ],
    ]);
  }
}
