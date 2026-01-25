import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/utils/localized_text_helper.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/route_names.dart';
import '../../../products/data/models/product_model.dart';
import '../bloc/favorites_bloc.dart';
import '../../../../core/widgets/product_card.dart';

/// Sevimlilar ekrani - Nabolen Style
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, favoritesState) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true, // Sarlavha markazda
            // 1. Sarlavha va Soni (Subtitle)
            title: Column(
              children: [
                const Text(
                  'Sevimlilar',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                // Agar ro'yxat bo'sh bo'lmasa, sonini ko'rsatamiz
                if (favoritesState.favorites.isNotEmpty)
                  Text(
                    '${favoritesState.favorites.length} ta mahsulot',
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),

            // 2. Tozalash tugmasi (Trash Icon)
            actions: [
              if (favoritesState.favorites.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    onPressed: () {
                      _showClearConfirmation(context);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.error.withOpacity(
                        0.1,
                      ), // Orqa fon (och qizil)
                      highlightColor: AppColors.error.withOpacity(0.2),
                    ),
                    icon: Icon(
                      Iconsax.trash, // Iconsax paketi
                      color: AppColors.error, // Qizil rang (xavfli amal)
                      size: 20,
                    ),
                    tooltip: 'Ro\'yxatni tozalash',
                  ),
                ),
            ],
          ),
          body: favoritesState.status == FavoritesStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : favoritesState.favorites.isEmpty
              ? _buildEmptyView()
              : _buildFavoritesList(context, favoritesState),
        );
      },
    );
  }

  /// Bo'sh ko'rinish (for both Guest and Authenticated users)
  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 56,
                color: AppColors.textSecondary,
              ),
            ).animate().scale(curve: Curves.elasticOut),
            const SizedBox(height: 28),
            const Text(
              'Sevimlilar bo\'sh',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            const Text(
              'Siz hali birorta mahsulotni\nsevimliga qo\'shmagansiz',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }

  /// Sevimlilar ro'yxati
  Widget _buildFavoritesList(
    BuildContext context,
    FavoritesState favoritesState,
  ) {
    final favorites = favoritesState.favorites
        .map((json) => ProductModel.fromJson(json))
        .toList();

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final product = favorites[index];
        return Dismissible(
          key: Key(product.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
          ),
          onDismissed: (direction) {
            // Use toJson() to ensure all product fields are included
            final productData = product.toJson();
            productData['image_url'] = product.imageUrl;
            productData['has_discount'] = product.hasDiscount;
            productData['discount_percent'] = product.discountPercent;
            
            context.read<FavoritesBloc>().add(
              ToggleFavoriteEvent(
                product: productData,
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${LocalizedTextHelper.get(product.name, context)} o\'chirildi',
                ),
              ),
            );
          },
          child: ProductCard(
            product: product,
            onTap: () {
              context.pushNamed(
                RouteNames.productDetail,
                pathParameters: {'productId': product.id},
              );
            },
          ).animate().fadeIn(delay: (50 * index).ms),
        );
      },
    );
  }

  /// Tozalash tasdiqlash dialogi
  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        title: const Text('Sevimlilarni tozalash'),
        content: const Text(
          'Barcha sevimli mahsulotlaringiz o\'chiriladi. Davom etasizmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FavoritesBloc>().add(const ClearFavorites());
              context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }
}
