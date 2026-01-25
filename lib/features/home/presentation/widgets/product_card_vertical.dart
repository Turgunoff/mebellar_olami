import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/localized_text_helper.dart';
import '../../../../core/utils/extensions.dart';
import '../../../products/data/models/product_model.dart';

class ProductCardVertical extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart; // Qo'shildi
  final bool showFavoriteButton;

  const ProductCardVertical({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart, // Qo'shildi
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          // Chegara (border) shart emas, soya yetarli
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize:
              MainAxisSize.min, // Muhim: O'z ichidagi narsachalik joy oladi
          children: [
            // 1. Rasm Qismi
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    // Staggered effekt uchun rasm o'lchami har xil bo'lishi kerak.
                    // Lekin hozircha chiroyli ko'rinishi uchun fixed height bermaymiz.
                    // Placeholder kvadrat bo'lib turadi.
                    placeholder: (context, url) => AspectRatio(
                      aspectRatio: 1, // Kvadrat
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      ),
                    ),
                    errorWidget: (_, __, ___) => const SizedBox(
                      height: 150,
                      child: Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                // Badge
                if (product.hasDiscount || product.isNew)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: product.hasDiscount
                            ? AppColors.error
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.hasDiscount
                            ? '-${product.discountPercent}%'
                            : 'Yangi',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Favorite
                if (showFavoriteButton)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),

            // 2. Ma'lumot Qismi
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nomi
                  Text(
                    LocalizedTextHelper.get(product.name, context),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Reyting
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "(12)", // review count
                        style: TextStyle(color: Colors.grey[500], fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Narx va Tugma
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.hasDiscount)
                            Text(
                              product.price.toCurrency(),
                              style: TextStyle(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            product.actualPrice.toCurrency(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      // Kichik "Add" tugmasi
                      InkWell(
                        onTap: onAddToCart,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
