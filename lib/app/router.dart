import 'package:flutter/material.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/welcome/presentation/welcome_screen.dart';

/// Imena vseh rut na enem mestu.
abstract final class AppRoutes {
  static const welcome = '/';
  static const onboarding = '/onboarding';
  static const register = '/register';
  static const login = '/login';
  static const home = '/home';
}

/// Za trenutno število zaslonov zadošča vgrajeni Navigator; go_router
/// bomo razmislili, ko pride glavna aplikacija z zavihki in globokimi
/// povezavami.
Route<dynamic> onGenerateRoute(RouteSettings settings) {
  final Widget page = switch (settings.name) {
    AppRoutes.onboarding => const OnboardingScreen(),
    AppRoutes.register => const RegisterScreen(),
    AppRoutes.login => const LoginScreen(),
    AppRoutes.home => const HomeScreen(),
    _ => const WelcomeScreen(),
  };

  return MaterialPageRoute(settings: settings, builder: (_) => page);
}
