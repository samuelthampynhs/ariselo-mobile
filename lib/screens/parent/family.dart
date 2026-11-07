import 'package:flutter/material.dart';

import '../../api.dart';
import '../../avatars.dart';
import '../../models.dart';
import '../../theme.dart';
import '../../widgets.dart';
import 'child_edit.dart';
import 'child_report.dart';
import 'plan.dart';
import 'settings.dart';

/// The parent's home: their children, the family code, and the way to each child's report.
class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  Family? _family;
  String _error = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_family == null) _load();
  }

  Future<void> _load() async {
    try {
      final f = Family.fromJson((await SessionScope.of(context).api.get('identity', '/family')) as Map<String, dynamic>);
      setState(() {
        _family = f;
        _error = '';
      });
    } catch (e) {
      setState(() => _error = errorText(e));
    }
  }

  Future<void> _edit([Child? child]) async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => ChildEditScreen(child: child)));
    if (changed == true) _load();
  }

  /// Hands the phone to a child: their session, straight into learning.
  Future<void> _start(Child c) async {
    final s = SessionScope.of(context);
    try {
      await s.api.post('identity', '/family/children/${c.id}/start');
      await s.refresh();
    } catch (e) {
      setState(() => _error = errorText(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = SessionScope.of(context).me;
    final f = _family;
    void go(Widget w) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, ${me?.name.split(' ').first ?? ''}'),
        actions: [
          IconButton(
            tooltip: 'Plan',
            icon: const Icon(Icons.workspace_premium_outlined),
            onPressed: () => go(const PlanScreen()),
          ),
          IconButton(tooltip: 'Settings', icon: const Icon(Icons.settings_outlined), onPressed: () => go(const SettingsScreen())),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: const Text('Add a child'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              ErrorNotice(_error),
              if (me?.emailVerified == false)
                Card(
                  color: Brand.sunSoft,
                  child: ListTile(
                    title: const Text('Please confirm your email'),
                    subtitle: const Text('We sent you a link. It keeps your account safe.'),
                    trailing: TextButton(
                      onPressed: () => SessionScope.of(context).api.post('identity', '/email/verify/resend'),
                      child: const Text('Send again'),
                    ),
                  ),
                ),
              if (f == null && _error.isEmpty) const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
              if (f != null) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.key_outlined, color: Brand.blue),
                    title: const Text('Family code'),
                    subtitle: const Text('Children type this to log in on their own.'),
                    trailing: SelectableText(f.familyCode,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                  ),
                ),
                const SizedBox(height: 12),
                if (f.children.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text('Add your first child to get started.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                  ),
                for (final c in f.children)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(children: [
                            AvatarCircle(c.avatar),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(c.name, style: Theme.of(context).textTheme.titleLarge),
                                Text(yearName(c.year), style: Theme.of(context).textTheme.bodySmall),
                              ]),
                            ),
                            IconButton(tooltip: 'Change ${c.name}', icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(c)),
                          ]),
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => go(ChildReportScreen(child: c)),
                                child: const Text('Progress'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: FilledButton(onPressed: () => _start(c), child: Text('Start ${c.name}'))),
                          ]),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
