import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/product_model.dart';
import '../../../features/cart/bloc/cart_bloc.dart';
import '../../../features/products/data/repositories/product_repository.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/product_card.dart';

/// Savatcha ekran
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Savatcha',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state.status == CartStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state.status == CartStatus.loaded &&
              state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == CartStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            );
          }

          if (state.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              // Cart Items
              Expanded(flex: 3, child: _buildCartItems(context, state)),

              // Total and Checkout
              _buildCheckoutSection(context, state),

              // Cross-selling
              Expanded(flex: 1, child: _buildCrossSelling(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Savatchangiz bo\'sh',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Mahsulotlarni savatchaga qo\'shing',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Katalogga o\'tish',
            onPressed: () {
              // Navigate to catalog
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(BuildContext context, CartState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.cartItems.length,
      itemBuilder: (context, index) {
        final cartItem = state.cartItems[index];
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
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusSmall,
                  ),
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
      },
    );
  }

  Widget _buildCheckoutSection(BuildContext context, CartState state) {
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
                state.totalPrice.toCurrency(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Buyurtma berish',
            onPressed: () {
              // Handle checkout
              _showCheckoutDialog(context, state);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCrossSelling(BuildContext context, CartState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sizga yoqishi mumkin',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder(
            future: ProductRepository().getRecommendedProducts(
              limit: 10,
              excludeIds: state.cartItems
                  .map((item) => item['product_id']?.toString() ?? '')
                  .toList(),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (!snapshot.hasData || snapshot.data!['success'] != true) {
                return const SizedBox.shrink();
              }

              final products = List<Map<String, dynamic>>.from(
                snapshot.data!['products'] ?? [],
              );

              if (products.isEmpty) {
                return const SizedBox.shrink();
              }

              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: HorizontalProductCard(
                        product: ProductModel(
                          id: product['id']?.toString() ?? '',
                          name: product['name']?.toString() ?? '',
                          description: product['description']?.toString() ?? '',
                          price: (product['price'] as num?)?.toDouble() ?? 0.0,
                          images: [product['image_url']?.toString() ?? ''],
                          discountPrice: (product['discount_price'] as num?)
                              ?.toDouble(),
                        ),
                        onTap: () {
                          // Navigate to product details
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, CartState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buyurtma berish'),
        content: Text(
          'Jami summa: ${state.totalPrice.toCurrency()}\n\n'
          'Buyurtmani tasdiqlaysizmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear cart after successful order
              context.read<CartBloc>().add(const ClearCart());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Buyurtma muvaffaqiyatli berildi!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Tasdiqlash'),
          ),
        ],
      ),
    );
  }

  double _getProductPrice(Map<String, dynamic> product) {
    final hasDiscount = product['has_discount'] as bool? ?? false;
    if (hasDiscount && product['discount_price'] != null) {
      return (product['discount_price'] as num?)?.toDouble() ?? 0.0;
    }
    return (product['price'] as num?)?.toDouble() ?? 0.0;
  }
}
