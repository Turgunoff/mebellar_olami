import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === Design System Colors ===

  // --- Primary (Cappuccino) ---
  /// Main Buttons, Active Icons, Selected States
  static const Color primary = Color(0xFF633E33);

  /// Darker variant for pressed states or gradients
  static const Color primaryDark = Color(0xFF4A2E26);

  // --- Secondary (Male/Beige) ---
  /// Card backgrounds, secondary elements
  static const Color secondary = Color(0xFFD6CFC4);

  // --- Accent (Tetsu Iron) ---
  /// Slate blue/grey accent color
  static const Color accent = Color(0xFF445667);

  // --- Black ---
  /// Main Text Color
  static const Color black = Color(0xFF1E1E20);
  static const Color textPrimary = Color(0xFF1E1E20);

  // --- White ---
  /// Scaffold Background, Cards (NOT pure white)
  static const Color white = Color(0xFFF9F9F9);
  static const Color background = Color(0xFFF9F9F9);
  static const Color surface = Color(0xFFF9F9F9);

  // --- Grey (Grey 500) ---
  /// Subtitles, unselected icons
  static const Color grey = Color(0xFF5F6063);
  static const Color textSecondary = Color(0xFF5F6063);

  // --- Additional Colors ---
  static const Color inputBackground = Color(0xFFF3F3F3);
  static const Color outline = Color(0xFFEEEEEE);
  static const Color lightGrey = Color(0xFFE0E0E0);

  // --- Status ---
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
