import 'package:flutter/material.dart';

/// Paleta Volver: papel, tinta y arcilla.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFA7543D);
  static const Color primaryDark = Color(0xFF783A2A);
  static const Color primaryLight = Color(0xFFC8795E);
  static const Color background = Color(0xFFF4F0E7);
  static const Color backgroundLight = Color(0xFFEAE4DB);
  static const Color surface = Color(0xFFEAE4DB);
  static const Color textPrimary = Color(0xFF302D29);
  static const Color textSecondary = Color(0xFF5D554E);
  static const Color textMuted = Color(0xFF746B63);
  static const Color accent = Color(0xFFA7543D);
  static const Color accentSoft = Color(0xFFC8795E);
  static const Color success = Color(0xFF42634D);
  static const Color warning = Color(0xFF8B5B22);
  static const Color error = Color(0xFF9C382E);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundLight],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );
}
