import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../screens/auth/login_screen.dart';

/// Login dialog widgeti
/// Mehmon foydalanuvchi sevimli yoki sotib olish tugmasini bosganida ko'rinadi
class LoginDialog extends StatelessWidget {
  final String message;

  const LoginDialog({
    super.key,
    this.message = 'Davom etish uchun tizimga kiring',
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.accent,
                size: 40,
              ),
            ).animate().scale(
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 20),
            // Sarlavha
            const Text(
              'Kirish talab qilinadi',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            // Xabar
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),
            // Tugmalar
            Row(
              children: [
                // Bekor qilish
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Bekor qilish'),
                  ),
                ),
                const SizedBox(width: 12),
                // Kirish
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Kirish'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          ],
        ),
      ).animate().scale(
            duration: 300.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}
