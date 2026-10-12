import 'package:certmore/app/app.dart';
import 'package:certmore/features/auth/data/local_auth_repository.dart';
import 'package:certmore/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Zažene celotno aplikacijo z lažno lokalno hrambo ([storage]).
///
/// Testi tečejo z vklopljenim "zmanjšaj gibanje", zato se typewriter ne
/// vrti in pumpAndSettle zanesljivo konča.
Future<void> pumpApp(
  WidgetTester tester, {
  Map<String, Object> storage = const {},
}) async {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  SharedPreferences.setMockInitialValues(storage);
  final prefs = await SharedPreferences.getInstance();
  final services = await createServices(prefs);

  await tester.pumpWidget(CertmoreApp(services: services));
  await tester.pumpAndSettle();
}

/// Hramba z registriranim in prijavljenim uporabnikom (Ana).
///
/// Registracija ima umetni zamik (simulacija omrežja), ki v lažnem času
/// testa ne bi nikoli potekel — zato jo izvedemo v `runAsync`.
Future<Map<String, Object>> signedInStorage(WidgetTester tester) async {
  final storage = await tester.runAsync(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await LocalAuthRepository(
      prefs,
    ).register(name: 'Ana Novak', email: 'ana@primer.si', password: 'geslo123');
    return {for (final key in prefs.getKeys()) key: prefs.get(key)!};
  });
  return storage!;
}
