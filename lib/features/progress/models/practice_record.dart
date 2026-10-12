/// En odgovor znotraj vaje.
class AnswerRecord {
  const AnswerRecord({
    required this.questionId,
    required this.topicId,
    required this.selectedIndex,
    required this.correct,
  });

  final String questionId;
  final String topicId;
  final int selectedIndex;
  final bool correct;

  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'topicId': topicId,
    'selectedIndex': selectedIndex,
    'correct': correct,
  };

  factory AnswerRecord.fromJson(Map<String, Object?> json) => AnswerRecord(
    questionId: json['questionId'] as String,
    topicId: json['topicId'] as String,
    selectedIndex: json['selectedIndex'] as int,
    correct: json['correct'] as bool,
  );
}

/// Zaključena vaja.
class PracticeRecord {
  const PracticeRecord({
    required this.title,
    required this.finishedAt,
    required this.answers,
    this.topicId,
  });

  /// Naslov vaje, npr. ime teme ali "Mešana vaja".
  final String title;

  /// `null` pri mešani vaji.
  final String? topicId;
  final DateTime finishedAt;
  final List<AnswerRecord> answers;

  int get correctCount => answers.where((a) => a.correct).length;

  Map<String, Object?> toJson() => {
    'title': title,
    'topicId': topicId,
    'finishedAt': finishedAt.toIso8601String(),
    'answers': [for (final a in answers) a.toJson()],
  };

  factory PracticeRecord.fromJson(Map<String, Object?> json) => PracticeRecord(
    title: json['title'] as String,
    topicId: json['topicId'] as String?,
    finishedAt: DateTime.parse(json['finishedAt'] as String),
    answers: [
      for (final a in json['answers'] as List<Object?>)
        AnswerRecord.fromJson(a as Map<String, Object?>),
    ],
  );
}
