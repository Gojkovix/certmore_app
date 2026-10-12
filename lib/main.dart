import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/data/local_auth_repository.dart';
import 'features/onboarding/data/onboarding_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Vsebina se izriše tudi pod statusno in navigacijsko vrstico;
  // SafeArea na posameznih zaslonih poskrbi za pravilne odmike.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final prefs = await SharedPreferences.getInstance();

  // Tukaj se izbere implementacija. Ko bo Certmore API znan, zamenjaj
  // LocalAuthRepository z API različico — ostala koda ostane enaka.
  final auth = AuthController(LocalAuthRepository(prefs));
  await auth.restore();

  runApp(CertmoreApp(auth: auth, onboardingStore: OnboardingStore(prefs)));
}
