/// Prijavljen uporabnik.
class AppUser {
  const AppUser({required this.name, required this.email});

  final String name;
  final String email;

  /// Prvo ime za pozdrav ("Dobro jutro, Ana.").
  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  Map<String, Object?> toJson() => {'name': name, 'email': email};

  factory AppUser.fromJson(Map<String, Object?> json) => AppUser(
        name: json['name'] as String,
        email: json['email'] as String,
      );
}
