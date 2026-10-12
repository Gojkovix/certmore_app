import 'dart:math';

import '../content_controller.dart';

/// Kaj naj vaja vsebuje. Posreduje se zaslonu z vprašanji.
class PracticeRequest {
  const PracticeRequest({
    required this.title,
    required this.questionIds,
    this.topicId,
  });

  /// Kratka mešana vaja iz vseh tem.
  factory PracticeRequest.mixed(
    ContentController content, {
    int count = 5,
    Random? random,
  }) {
    final ids = [for (final q in content.questions) q.id]..shuffle(random);
    return PracticeRequest(
      title: 'Mešana vaja',
      questionIds: ids.take(count).toList(),
    );
  }

  /// Vsa vprašanja ene teme v naključnem vrstnem redu.
  factory PracticeRequest.topic(
    ContentController content,
    String topicId, {
    Random? random,
  }) {
    final ids = [for (final q in content.questionsFor(topicId)) q.id]
      ..shuffle(random);
    return PracticeRequest(
      title: content.topic(topicId)?.title ?? 'Vaja',
      topicId: topicId,
      questionIds: ids,
    );
  }

  /// Ponovitev vprašanj, pri katerih je bil odgovor napačen.
  factory PracticeRequest.review(List<String> questionIds) =>
      PracticeRequest(title: 'Ponovitev napačnih', questionIds: questionIds);

  final String title;
  final String? topicId;
  final List<String> questionIds;
}
