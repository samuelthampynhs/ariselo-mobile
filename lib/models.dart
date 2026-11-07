/// The parts of the API the app uses (the website's frontend/src/api/types.ts is the reference).
class Me {
  Me({required this.id, required this.role, required this.name, this.email, this.year, this.avatar, this.emailVerified});

  final String id;
  final String role; // child | parent | staff | super
  final String name;
  final String? email;
  final int? year;
  final String? avatar;
  final bool? emailVerified;

  bool get isChild => role == 'child';
  bool get isParent => role == 'parent';

  factory Me.fromJson(Map<String, dynamic> j) => Me(
        id: j['id'] as String,
        role: j['role'] as String,
        name: (j['name'] ?? '') as String,
        email: j['email'] as String?,
        year: j['year'] as int?,
        avatar: j['avatar'] as String?,
        emailVerified: j['email_verified'] as bool?,
      );
}

class Child {
  Child({required this.id, required this.name, required this.year, required this.avatar});

  final String id;
  final String name;
  final int year;
  final String avatar;

  factory Child.fromJson(Map<String, dynamic> j) => Child(
        id: j['id'] as String,
        name: (j['name'] ?? '') as String,
        year: (j['year'] ?? 0) as int,
        avatar: (j['avatar'] ?? '') as String,
      );
}

class Family {
  Family({required this.id, required this.familyCode, required this.children, this.deleteAfter});

  final String id;
  final String familyCode;
  final List<Child> children;
  final String? deleteAfter;

  factory Family.fromJson(Map<String, dynamic> j) => Family(
        id: j['id'] as String,
        familyCode: (j['family_code'] ?? '') as String,
        children: [for (final c in (j['children'] as List? ?? const [])) Child.fromJson(c as Map<String, dynamic>)],
        deleteAfter: j['delete_after'] as String?,
      );
}

class DayCount {
  DayCount(this.date, this.right, this.notRight);
  final String date;
  final int right;
  final int notRight;
}

class RecentAnswer {
  RecentAnswer({required this.prompt, required this.given, required this.answer, required this.correct});
  final String prompt;
  final String given;
  final String answer;
  final bool correct;
}

class Report {
  Report({
    required this.questions,
    required this.rightPercent,
    required this.daysPractised,
    required this.skillsStarted,
    required this.skillsMastered,
    required this.days,
    required this.subjects,
    required this.recent,
  });

  final int questions;
  final int? rightPercent;
  final int daysPractised;
  final int skillsStarted;
  final int skillsMastered;
  final List<DayCount> days;

  /// "Maths" / "English" -> (questions, right percent)
  final Map<String, (int, int?)> subjects;
  final List<RecentAnswer> recent;

  static int? _pct(Object? v) => v == null ? null : (v as num).round();

  factory Report.fromJson(Map<String, dynamic> j) {
    final t = (j['totals'] ?? const {}) as Map<String, dynamic>;
    final subjects = <String, (int, int?)>{};
    ((j['subjects'] ?? const {}) as Map<String, dynamic>).forEach((k, v) {
      final m = v as Map<String, dynamic>;
      subjects[k] = ((m['questions'] ?? 0) as int, _pct(m['right_percent']));
    });
    return Report(
      questions: (t['questions'] ?? 0) as int,
      rightPercent: _pct(t['right_percent']),
      daysPractised: (t['days_practised'] ?? 0) as int,
      skillsStarted: (t['skills_started'] ?? 0) as int,
      skillsMastered: (t['skills_mastered'] ?? 0) as int,
      days: [
        for (final d in (j['last_14_days'] as List? ?? const []))
          DayCount((d as Map<String, dynamic>)['date'] as String, (d['right'] ?? 0) as int, (d['not_right'] ?? 0) as int),
      ],
      subjects: subjects,
      recent: [
        for (final r in (j['recent'] as List? ?? const []))
          RecentAnswer(
            prompt: ((r as Map<String, dynamic>)['prompt'] ?? '') as String,
            given: (r['given'] ?? '') as String,
            answer: (r['answer'] ?? '') as String,
            correct: (r['correct'] ?? false) as bool,
          ),
      ],
    );
  }
}

class Account {
  Account({
    required this.status,
    required this.plan,
    required this.trialDaysLeft,
    required this.fullAccess,
    required this.monthlyPence,
    required this.yearlyPence,
    required this.cancelAtPeriodEnd,
    required this.currentPeriodEnd,
    required this.paymentsMode,
    required this.freeDailyQuestions,
    this.referralCode = '',
    this.referralLink = '',
    this.referralMonths = 1,
    this.friendsJoined = 0,
    this.friendsPaid = 0,
    this.freeMonths = 0,
  });

  final String status; // trialing | active | cancelled | past_due | free
  final String? plan;
  final int trialDaysLeft;
  final bool fullAccess;
  final int monthlyPence;
  final int yearlyPence;
  final bool cancelAtPeriodEnd;
  final String? currentPeriodEnd;
  final String paymentsMode; // test | stripe
  final int freeDailyQuestions;

  /// Share Ariselo: friends who join with this code and pay give both families free months.
  final String referralCode;
  final String referralLink;
  final int referralMonths;
  final int friendsJoined;
  final int friendsPaid;
  final int freeMonths;

  factory Account.fromJson(Map<String, dynamic> j) {
    final q = (j['quote'] ?? const {}) as Map<String, dynamic>;
    return Account(
      status: (j['status'] ?? 'free') as String,
      plan: j['plan'] as String?,
      trialDaysLeft: (j['trial_days_left'] ?? 0) as int,
      fullAccess: (j['full_access'] ?? false) as bool,
      monthlyPence: (q['monthly'] ?? 0) as int,
      yearlyPence: (q['yearly'] ?? 0) as int,
      cancelAtPeriodEnd: (j['cancel_at_period_end'] ?? false) as bool,
      currentPeriodEnd: j['current_period_end'] as String?,
      paymentsMode: (j['payments_mode'] ?? 'test') as String,
      freeDailyQuestions: (j['free_daily_questions'] ?? 0) as int,
      referralCode: (j['referral_code'] ?? '') as String,
      referralLink: (j['referral_link'] ?? '') as String,
      referralMonths: (j['referral_free_months'] ?? 1) as int,
      friendsJoined: ((j['referrals'] ?? const {}) as Map)['joined'] as int? ?? 0,
      friendsPaid: ((j['referrals'] ?? const {}) as Map)['paid'] as int? ?? 0,
      freeMonths: (j['free_months'] ?? 0) as int,
    );
  }
}

String pounds(int pence) => '£${(pence / 100).toStringAsFixed(pence % 100 == 0 ? 0 : 2)}';
