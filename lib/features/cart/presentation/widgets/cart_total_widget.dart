import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_button.dart';

/// Savatcha jami summa va checkout widgeti
class CartTotalWidget extends StatelessWidget {
  const CartTotalWidget({
    super.key,
    required this.totalPrice,
    required this.onCheckout,
  });

  final double totalPrice;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jami summa:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              Text(
                totalPrice.toCurrency(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(text: 'Buyurtma berish', onPressed: onCheckout),
        ],
      ),
    );
  }
}
