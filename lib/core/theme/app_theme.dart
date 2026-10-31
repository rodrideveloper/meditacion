import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final palette = brightness == Brightness.dark
        ? AppPalette.dark
        : AppPalette.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: brightness,
      surface: palette.background,
      error: palette.error,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: palette.textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: palette.textPrimary,
          fontSize: 72,
          fontWeight: FontWeight.w300,
          letterSpacing: -1.5,
        ),
        displayMedium: TextStyle(
          color: palette.textPrimary,
          fontSize: 48,
          fontWeight: FontWeight.w300,
        ),
        headlineLarge: TextStyle(
          color: palette.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w500,
          fontFamily: 'serif',
        ),
        headlineMedium: TextStyle(
          color: palette.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w500,
          fontFamily: 'serif',
        ),
        titleLarge: TextStyle(
          color: palette.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: palette.textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: palette.textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: palette.textMuted, fontSize: 12),
        labelLarge: TextStyle(
          color: palette.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      iconTheme: IconThemeData(color: palette.textPrimary, size: 24),
      sliderTheme: SliderThemeData(
        activeTrackColor: palette.primary,
        inactiveTrackColor: palette.primary.withValues(alpha: .3),
        thumbColor: palette.primaryLight,
        overlayColor: palette.primary.withValues(alpha: .2),
        trackHeight: 4,
      ),
    );
  }
}
