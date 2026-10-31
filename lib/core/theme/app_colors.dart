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

@immutable
class AppPalette {
  const AppPalette({
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.backgroundLight,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.error,
  });

  final Color primary, primaryLight, background, backgroundLight, surface;
  final Color textPrimary, textSecondary, textMuted, accent, error;

  LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundLight],
  );

  static const light = AppPalette(
    primary: Color(0xFFA7543D),
    primaryLight: Color(0xFFC8795E),
    background: Color(0xFFF4F0E7),
    backgroundLight: Color(0xFFEAE4DB),
    surface: Color(0xFFEAE4DB),
    textPrimary: Color(0xFF302D29),
    textSecondary: Color(0xFF5D554E),
    textMuted: Color(0xFF746B63),
    accent: Color(0xFFA7543D),
    error: Color(0xFF9C382E),
  );
  static const dark = AppPalette(
    primary: Color(0xFFD9987C),
    primaryLight: Color(0xFFE7B39B),
    background: Color(0xFF201D1A),
    backgroundLight: Color(0xFF29241F),
    surface: Color(0xFF302A25),
    textPrimary: Color(0xFFF4F0E7),
    textSecondary: Color(0xFFC4B9AE),
    textMuted: Color(0xFFA99D91),
    accent: Color(0xFFD9987C),
    error: Color(0xFFFFB4A5),
  );
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).brightness == Brightness.dark
      ? AppPalette.dark
      : AppPalette.light;
}
