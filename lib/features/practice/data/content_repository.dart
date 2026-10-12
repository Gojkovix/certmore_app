import '../models/question.dart';

/// Vir izpitnih vsebin (teme in vprašanja).
///
/// Trenutno ga implementira [SampleContentRepository] z vzorčnimi
/// vprašanji. Ko bo znan Certmore API, dodamo API različico.
abstract interface class ContentRepository {
  /// `true`, če vsebina ni prava izpitna snov (vzorčna vprašanja).
  bool get isSample;

  Future<List<Topic>> topics();

  Future<List<Question>> questions();
}
