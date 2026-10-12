import 'package:flutter/widgets.dart';

import '../features/auth/auth_controller.dart';
import '../features/onboarding/data/onboarding_store.dart';
import '../features/practice/content_controller.dart';
import '../features/progress/progress_controller.dart';

/// Vse storitve aplikacije na enem mestu. Ustvarijo se v `main.dart`
/// (v testih pa z lažno hrambo).
class AppServices {
  const AppServices({
    required this.auth,
    required this.onboardingStore,
    required this.content,
    required this.progress,
  });

  final AuthController auth;
  final OnboardingStore onboardingStore;
  final ContentController content;
  final ProgressController progress;
}

/// Storitve, dostopne vsem zaslonom: `AppScope.of(context).auth`.
///
/// InheritedWidget je Flutterjev vgrajen način za posredovanje podatkov
/// navzdol po drevesu — za nekaj storitev ne potrebujemo paketa,
/// kot je provider.
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope ni najden nad tem widgetom.');
    return scope!.services;
  }

  /// Storitve se med delovanjem ne zamenjajo; spremembe stanja
  /// sporočajo kontrolerji sami (ChangeNotifier).
  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}
