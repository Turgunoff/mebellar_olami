import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/localized_text_helper.dart';
import '../../data/models/category_model.dart';

/// Zamonaviy kategoriya grid karta (Zara Home / Pinterest style)
class CategoryGridCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;

  const CategoryGridCard({super.key, required this.category, this.onTap});

  /// Kategoriya nomidan slug yaratish (Unsplash image mapping uchun)
  String _getCategorySlug(BuildContext context) {
    final name = LocalizedTextHelper.get(category.name, context).toLowerCase();
    // Kichik harflarga o'tkazish va maxsus belgilarni olib tashlash
    return name
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  /// Unsplash image URL ni kategoriya slug asosida olish
  String _getCategoryImageUrl(BuildContext context) {
    final slug = _getCategorySlug(context);

    // Kategoriya nomlariga asoslangan Unsplash image mapping
    final imageMap = {
      // Furniture categories
      'wardrobe':
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&q=80',
      'шкафы':
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&q=80',
      'wardrobes':
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&q=80',

      'upholstered':
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800&q=80',
      'мягкая-мебель':
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800&q=80',
      'soft-furniture':
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800&q=80',
      'sofa':
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800&q=80',

      'office':
          'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=800&q=80',
      'офисная-мебель':
          'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=800&q=80',
      'office-furniture':
          'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=800&q=80',
      'desk':
          'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=800&q=80',

      'children':
          'https://images.unsplash.com/photo-1616594039964-40891a909d72?w=800&q=80',
      'детская-мебель':
          'https://images.unsplash.com/photo-1616594039964-40891a909d72?w=800&q=80',
      'children-furniture':
          'https://images.unsplash.com/photo-1616594039964-40891a909d72?w=800&q=80',
      'kids':
          'https://images.unsplash.com/photo-1616594039964-40891a909d72?w=800&q=80',

      'bedroom':
          'https://images.unsplash.com/photo-1631889993954-0f77a0f1b3b1?w=800&q=80',
      'bed':
          'https://images.unsplash.com/photo-1631889993954-0f77a0f1b3b1?w=800&q=80',

      'kitchen':
          'https://images.unsplash.com/photo-1556912172-45b7abe8b7e8?w=800&q=80',
      'кухня':
          'https://images.unsplash.com/photo-1556912172-45b7abe8b7e8?w=800&q=80',

      'living-room':
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&q=80',
      'гостиная':
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&q=80',

      'dining':
          'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=800&q=80',
      'столовая':
          'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=800&q=80',
    };

    // Slug yoki nom bo'yicha qidirish (case-insensitive)
    final searchText =
        '$slug ${LocalizedTextHelper.get(category.name, context).toLowerCase()}';
    for (final key in imageMap.keys) {
      if (searchText.contains(key.toLowerCase()) ||
          key.toLowerCase().contains(slug)) {
        return imageMap[key]!;
      }
    }

    // Default image - beautiful modern furniture
    return 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&q=80';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getCategoryImageUrl(context);
    final categoryName = LocalizedTextHelper.get(category.name, context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Layer 1: Background Image
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: AppColors.secondary.withValues(alpha: 0.3),
                  highlightColor: AppColors.secondary.withValues(alpha: 0.1),
                  child: Container(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.2),
                        AppColors.primary.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.category_outlined,
                    size: 48,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
              // Layer 2: Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.0, 0.4, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              // Layer 3: Text Content
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (category.productCount > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${category.productCount} ta mahsulot',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
