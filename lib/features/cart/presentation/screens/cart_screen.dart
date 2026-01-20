import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../products/data/models/product_model.dart';
import '../bloc/cart_bloc.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_total_widget.dart';
import '../widgets/empty_cart_widget.dart';
import '../../../../core/widgets/product_card.dart';

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
    return const EmptyCartWidget();
  }

  Widget _buildCartItems(BuildContext context, CartState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.cartItems.length,
      itemBuilder: (context, index) {
        final cartItem = state.cartItems[index];

        return CartItemCard(cartItem: cartItem);
      },
    );
  }

  Widget _buildCheckoutSection(BuildContext context, CartState state) {
    return CartTotalWidget(
      totalPrice: state.totalPrice,
      onCheckout: () => _showCheckoutDialog(context, state),
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
}
