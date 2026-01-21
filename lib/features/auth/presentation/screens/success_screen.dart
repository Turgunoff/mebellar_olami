import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../main/presentation/screens/main_screen.dart';
import 'login_screen.dart';

/// Muvaffaqiyat ekrani - Nabolen Style
class SuccessScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isPasswordReset;

  const SuccessScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.isPasswordReset = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Muvaffaqiyat ikoni
              Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 80,
                    ),
                  )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .then()
                  .shimmer(
                    duration: 1200.ms,
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
              const SizedBox(height: 40),
              // Sarlavha
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 14),
              // Izoh
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
              const Spacer(flex: 2),
              // Davom etish tugmasi
              CustomButton(
                text: 'auth.continue'.tr(),
                width: double.infinity,
                onPressed: () {
                  if (isPasswordReset) {
                    // Parol tiklash - Login sahifasiga o'tish
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const LoginScreen(isFromOnboarding: true),
                      ),
                      (route) => false,
                    );
                  } else {
                    // Ro'yxatdan o'tish - Asosiy sahifaga o'tish
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
