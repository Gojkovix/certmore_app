/// Tema izpitne snovi.
class Topic {
  const Topic({required this.id, required this.title});

  final String id;
  final String title;
}

/// Vprašanje z enim pravilnim odgovorom.
class Question {
  const Question({
    required this.id,
    required this.topicId,
    required this.text,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  final String id;
  final String topicId;
  final String text;
  final List<String> options;
  final int correctIndex;

  /// Pojasnilo pravilnega odgovora. `null`, če ga vir ne vsebuje —
  /// takrat ga ne prikažemo in si ga nikoli ne izmislimo.
  final String? explanation;
}
