import 'package:flutter/material.dart';

import '../../api.dart';
import '../../avatars.dart';
import '../../models.dart';
import '../../theme.dart';
import '../../widgets.dart';

/// Add a child, or change one: name, year group, picture and PIN.
class ChildEditScreen extends StatefulWidget {
  const ChildEditScreen({super.key, this.child});
  final Child? child;

  @override
  State<ChildEditScreen> createState() => _ChildEditScreenState();
}

class _ChildEditScreenState extends State<ChildEditScreen> {
  late final _name = TextEditingController(text: widget.child?.name ?? '');
  final _pin = TextEditingController();
  late int _year = widget.child?.year ?? 2;
  late String _avatar = widget.child?.avatar ?? 'fox';
  bool _busy = false;
  String _error = '';

  bool get _isNew => widget.child == null;

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = '';
    });
    final api = SessionScope.of(context).api;
    final body = {
      'name': _name.text.trim(),
      'year': _year,
      'avatar': _avatar,
      if (_pin.text.isNotEmpty || _isNew) 'pin': _pin.text,
    };
    try {
      if (_isNew) {
        await api.post('identity', '/family/children', body);
      } else {
        await api.patch('identity', '/family/children/${widget.child!.id}', body);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    final c = widget.child!;
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove ${c.name}?'),
        content: const Text('Their progress is deleted too. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Brand.bad),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    try {
      await SessionScope.of(context).api.delete('identity', '/family/children/${c.id}');
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = errorText(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(title: _isNew ? 'Add a child' : 'Change ${widget.child!.name}', children: [
      TextField(controller: _name, decoration: const InputDecoration(labelText: 'First name'), maxLength: 20),
      const SizedBox(height: 8),
      const Text('Year group', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (var y = 0; y <= 6; y++)
          ChoiceChip(label: Text(y == 0 ? 'Reception' : 'Y$y'), selected: _year == y, onSelected: (_) => setState(() => _year = y)),
      ]),
      const SizedBox(height: 20),
      const Text('Picture', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Wrap(spacing: 10, runSpacing: 10, children: [
        for (final a in avatars.keys)
          Semantics(
            label: a,
            selected: _avatar == a,
            button: true,
            child: InkWell(
              onTap: () => setState(() => _avatar = a),
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _avatar == a ? Brand.blue : Colors.transparent, width: 3),
                ),
                child: AvatarCircle(a, size: 52),
              ),
            ),
          ),
      ]),
      const SizedBox(height: 20),
      TextField(
        controller: _pin,
        decoration: InputDecoration(
          labelText: _isNew ? '4-number PIN' : 'New PIN (leave empty to keep it)',
          helperText: 'Your child types this to log in.',
        ),
        keyboardType: TextInputType.number,
        maxLength: 4,
        obscureText: true,
      ),
      ErrorNotice(_error),
      const SizedBox(height: 8),
      FilledButton(onPressed: _busy ? null : _save, child: Text(_isNew ? 'Add' : 'Save')),
      if (!_isNew) ...[
        const SizedBox(height: 24),
        TextButton(
          onPressed: _remove,
          style: TextButton.styleFrom(foregroundColor: Brand.bad),
          child: Text('Remove ${widget.child!.name}'),
        ),
      ],
    ]);
  }
}
