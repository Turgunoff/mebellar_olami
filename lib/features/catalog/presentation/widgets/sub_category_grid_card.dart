import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/localized_text_helper.dart';
import '../../data/models/category_model.dart';

class SubCategoryGridCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const SubCategoryGridCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  String _getCategorySlug(String categoryName) {
    final slugMap = {
      'divanlar': 'sofas',
      'sofas': 'sofas',
      'диваны': 'sofas',
      'yotoq': 'beds',
      'beds': 'beds',
      'кровати': 'beds',
      'shkaflar': 'wardrobes',
      'wardrobes': 'wardrobes',
      'шкафы': 'wardrobes',
      'stollar': 'tables',
      'tables': 'tables',
      'столы': 'tables',
      'stullar': 'chairs',
      'chairs': 'chairs',
      'стулья': 'chairs',
      'yotoqxona': 'bedroom',
      'bedroom': 'bedroom',
      'спальня': 'bedroom',
      'oshxona': 'kitchen',
      'kitchen': 'kitchen',
      'кухня': 'kitchen',
      'ofis': 'office',
      'office': 'office',
      'офис': 'office',
    };

    final lowerName = categoryName.toLowerCase();
    for (final entry in slugMap.entries) {
      if (lowerName.contains(entry.key)) {
        return entry.value;
      }
    }
    return 'furniture';
  }

  String _getFallbackImageUrl(BuildContext context) {
    final name = LocalizedTextHelper.get(category.name, context);
    final slug = _getCategorySlug(name);

    final unsplashMap = {
      'sofas':
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400',
      'beds':
          'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=400',
      'wardrobes':
          'https://images.unsplash.com/photo-1558997519-83ea9252edf8?w=400',
      'tables':
          'https://images.unsplash.com/photo-1611269154421-4e27233ac5c7?w=400',
      'chairs':
          'https://images.unsplash.com/photo-1503602642458-232111445657?w=400',
      'bedroom':
          'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=400',
      'kitchen':
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400',
      'office':
          'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=400',
      'furniture':
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
    };

    return unsplashMap[slug] ?? unsplashMap['furniture']!;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = category.iconUrl.isNotEmpty
        ? category.fullIconUrl
        : _getFallbackImageUrl(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.secondary,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              ),
              // Gradient Overlay (from transparent to semi-transparent Black/Cappuccino)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.5), // 50% opacity as requested
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
              // Category Name - Centered, White, Bold, Medium Size
              Center(
                child: Text(
                  LocalizedTextHelper.get(category.name, context),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18, // Medium size
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
