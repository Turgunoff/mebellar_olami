import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../products/data/models/product_model.dart';

/// Buyurtma xulosasini ko'rsatuvchi widget
class OrderSummaryWidget extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final String? selectedColor;
  final VoidCallback? onOrderPressed;
  final bool isLoading;

  const OrderSummaryWidget({
    super.key,
    required this.product,
    required this.quantity,
    this.selectedColor,
    this.onOrderPressed,
    this.isLoading = false,
  });

  double get _totalPrice => product.price * quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Jami summa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jami to\'lov:',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _totalPrice.toCurrency(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${quantity} dona',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Tasdiqlash tugmasi
            CustomButton(
              text: 'Buyurtmani tasdiqlash',
              icon: Icons.check_circle_outline_rounded,
              width: double.infinity,
              height: 58,
              isLoading: isLoading,
              onPressed: onOrderPressed,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}
