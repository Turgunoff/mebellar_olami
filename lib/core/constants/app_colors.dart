import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Asosiy Brand Rangi (Rasmdagi tugmalar rangi) ---
  /// Warm Chocolate - Issiq Shokolad rangi
  static const Color primary = Color(0xFF5D4037);

  /// Bosilganda yoki gradient uchun to'qroq varianti
  static const Color primaryDark = Color(0xFF4E342E);

  // --- Qo'shimcha Ranglar ---
  /// Secondary: Oltin/Sariq (Credit Card dagi chip yoki yulduzchalar uchun)
  static const Color accent = Color(0xFFD4A017);

  // --- Fon Ranglari (Rasmdagi toza fon) ---
  /// Asosiy fon - Deyarli Oq (Juda och issiq kulrang)
  static const Color background = Color(0xFFFAFAFA);

  /// Karta va BottomSheet foni - Toza Oq
  static const Color surface = Colors.white;

  /// Input maydonlari foni (Rasmdagi "Enter coupon code" foni)
  static const Color inputBackground = Color(0xFFF3F3F3);

  // --- Matn Ranglari ---
  /// Asosiy sarlavhalar (Qop-qora emas, to'q kulrang)
  static const Color textPrimary = Color(0xFF212121);

  /// Izohlar va yordamchi matnlar
  static const Color textSecondary = Color(0xFF757575);

  // --- Chiziqlar va Borderlar ---
  static const Color outline = Color(0xFFEEEEEE);

  // --- Status ---
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);

  // --- Missing Colors (Added to fix errors) ---
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color lightGrey = Color(0xFFE0E0E0); // Added lightGrey
  static const Color secondary = Color(0xFFD7CCC8); // Added secondary back as a soft beige/brown

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}