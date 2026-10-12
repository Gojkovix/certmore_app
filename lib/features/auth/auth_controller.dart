import 'package:flutter/foundation.dart';

import 'data/auth_repository.dart';
import 'models/app_user.dart';

/// Hrani stanje prijave za celotno aplikacijo.
///
/// ChangeNotifier je vgrajen v Flutter: ko se uporabnik spremeni,
/// pokličemo [notifyListeners] in vsi poslušalci (npr. ListenableBuilder)
/// se osvežijo.
class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  AppUser? _user;
  AppUser? get user => _user;
  bool get isSignedIn => _user != null;
  bool get isLocal => _repository.isLocal;

  /// Ob zagonu aplikacije obnovi morebitno obstoječo sejo.
  Future<void> restore() async {
    _user = await _repository.currentUser();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) => _run(
    () => _repository.register(name: name, email: email, password: password),
  );

  Future<void> signIn({required String email, required String password}) =>
      _run(() => _repository.signIn(email: email, password: password));

  Future<void> signOut() async {
    await _repository.signOut();
    _user = null;
    notifyListeners();
  }

  /// Vse nepričakovane napake pretvori v [AuthException], da zasloni
  /// uporabniku nikoli ne pokažejo surove izjeme.
  Future<void> _run(Future<AppUser> Function() action) async {
    try {
      _user = await action();
      notifyListeners();
    } on AuthException {
      rethrow;
    } catch (error, stack) {
      debugPrint('Auth error: $error\n$stack');
      throw const AuthException(AuthFailure.unknown);
    }
  }
}
