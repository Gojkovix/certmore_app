import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_scope.dart';
import 'router.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class CertmoreApp extends StatelessWidget {
  const CertmoreApp({super.key, required this.services});

  final AppServices services;

  static const _systemUiStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  );

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: services,
      child: MaterialApp(
        title: 'Certmore',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        color: AppColors.background,
        locale: const Locale('sl'),
        supportedLocales: const [Locale('sl')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        // Prijavljen uporabnik gre naravnost na Domov. Uporabimo samo eno
        // začetno ruto, da "nazaj" z Domov ne vodi na welcome.
        onGenerateInitialRoutes: (_) => [
          onGenerateRoute(
            RouteSettings(
              name: services.auth.isSignedIn
                  ? AppRoutes.home
                  : AppRoutes.welcome,
            ),
          ),
        ],
        onGenerateRoute: onGenerateRoute,
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: _systemUiStyle,
          child: child!,
        ),
      ),
    );
  }
}
