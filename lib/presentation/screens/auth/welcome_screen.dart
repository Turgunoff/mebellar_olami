import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../main_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

/// Welcome Screen - Auth Selection Screen
/// Splash dan keyin, agar foydalanuvchi tizimga kirmagan bo'lsa ko'rsatiladi
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/welcome_image.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF4A5043), Color(0xFF3D4A3A)],
                  ),
                ),
              );
            },
          ),
          // Dark Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  // Logo Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.chair_alt_rounded,
                      color: AppColors.white,
                      size: 40,
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 24),
                  // Title
                  const Text(
                    'Mebellar Olami',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  const SizedBox(height: 12),
                  // Subtitle
                  Text(
                    'Orzuingizdagi uyni yarating',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.85),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                  const Spacer(flex: 2),
                  // Buttons
                  // Login Button - Filled
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const LoginScreen(isFromOnboarding: true),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadius,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Kirish',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                  const SizedBox(height: 14),
                  // Sign Up Button - Outlined
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        side: const BorderSide(
                          color: AppColors.white,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadius,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Ro\'yxatdan o\'tish',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
                  const SizedBox(height: 24),
                  // Guest Mode - TextButton
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Mehmon sifatida davom etish',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
