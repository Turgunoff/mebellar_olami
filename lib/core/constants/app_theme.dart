import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const double borderRadius = 16.0;
  static const double borderRadiusSmall = 12.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        outline: AppColors.outline,
      ),

      // Typography - Roboto Font Family
      textTheme: TextTheme(
        // Header (24px, SemiBold) -> headlineSmall
        headlineSmall: GoogleFonts.roboto(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        // Sub Header (22px, Medium) -> titleLarge
        titleLarge: GoogleFonts.roboto(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
        // Title (20px, Medium) -> titleMedium
        titleMedium: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
        // Body (18px, Regular) -> bodyLarge
        bodyLarge: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: AppColors.black,
        ),
        // Body 2 (16px, Regular) -> bodyMedium
        bodyMedium: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.black,
        ),
        // Sub-Body (14px, Regular) -> bodySmall
        bodySmall: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.grey,
        ),
        // Sub-body 2 (13px, Regular) -> labelSmall
        labelSmall: GoogleFonts.roboto(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.grey,
        ),
        // Navbar (12px, Medium) -> labelMedium
        labelMedium: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.grey,
        ),
        // Button (16px, SemiBold) -> labelLarge
        labelLarge: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.black),
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        hintStyle: GoogleFonts.roboto(color: AppColors.grey, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),

      // ElevatedButton Theme - Primary (#633E33), Text White, Radius 12px
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // OutlinedButton Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: AppColors.outline),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // BottomNavigationBar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        selectedLabelStyle: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(AppColors.primary),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: AppColors.grey),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
      ),
    );
  }
}
