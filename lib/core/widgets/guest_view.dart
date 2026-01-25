import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../constants/app_colors.dart';
import 'custom_button.dart';

/// Reusable widget for displaying a login prompt to Guest users
/// Used in Cart and Profile screens when user is in Guest mode
class GuestPlaceholder extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onLoginTap;
  final IconData icon;

  const GuestPlaceholder({
    super.key,
    required this.title,
    required this.message,
    required this.onLoginTap,
    this.icon = Iconsax.user,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container with gradient background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 56,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 32),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Login button
            CustomButton(
              text: 'Tizimga kirish',
              onPressed: onLoginTap,
              width: double.infinity,
              icon: Iconsax.login_1,
            ),
          ],
        ),
      ),
    );
  }
}
