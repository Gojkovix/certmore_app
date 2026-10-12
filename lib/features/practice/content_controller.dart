import 'data/content_repository.dart';
import 'models/question.dart';

/// Vsebino naloži enkrat ob zagonu in jo potem ponuja sinhrono,
/// da zaslonom ni treba čakati.
class ContentController {
  ContentController(this._repository);

  final ContentRepository _repository;

  List<Topic> _topics = const [];
  List<Question> _questions = const [];

  bool get isSample => _repository.isSample;
  List<Topic> get topics => _topics;
  List<Question> get questions => _questions;

  Future<void> load() async {
    _topics = await _repository.topics();
    _questions = await _repository.questions();
  }

  Topic? topic(String id) => _topics.where((t) => t.id == id).firstOrNull;

  List<Question> questionsFor(String topicId) =>
      _questions.where((q) => q.topicId == topicId).toList();

  Question? question(String id) =>
      _questions.where((q) => q.id == id).firstOrNull;
}
