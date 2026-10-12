import '../models/practice_record.dart';

/// Shranjevanje napredka uporabnika.
///
/// Trenutno lokalno ([LocalProgressRepository]); kasneje Certmore API,
/// da bo napredek viden tudi na spletni strani.
abstract interface class ProgressRepository {
  /// Vse vaje uporabnika, od najnovejše do najstarejše.
  Future<List<PracticeRecord>> load(String userId);

  Future<void> add(String userId, PracticeRecord record);
}
