import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import 'auth_repository.dart';

/// DEMO: računi so shranjeni samo na tej napravi.
///
/// Namenjeno razvoju vmesnika, dokler Certmore API ni povezan. Gesla se
/// nikoli ne shranijo v izvirni obliki — samo zgoščena vrednost (SHA-256)
/// z naključno soljo.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _accountsKey = 'demo_auth.accounts';
  static const _sessionKey = 'demo_auth.session';

  /// Kratek zamik, da so stanja nalaganja vidna kot pri pravem omrežju.
  static const _latency = Duration(milliseconds: 350);

  @override
  bool get isLocal => true;

  @override
  Future<AppUser?> currentUser() async {
    final email = _prefs.getString(_sessionKey);
    if (email == null) return null;
    final account = _accounts()[email];
    if (account == null) return null;
    return AppUser(name: account['name'] as String, email: email);
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);
    final key = _normalize(email);
    final accounts = _accounts();
    if (accounts.containsKey(key)) {
      throw const AuthException(AuthFailure.emailTaken);
    }

    final salt = _randomSalt();
    accounts[key] = {
      'name': name.trim(),
      'salt': salt,
      'hash': _hash(password, salt),
    };
    await _prefs.setString(_accountsKey, jsonEncode(accounts));
    await _prefs.setString(_sessionKey, key);
    return AppUser(name: name.trim(), email: key);
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);
    final key = _normalize(email);
    final account = _accounts()[key];
    if (account == null ||
        _hash(password, account['salt'] as String) != account['hash']) {
      throw const AuthException(AuthFailure.invalidCredentials);
    }
    await _prefs.setString(_sessionKey, key);
    return AppUser(name: account['name'] as String, email: key);
  }

  @override
  Future<void> signOut() => _prefs.remove(_sessionKey);

  Map<String, Map<String, Object?>> _accounts() {
    final raw = _prefs.getString(_accountsKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, Object?>;
    return decoded.map(
      (email, value) => MapEntry(email, value as Map<String, Object?>),
    );
  }

  static String _normalize(String email) => email.trim().toLowerCase();

  static String _randomSalt() {
    final random = Random.secure();
    return base64Url.encode(List.generate(16, (_) => random.nextInt(256)));
  }

  static String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();
}
