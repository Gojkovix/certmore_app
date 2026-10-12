import 'package:flutter/widgets.dart';

/// Lestvica razmikov. Uporabljaj samo te vrednosti.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
  static const double giant = 64;

  /// Standardni vodoravni odmik strani.
  static const double page = xl;

  static const pagePadding = EdgeInsets.symmetric(horizontal: page);
}

abstract final class AppRadii {
  static const double control = 12;
  static const double card = 14;
  static const double large = 20;

  static const controlRadius = BorderRadius.all(Radius.circular(control));
  static const cardRadius = BorderRadius.all(Radius.circular(card));
}

/// Trajanja in krivulje animacij — vse na enem mestu, da je gibanje
/// po celotni aplikaciji enotno.
abstract final class AppMotion {
  static const press = Duration(milliseconds: 120);
  static const selection = Duration(milliseconds: 180);
  static const page = Duration(milliseconds: 280);
  static const progress = Duration(milliseconds: 420);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubic;
}
