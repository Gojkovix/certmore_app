import 'package:flutter/material.dart';

/// Certmore barvna paleta.
///
/// Večino vmesnika nosijo nevtralne površine in temno besedilo;
/// [teal] je namerni poudarek blagovne znamke, ne privzeta barva.
abstract final class AppColors {
  // Blagovna znamka
  static const navy = Color(0xFF0D2638);
  static const teal = Color(0xFF16A394);

  // Površine
  static const background = Color(0xFFF8FCFB);
  static const surface = Color(0xFFFFFFFF);
  static const soft = Color(0xFFE9F4F1);

  /// Zelo rahel teal ton za izbrane elemente.
  static const tealTint = Color(0xFFF0F8F6);

  // Besedilo
  static const textPrimary = navy;
  static const textSecondary = Color(0xFF647780);
  static const muted = Color(0xFF7A9994);

  // Robovi
  static const border = Color(0xFFE4EBE9);

  // Stanja
  static const success = Color(0xFF16856D);
  static const warning = Color(0xFFB47A32);
  static const error = Color(0xFFBD514C);
}
