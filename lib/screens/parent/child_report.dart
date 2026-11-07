import 'package:flutter/material.dart';

import '../../api.dart';
import '../../avatars.dart';
import '../../models.dart';
import '../../theme.dart';
import '../../widgets.dart';

/// How a child is doing: the last 30 days, each subject, and their latest answers.
class ChildReportScreen extends StatefulWidget {
  const ChildReportScreen({super.key, required this.child});
  final Child child;

  @override
  State<ChildReportScreen> createState() => _ChildReportScreenState();
}

class _ChildReportScreenState extends State<ChildReportScreen> {
  Report? _report;
  String _error = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_report == null && _error.isEmpty) _load();
  }

  Future<void> _load() async {
    try {
      final c = widget.child;
      final r = await SessionScope.of(context).api.get('practice', '/children/${c.id}/report?year=${c.year}&days=30');
      setState(() => _report = Report.fromJson(r as Map<String, dynamic>));
    } catch (e) {
      setState(() => _error = errorText(e));
    }
  }

  Widget _stat(String label, String value) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(children: [
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Brand.blue)),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Brand.muted)),
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final r = _report;
    final c = widget.child;
    return AppPage(title: "${c.name}'s progress", children: [
      Row(children: [
        AvatarCircle(c.avatar),
        const SizedBox(width: 12),
        Text('${c.name} · ${yearName(c.year)}', style: Theme.of(context).textTheme.titleLarge),
      ]),
      const SizedBox(height: 16),
      ErrorNotice(_error),
      if (r == null && _error.isEmpty) const Center(child: CircularProgressIndicator()),
      if (r != null) ...[
        const Text('Last 30 days', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(children: [
          _stat('questions', '${r.questions}'),
          _stat('right', r.rightPercent == null ? '–' : '${r.rightPercent}%'),
          _stat('days practised', '${r.daysPractised}'),
        ]),
        Row(children: [
          _stat('skills started', '${r.skillsStarted}'),
          _stat('skills mastered', '${r.skillsMastered}'),
        ]),
        const SizedBox(height: 16),
        const Text('Last 14 days', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _DaysChart(days: r.days),
        const SizedBox(height: 16),
        for (final e in r.subjects.entries)
          Card(
            child: ListTile(
              leading: Icon(e.key == 'Maths' ? Icons.calculate_outlined : Icons.menu_book_outlined,
                  color: e.key == 'Maths' ? Brand.blue : Brand.grape),
              title: Text(e.key),
              subtitle: Text('${e.value.$1} questions'),
              trailing: Text(e.value.$2 == null ? '–' : '${e.value.$2}% right',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        if (r.recent.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Latest answers', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final a in r.recent.take(15))
            Card(
              child: ListTile(
                leading: Icon(a.correct ? Icons.check_circle : Icons.cancel,
                    color: a.correct ? Brand.good : Brand.bad, semanticLabel: a.correct ? 'Right' : 'Not right'),
                title: Text(a.prompt, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(a.correct ? 'Answered ${a.given}' : 'Answered ${a.given} · the answer is ${a.answer}'),
              ),
            ),
        ],
      ],
    ]);
  }
}

/// Right and not-right answers for each of the last 14 days, as bars.
class _DaysChart extends StatelessWidget {
  const _DaysChart({required this.days});
  final List<DayCount> days;

  @override
  Widget build(BuildContext context) {
    final most = days.fold<int>(1, (m, d) => d.right + d.notRight > m ? d.right + d.notRight : m);
    final total = days.fold<int>(0, (s, d) => s + d.right + d.notRight);
    return Semantics(
      label: '$total questions in the last 14 days',
      child: ExcludeSemantics(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            child: SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final d in days)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                          Container(height: 96 * d.notRight / most, color: Brand.coral),
                          Container(height: 96 * d.right / most, color: Brand.good),
                          const SizedBox(height: 4),
                          Text(d.date.length >= 10 ? d.date.substring(8, 10) : '', style: const TextStyle(fontSize: 10, color: Brand.muted)),
                        ]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
