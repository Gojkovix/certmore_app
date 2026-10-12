import 'package:certmore/app/app.dart';
import 'package:certmore/features/auth/auth_controller.dart';
import 'package:certmore/features/auth/data/local_auth_repository.dart';
import 'package:certmore/features/onboarding/data/onboarding_store.dart';
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
  final auth = AuthController(LocalAuthRepository(prefs));
  await auth.restore();

  await tester.pumpWidget(
    CertmoreApp(auth: auth, onboardingStore: OnboardingStore(prefs)),
  );
  await tester.pumpAndSettle();
}
