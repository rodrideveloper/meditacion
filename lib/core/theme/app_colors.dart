import 'package:flutter/material.dart';

/// Colores de la aplicación
class AppColors {
  AppColors._();

  // Colores primarios
  static const Color primary = Color(0xFF6B5B95);
  static const Color primaryDark = Color(0xFF4A3F6B);
  static const Color primaryLight = Color(0xFF9B8BC2);

  // Colores de fondo
  static const Color background = Color(0xFF1A1A2E);
  static const Color backgroundLight = Color(0xFF16213E);
  static const Color surface = Color(0xFF0F3460);

  // Colores de texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8D1);
  static const Color textMuted = Color(0xFF6B6B8D);

  // Colores de acento
  static const Color accent = Color(0xFFE94560);
  static const Color accentSoft = Color(0xFFFF6B6B);

  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE94560);

  // Gradientes
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
