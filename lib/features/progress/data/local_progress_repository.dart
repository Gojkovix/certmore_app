import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/practice_record.dart';
import 'progress_repository.dart';

/// DEMO: napredek je shranjen samo na tej napravi, ločeno za vsak račun.
class LocalProgressRepository implements ProgressRepository {
  LocalProgressRepository(this._prefs);

  final SharedPreferences _prefs;

  static String _key(String userId) => 'progress.v1.$userId';

  @override
  Future<List<PracticeRecord>> load(String userId) async {
    final raw = _prefs.getString(_key(userId));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<Object?>;
      return [
        for (final item in list)
          PracticeRecord.fromJson(item as Map<String, Object?>),
      ];
    } on FormatException {
      return [];
    }
  }

  @override
  Future<void> add(String userId, PracticeRecord record) async {
    final records = [record, ...await load(userId)];
    await _prefs.setString(
      _key(userId),
      jsonEncode([for (final r in records) r.toJson()]),
    );
  }
}
