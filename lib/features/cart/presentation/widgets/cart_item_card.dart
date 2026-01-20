import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../bloc/cart_bloc.dart';

/// Savatcha elementi kartasi
class CartItemCard extends StatelessWidget {
  const CartItemCard({super.key, required this.cartItem});

  final Map<String, dynamic> cartItem;

  @override
  Widget build(BuildContext context) {
    final product = cartItem['product'] as Map<String, dynamic>;
    final quantity = cartItem['quantity'] as int? ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              child: Container(
                width: 80,
                height: 80,
                color: AppColors.secondary.withValues(alpha: 0.3),
                child: const Icon(
                  Icons.image,
                  color: AppColors.textSecondary,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name']?.toString() ?? 'Mahsulot',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getProductPrice(product).toCurrency(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            context.read<CartBloc>().add(
                              UpdateCartItemQuantity(
                                productId: product['id']?.toString() ?? '',
                                newQuantity: quantity - 1,
                              ),
                            );
                          } else {
                            context.read<CartBloc>().add(
                              RemoveFromCart(
                                productId: product['id']?.toString() ?? '',
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.remove,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: Text(
                          quantity.toString(),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          context.read<CartBloc>().add(
                            UpdateCartItemQuantity(
                              productId: product['id']?.toString() ?? '',
                              newQuantity: quantity + 1,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: () {
                    context.read<CartBloc>().add(
                      RemoveFromCart(
                        productId: product['id']?.toString() ?? '',
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  double _getProductPrice(Map<String, dynamic> product) {
    final hasDiscount = product['has_discount'] as bool? ?? false;
    if (hasDiscount && product['discount_price'] != null) {
      return (product['discount_price'] as num?)?.toDouble() ?? 0.0;
    }
    return (product['price'] as num?)?.toDouble() ?? 0.0;
  }
}
