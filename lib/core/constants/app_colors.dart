import 'package:flutter/material.dart';

/// Ilova ranglar paleti - Nabolen Style
/// Earthy, premium, cozy dizayn
class AppColors {
  AppColors._();

  /// Asosiy rang - Cappuccino/Dark Brown (Tugmalar, Sarlavhalar, Faol ikonlar)
  static const Color primary = Color(0xFF633E33);

  /// Ikkinchi rang - Soft Beige (Fon, yengil ta'kidlash)
  static const Color secondary = Color(0xFFD6CFC4);

  /// Asosiy fon - Off-white
  static const Color background = Color(0xFFF9F9F9);

  /// Karta foni - Oq
  static const Color surface = Colors.white;

  /// Asosiy matn rangi - Qora/To'q kulrang
  static const Color textPrimary = Color(0xFF1E1E20);

  /// Ikkinchi matn rangi - Kulrang
  static const Color textSecondary = Color(0xFF6B6B6B);

  /// Yengil kulrang (divider, border)
  static const Color lightGrey = Color(0xFFE8E8E8);

  /// Muvaffaqiyat rangi
  static const Color success = Color(0xFF4CAF50);

  /// Xatolik rangi
  static const Color error = Color(0xFFE53935);

  /// Oq rang
  static const Color white = Colors.white;

  /// Qora rang
  static const Color black = Colors.black;

  /// Accent gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF633E33), Color(0xFF8B5A4A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
