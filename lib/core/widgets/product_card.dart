import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/localized_text_helper.dart';
import '../../features/products/data/models/product_model.dart';
import '../constants/app_colors.dart';
import '../utils/extensions.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';

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
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section (Flex: 6)
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.textSecondary,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  // "New" Badge (Top Left) - Green
                  if (product.isNew)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _buildNewBadge(),
                    ),
                  // Favorite Icon (Top Right) - No background, just icon
                  if (showFavoriteButton)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _FavoriteButton(product: product),
                    ),
                  // Color Swatches (Below Favorite Icon, Right)
                  Positioned(
                    top: 36,
                    right: 8,
                    child: _ColorSwatches(colors: product.colors),
                  ),
                ],
              ),
            ),
            // Details Section (Flex: 4)
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Rating Row
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // Title
                    Flexible(
                      child: Text(
                        LocalizedTextHelper.get(product.name, context),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Price Row with Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: _buildPriceSection(),
                        ),
                        const SizedBox(width: 8),
                        _AddButton(product: product),
                      ],
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

  Widget _buildNewBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(4),
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

  Widget _buildPriceSection() {
    // Show discount price if available, otherwise regular price
    final displayPrice = product.hasDiscount
        ? product.discountPrice!
        : product.price;

    return Text(
      displayPrice.toCurrency(),
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ColorSwatches extends StatelessWidget {
  final List<String> colors;

  const _ColorSwatches({required this.colors});

  @override
  Widget build(BuildContext context) {
    // If no colors available, show mock colors or hide
    final displayColors = colors.isNotEmpty
        ? colors.take(3).toList()
        : ['#9E9E9E', '#212121', '#E91E63']; // Mock: Grey, Black, Pink

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: displayColors.map((colorCode) {
        Color color;
        try {
          // Try to parse hex color
          color = Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
        } catch (e) {
          // Fallback to grey if parsing fails
          color = Colors.grey;
        }

        return Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.white,
              width: 1.5,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final ProductModel product;

  const _FavoriteButton({required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, favoritesState) {
        return BlocListener<FavoritesBloc, FavoritesState>(
          listener: (context, state) {
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
                behavior: HitTestBehavior.opaque,
                child: isUpdating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isFavorite
                            ? AppColors.error // Red when favorited
                            : AppColors.primary, // Brown when not favorited
                      ),
              );
            },
          ),
        );
      },
    );
  }
}

class _AddButton extends StatelessWidget {
  final ProductModel product;

  const _AddButton({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<CartBloc>().add(
              AddToCart(
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
                quantity: 1,
              ),
            );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.add,
          color: AppColors.white,
          size: 20,
        ),
      ),
    );
  }
}


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
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        LocalizedTextHelper.get(product.name, context),
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
