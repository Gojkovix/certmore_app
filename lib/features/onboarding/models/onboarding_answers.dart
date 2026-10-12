import '../../../core/utils/date_format.dart';

/// Odgovori iz onboardinga. Nespremenljiv razred — vsaka sprememba
/// ustvari novo instanco s [copyWith], kar olajša sledenje stanju.
class OnboardingAnswers {
  const OnboardingAnswers({
    this.discovery,
    this.goal,
    this.examTiming,
    this.examDate,
    this.knowledge,
  });

  final DiscoverySource? discovery;
  final PreparationGoal? goal;
  final ExamTiming? examTiming;

  /// Točen datum izpita, če ga uporabnik pozna. Ko je nastavljen,
  /// je [examTiming] izpeljan iz njega.
  final DateTime? examDate;
  final KnowledgeLevel? knowledge;

  OnboardingAnswers copyWith({
    DiscoverySource? discovery,
    PreparationGoal? goal,
    KnowledgeLevel? knowledge,
  }) {
    return OnboardingAnswers(
      discovery: discovery ?? this.discovery,
      goal: goal ?? this.goal,
      examTiming: examTiming,
      examDate: examDate,
      knowledge: knowledge ?? this.knowledge,
    );
  }

  /// Izbira okvirnega obdobja počisti morebitni točen datum.
  OnboardingAnswers withExamTiming(ExamTiming timing) {
    return OnboardingAnswers(
      discovery: discovery,
      goal: goal,
      examTiming: timing,
      knowledge: knowledge,
    );
  }

  OnboardingAnswers withExamDate(DateTime date, {required DateTime today}) {
    return OnboardingAnswers(
      discovery: discovery,
      goal: goal,
      examTiming: ExamTiming.fromDate(date, today: today),
      examDate: date,
      knowledge: knowledge,
    );
  }

  Map<String, Object?> toJson() => {
    'discovery': discovery?.name,
    'goal': goal?.name,
    'examTiming': examTiming?.name,
    'examDate': examDate?.toIso8601String(),
    'knowledge': knowledge?.name,
  };

  factory OnboardingAnswers.fromJson(Map<String, Object?> json) {
    T? byName<T extends Enum>(List<T> values, Object? name) =>
        values.where((v) => v.name == name).firstOrNull;
    final examDate = json['examDate'] as String?;

    return OnboardingAnswers(
      discovery: byName(DiscoverySource.values, json['discovery']),
      goal: byName(PreparationGoal.values, json['goal']),
      examTiming: byName(ExamTiming.values, json['examTiming']),
      examDate: examDate == null ? null : DateTime.tryParse(examDate),
      knowledge: byName(KnowledgeLevel.values, json['knowledge']),
    );
  }
}

enum DiscoverySource {
  instagram('Instagram'),
  facebook('Facebook'),
  google('Google'),
  referral('Priporočilo prijatelja ali sodelavca'),
  other('Drugo');

  const DiscoverySource(this.label);
  final String label;
}

enum PreparationGoal {
  starting('Začenjam s pripravami.'),
  strengthen('Želim utrditi svoje znanje.'),
  checkReadiness('Želim preveriti pripravljenost na izpit.');

  const PreparationGoal(this.label);
  final String label;
}

enum ExamTiming {
  within30Days('V naslednjih 30 dneh.'),
  within3Months('V naslednjih 3 mesecih.'),
  later('Čez več kot 3 mesece.'),
  unknown('Datuma še ne poznam.');

  const ExamTiming(this.label);
  final String label;

  static ExamTiming fromDate(DateTime date, {required DateTime today}) {
    final days = daysBetween(today, date);
    if (days <= 30) return within30Days;
    if (days <= 92) return within3Months;
    return later;
  }
}

enum KnowledgeLevel {
  beginner('Šele spoznavam snov.'),
  some('Nekaj že znam.'),
  most('Večino snovi že poznam.'),
  practiceOnly('Želim predvsem vaditi vprašanja.');

  const KnowledgeLevel(this.label);
  final String label;
}
