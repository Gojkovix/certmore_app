import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tipografska lestvica. Uporablja sistemsko pisavo (Roboto na Androidu,
/// SF Pro na iOS), zato ne potrebujemo dodatnih paketov s pisavami.
abstract final class AppTypography {
  static const display = TextStyle(
    fontSize: 36,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    color: AppColors.textPrimary,
  );

  static const headline = TextStyle(
    fontSize: 30,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.6,
    color: AppColors.textPrimary,
  );

  static const title = TextStyle(
    fontSize: 21,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static const cardTitle = TextStyle(
    fontSize: 17,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const bodySecondary = TextStyle(
    fontSize: 15,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const option = TextStyle(
    fontSize: 16,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const label = TextStyle(
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const caption = TextStyle(
    fontSize: 12.5,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  static const button = TextStyle(
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static TextTheme get textTheme => const TextTheme(
        displaySmall: display,
        headlineMedium: headline,
        titleLarge: title,
        titleMedium: cardTitle,
        bodyLarge: body,
        bodyMedium: bodySecondary,
        labelLarge: button,
        bodySmall: caption,
      );
}
