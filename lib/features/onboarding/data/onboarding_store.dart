import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/onboarding_answers.dart';

/// Lokalno shrani odgovore iz onboardinga, da se ne izgubijo, če
/// uporabnik aplikacijo zapre pred registracijo.
///
/// Ko bo znan Certmore API, se bodo odgovori ob registraciji poslali
/// tudi na strežnik.
class OnboardingStore {
  OnboardingStore(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'onboarding.answers';

  OnboardingAnswers? load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      return OnboardingAnswers.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } on FormatException {
      return null;
    }
  }

  Future<void> save(OnboardingAnswers answers) =>
      _prefs.setString(_key, jsonEncode(answers.toJson()));
}
