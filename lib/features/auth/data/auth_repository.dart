import '../models/app_user.dart';

/// Meja med aplikacijo in avtentikacijo.
///
/// Zasloni poznajo samo ta vmesnik. Ko bo znan Certmore API (račun se
/// deli s spletno stranjo), dodamo `ApiAuthRepository` in ga zamenjamo
/// v `main.dart` — zaslonov ni treba spreminjati.
abstract interface class AuthRepository {
  /// `true`, če podatki ostanejo samo na tej napravi (demo način).
  bool get isLocal;

  /// Trenutno prijavljen uporabnik ali `null`.
  Future<AppUser?> currentUser();

  /// Vrže [AuthException], če račun že obstaja.
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  });

  /// Vrže [AuthException] ob napačnih podatkih.
  Future<AppUser> signIn({required String email, required String password});

  Future<void> signOut();
}

enum AuthFailure {
  emailTaken('Račun s tem e-poštnim naslovom že obstaja.'),
  invalidCredentials('E-poštni naslov ali geslo ni pravilno.'),
  unknown('Nekaj je šlo narobe. Poskusi znova.');

  const AuthFailure(this.message);

  /// Sporočilo, primerno za prikaz uporabniku.
  final String message;
}

class AuthException implements Exception {
  const AuthException(this.failure);

  final AuthFailure failure;

  @override
  String toString() => 'AuthException(${failure.name})';
}
