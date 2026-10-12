import 'package:flutter/material.dart' show ChangeNotifier, DateUtils;

import '../auth/auth_controller.dart';
import 'data/progress_repository.dart';
import 'models/practice_record.dart';

/// Statistika za eno temo.
class TopicStats {
  const TopicStats({required this.answered, required this.correct});

  final int answered;
  final int correct;

  /// Delež pravilnih (0–1) ali `null`, če še ni odgovorov.
  double? get accuracy => answered == 0 ? null : correct / answered;
}

/// Napredek prijavljenega uporabnika. Vse vrednosti so izračunane iz
/// dejanskih odgovorov — če podatkov ni, so prazne, nikoli izmišljene.
class ProgressController extends ChangeNotifier {
  ProgressController(this._repository, this._auth) {
    _auth.addListener(_reload);
  }

  final ProgressRepository _repository;
  final AuthController _auth;

  /// Teme z vsaj toliko odgovori lahko predlagamo za ponavljanje.
  static const minAnswersForRecommendation = 3;

  List<PracticeRecord> _records = const [];

  /// Vaje od najnovejše do najstarejše.
  List<PracticeRecord> get records => _records;
  bool get hasActivity => _records.isNotEmpty;

  Iterable<AnswerRecord> get _answers => _records.expand((r) => r.answers);

  int get answeredCount => _answers.length;
  int get correctCount => _answers.where((a) => a.correct).length;
  double? get accuracy =>
      answeredCount == 0 ? null : correctCount / answeredCount;

  PracticeRecord? get lastRecord => _records.firstOrNull;

  int answeredOn(DateTime day) => _records
      .where((r) => DateUtils.isSameDay(r.finishedAt, day))
      .fold(0, (sum, r) => sum + r.answers.length);

  TopicStats statsFor(String topicId) {
    final answers = _answers.where((a) => a.topicId == topicId);
    return TopicStats(
      answered: answers.length,
      correct: answers.where((a) => a.correct).length,
    );
  }

  /// Tema z najnižjo uspešnostjo (pod 70 %), če ima dovolj odgovorov.
  String? weakestTopic(Iterable<String> topicIds) {
    String? weakest;
    double lowest = 0.7;
    for (final id in topicIds) {
      final stats = statsFor(id);
      final accuracy = stats.accuracy;
      if (stats.answered < minAnswersForRecommendation || accuracy == null) {
        continue;
      }
      if (accuracy < lowest) {
        lowest = accuracy;
        weakest = id;
      }
    }
    return weakest;
  }

  /// Vprašanja, pri katerih je bil zadnji odgovor napačen.
  List<String> get questionsToReview {
    final latest = <String, bool>{};
    for (final record in _records) {
      for (final answer in record.answers) {
        latest.putIfAbsent(answer.questionId, () => answer.correct);
      }
    }
    return [
      for (final entry in latest.entries)
        if (!entry.value) entry.key,
    ];
  }

  Future<void> load() async {
    final user = _auth.user;
    _records = user == null ? const [] : await _repository.load(user.email);
    notifyListeners();
  }

  Future<void> add(PracticeRecord record) async {
    final user = _auth.user;
    if (user == null) return;
    await _repository.add(user.email, record);
    _records = [record, ..._records];
    notifyListeners();
  }

  void _reload() => load();

  @override
  void dispose() {
    _auth.removeListener(_reload);
    super.dispose();
  }
}
