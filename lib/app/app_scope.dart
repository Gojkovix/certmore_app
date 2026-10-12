import 'package:flutter/widgets.dart';

import '../features/auth/auth_controller.dart';
import '../features/onboarding/data/onboarding_store.dart';

/// Storitve, dostopne vsem zaslonom: `AppScope.of(context).auth`.
///
/// InheritedWidget je Flutterjev vgrajen način za posredovanje podatkov
/// navzdol po drevesu — za nekaj storitev ne potrebujemo paketa,
/// kot je provider.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.auth,
    required this.onboardingStore,
    required super.child,
  });

  final AuthController auth;
  final OnboardingStore onboardingStore;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope ni najden nad tem widgetom.');
    return scope!;
  }

  /// Storitve se med delovanjem ne zamenjajo; spremembe stanja
  /// sporoča AuthController sam.
  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      auth != oldWidget.auth || onboardingStore != oldWidget.onboardingStore;
}
