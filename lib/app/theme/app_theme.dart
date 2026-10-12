import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.navy,
      onPrimary: Colors.white,
      secondary: AppColors.teal,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTypography.textTheme,
      splashFactory: InkRipple.splashFactory,
      highlightColor: AppColors.navy.withValues(alpha: 0.04),
      splashColor: AppColors.navy.withValues(alpha: 0.04),
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _CertmorePageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.surface,
        headerForegroundColor: AppColors.textPrimary,
        dividerColor: AppColors.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.large)),
        ),
        todayForegroundColor: const WidgetStatePropertyAll(AppColors.teal),
        todayBorder: const BorderSide(color: AppColors.teal),
        dayBackgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.teal
              : null,
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColors.navy,
          textStyle: AppTypography.label,
        ),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          textStyle: AppTypography.label,
        ),
      ),
    );
  }
}

/// Mirna prehodna animacija med zasloni: nov zaslon rahlo pripelje z desne
/// in se pojavi, prejšnji se umakne. Ob vklopljenem "zmanjšaj gibanje"
/// prehoda ni.
class _CertmorePageTransitionsBuilder extends PageTransitionsBuilder {
  const _CertmorePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final incoming = CurvedAnimation(
      parent: animation,
      curve: AppMotion.standard,
      reverseCurve: Curves.easeInCubic,
    );
    final outgoing = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppMotion.standard,
      reverseCurve: Curves.easeInCubic,
    );

    return SlideTransition(
      position: Tween(begin: Offset.zero, end: const Offset(-0.04, 0))
          .animate(outgoing),
      child: FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.0).animate(outgoing),
        child: SlideTransition(
          position: Tween(begin: const Offset(0.06, 0), end: Offset.zero)
              .animate(incoming),
          child: FadeTransition(opacity: incoming, child: child),
        ),
      ),
    );
  }
}
