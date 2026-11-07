import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api.dart';
import '../../avatars.dart';
import '../../models.dart';
import '../../theme.dart';
import '../../widgets.dart';

/// Children log in: family code → tap your picture → 4-number PIN. No names or emails to type.
class KidsLoginScreen extends StatefulWidget {
  const KidsLoginScreen({super.key});

  @override
  State<KidsLoginScreen> createState() => _KidsLoginScreenState();
}

class _KidsLoginScreenState extends State<KidsLoginScreen> {
  static const _saved = 'ariselo.familyCode';
  final _code = TextEditingController();
  List<Child>? _kids;
  Child? _kid;
  String _pin = '';
  String _error = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      final c = p.getString(_saved);
      if (c != null && c.isNotEmpty && mounted) {
        _code.text = c;
        _find();
      }
    });
  }

  Future<void> _find() async {
    setState(() => _error = '');
    final code = _code.text.trim().toUpperCase();
    try {
      final r = await SessionScope.of(context).api.get('identity', '/kids/${Uri.encodeComponent(code)}');
      final kids = [for (final c in (r as Map)['children'] as List) Child.fromJson(c as Map<String, dynamic>)];
      (await SharedPreferences.getInstance()).setString(_saved, code);
      setState(() => _kids = kids);
    } catch (e) {
      setState(() {
        _kids = null;
        _error = errorText(e);
      });
    }
  }

  Future<void> _pinChanged(String pin) async {
    setState(() => _pin = pin);
    if (pin.length < 4 || _kid == null || _busy) return;
    setState(() => _busy = true);
    final s = SessionScope.of(context);
    final nav = Navigator.of(context);
    try {
      await s.api.post('identity', '/kids/login', {
        'family_code': _code.text.trim().toUpperCase(),
        'child_id': _kid!.id,
        'pin': pin,
      });
      await s.refresh();
      nav.popUntil((r) => r.isFirst);
    } catch (e) {
      setState(() {
        _error = errorText(e);
        _pin = '';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kids = _kids;
    final kid = _kid;
    final title = Theme.of(context).textTheme.headlineMedium;
    return Scaffold(
      appBar: AppBar(
        leading: kid != null || kids != null
            ? BackButton(onPressed: () => setState(() {
                  if (kid != null) {
                    _kid = null;
                    _pin = '';
                  } else {
                    _kids = null;
                  }
                  _error = '';
                }))
            : null,
      ),
      backgroundColor: Brand.blueSoft,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (kids == null) ...[
                  Text('Hello! 👋', style: title, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  const Text('Type your family code. Your grown-up has it.',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _code,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    autocorrect: false,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 2),
                    decoration: const InputDecoration(hintText: 'OWL-4821', labelText: 'Family code'),
                    onSubmitted: (_) => _find(),
                  ),
                  ErrorNotice(_error),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _find, child: const Text('Next')),
                ] else if (kid == null) ...[
                  Text("Who's learning?", style: title, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  if (kids.isEmpty)
                    const Text('No children yet. Ask your grown-up to add you.', textAlign: TextAlign.center)
                  else
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        for (final k in kids)
                          SizedBox(
                            width: 130,
                            child: Card(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => setState(() {
                                  _kid = k;
                                  _pin = '';
                                  _error = '';
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(children: [
                                    AvatarCircle(k.avatar, size: 76),
                                    const SizedBox(height: 8),
                                    Text(k.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                                    Text(yearName(k.year), style: const TextStyle(color: Brand.muted)),
                                  ]),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ] else ...[
                  Center(child: AvatarCircle(kid.avatar, size: 84)),
                  const SizedBox(height: 10),
                  Text('Hi ${kid.name}! Type your PIN.', style: title, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  PinPad(value: _pin, onChanged: _pinChanged, enabled: !_busy),
                  ErrorNotice(_error),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
