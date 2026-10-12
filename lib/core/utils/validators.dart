/// Preverjanje vnosov v obrazcih. Vsaka funkcija vrne sporočilo o napaki
/// ali `null`, če je vnos veljaven — to je oblika, ki jo pričakuje
/// `TextFormField.validator`.
abstract final class Validators {
  static const minPasswordLength = 8;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vpiši svoje ime.';
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Vpiši e-poštni naslov.';
    if (!_email.hasMatch(email)) return 'E-poštni naslov ni veljaven.';
    return null;
  }

  /// Za registracijo: preveri tudi dolžino.
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Vpiši geslo.';
    if (value.length < minPasswordLength) {
      return 'Geslo naj ima vsaj $minPasswordLength znakov.';
    }
    return null;
  }

  /// Za prijavo: samo, da ni prazno.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Vpiši geslo.';
    return null;
  }
}
