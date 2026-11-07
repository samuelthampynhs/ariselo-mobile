import 'package:ariselo_mobile/avatars.dart';
import 'package:ariselo_mobile/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('family and children read from the API shape', () {
    final f = Family.fromJson({
      'id': 'f1',
      'family_code': 'OWL-4821',
      'delete_after': null,
      'children': [
        {'id': 'c1', 'name': 'Asha', 'year': 3, 'avatar': 'owl'},
      ],
    });
    expect(f.familyCode, 'OWL-4821');
    expect(f.children.single.name, 'Asha');
    expect(yearName(f.children.single.year), 'Year 3');
    expect(yearName(0), 'Reception');
    expect(avatarFor('owl'), '🦉');
    expect(avatarFor('nope'), '🙂');
  });

  test('a report with no practice yet', () {
    final r = Report.fromJson({
      'totals': {'questions': 0, 'right_percent': null, 'days_practised': 0, 'skills_started': 0, 'skills_mastered': 0},
      'last_14_days': [
        {'date': '2026-11-07', 'right': 3, 'not_right': 1},
      ],
      'skills': [],
      'subjects': {
        'Maths': {'questions': 4, 'right_percent': 75.0},
        'English': {'questions': 0, 'right_percent': null},
      },
      'mocks': [],
      'recent': [
        {'at': 'x', 'skill_id': 's', 'prompt': '2 + 2', 'given': '4', 'answer': '4', 'correct': true, 'mock': false},
      ],
    });
    expect(r.rightPercent, isNull);
    expect(r.days.single.right, 3);
    expect(r.subjects['Maths'], (4, 75));
    expect(r.subjects['English']!.$2, isNull);
    expect(r.recent.single.correct, isTrue);
  });

  test('prices in pounds', () {
    expect(pounds(799), '£7.99');
    expect(pounds(7000), '£70');
  });

  test('me knows whether it is a child or a parent', () {
    expect(Me.fromJson({'id': 'a', 'role': 'child', 'name': 'Asha'}).isChild, isTrue);
    expect(Me.fromJson({'id': 'b', 'role': 'parent', 'name': 'Jiku'}).isParent, isTrue);
  });
}
