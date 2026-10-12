import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/app_scope.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/data/local_auth_repository.dart';
import 'features/onboarding/data/onboarding_store.dart';
import 'features/practice/content_controller.dart';
import 'features/practice/data/sample_content_repository.dart';
import 'features/progress/data/local_progress_repository.dart';
import 'features/progress/progress_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Vsebina se izriše tudi pod statusno in navigacijsko vrstico;
  // SafeArea na posameznih zaslonih poskrbi za pravilne odmike.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final prefs = await SharedPreferences.getInstance();

  runApp(CertmoreApp(services: await createServices(prefs)));
}

/// Tukaj se izberejo implementacije. Ko bo Certmore API znan, zamenjaj
/// lokalne/vzorčne razrede z API različicami — zasloni ostanejo enaki.
Future<AppServices> createServices(SharedPreferences prefs) async {
  final auth = AuthController(LocalAuthRepository(prefs));
  await auth.restore();

  final content = ContentController(const SampleContentRepository());
  await content.load();

  final progress = ProgressController(LocalProgressRepository(prefs), auth);
  await progress.load();

  return AppServices(
    auth: auth,
    onboardingStore: OnboardingStore(prefs),
    content: content,
    progress: progress,
  );
}
