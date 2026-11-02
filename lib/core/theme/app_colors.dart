import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.error,
  });

  final Color primary, primaryLight, background, surface;
  final Color textPrimary, textSecondary, textMuted, accent, error;

  @override
  AppPalette copyWith({
    Color? primary,
    Color? primaryLight,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? error,
  }) => AppPalette(
    primary: primary ?? this.primary,
    primaryLight: primaryLight ?? this.primaryLight,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textMuted: textMuted ?? this.textMuted,
    accent: accent ?? this.accent,
    error: error ?? this.error,
  );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }

  static const light = AppPalette(
    primary: Color(0xFFA7543D),
    primaryLight: Color(0xFFC8795E),
    background: Color(0xFFF4F0E7),
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
    surface: Color(0xFF302A25),
    textPrimary: Color(0xFFF4F0E7),
    textSecondary: Color(0xFFC4B9AE),
    textMuted: Color(0xFFA99D91),
    accent: Color(0xFFD9987C),
    error: Color(0xFFFFB4A5),
  );
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AppPalette.dark
          : AppPalette.light);
}
