import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../../data/models/product_model.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/favorites/bloc/favorites_bloc.dart';

/// Mahsulot kartasi widgeti - Nabolen Style (Discount support)
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final bool showFavoriteButton;
  final bool isCompact;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showFavoriteButton = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rasm
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Rasm
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppTheme.borderRadius),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  // Badge (Yangi yoki Chegirma)
                  Positioned(top: 10, left: 10, child: _buildBadge()),

                  // Sevimli tugmasi
                  if (showFavoriteButton)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _FavoriteButton(product: product),
                    ),
                ],
              ),
            ),

            // Ma'lumotlar
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nomi
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Narxlar
                    _buildPriceSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Badge (Yangi yoki Chegirma)
  Widget _buildBadge() {
    // Chegirma bo'lsa - chegirma foizini ko'rsatish
    if (product.hasDiscount) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '-${product.discountPercent}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // Yangi mahsulot
    if (product.isNew) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Yangi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Narxlar (chegirmali va oddiy)
  Widget _buildPriceSection() {
    if (product.hasDiscount) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eski narx (o'chirilgan)
          Text(
            product.price.toCurrency(),
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 2),
          // Yangi narx
          Text(
            product.discountPrice!.toCurrency(),
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    // Oddiy narx
    return Text(
      product.price.toCurrency(),
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Sevimli tugmasi
class _FavoriteButton extends StatelessWidget {
  final ProductModel product;

  const _FavoriteButton({required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, favoritesState) {
        return BlocListener<FavoritesBloc, FavoritesState>(
          listener: (context, state) {
            // Show error message if needed
            if (state.status == FavoritesStatus.error &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final isFavorite = context.read<FavoritesBloc>().isFavorite(
                product.id.toString(),
              );
              final isUpdating = favoritesState.isUpdating;

              return GestureDetector(
                onTap: () {
                  // Guest Mode - Works without login
                  // User Mode - Also works, will sync to server
                  context.read<FavoritesBloc>().add(
                    ToggleFavoriteEvent(
                      product: {
                        'id': product.id,
                        'name': product.name,
                        'price': product.price,
                        'image_url': product.imageUrl,
                        'has_discount': product.hasDiscount,
                        'discount_price': product.discountPrice,
                        'discount_percent': product.discountPercent,
                        'is_new': product.isNew,
                      },
                      showSuccessMessage: true,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isUpdating
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border_rounded,
                          size: 20,
                          color: isFavorite
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Gorizontal mahsulot kartasi (Yangi kelganlar uchun)
class HorizontalProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final double width;

  const HorizontalProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.width = 160,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rasm
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),

                  // Badge
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else if (product.isNew)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Yangi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Ma'lumotlar
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nomi
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Narx
                    if (product.hasDiscount) ...[
                      Text(
                        product.price.toCurrency(),
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                          fontSize: 10,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        product.discountPrice!.toCurrency(),
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else
                      Text(
                        product.price.toCurrency(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
