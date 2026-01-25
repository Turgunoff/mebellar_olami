import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/localized_text_helper.dart';
import '../../data/models/category_model.dart';

class CategoryListCard extends StatelessWidget {
  final CategoryModel category;
  final int index;
  final VoidCallback onTap;

  const CategoryListCard({
    super.key,
    required this.category,
    required this.index,
    required this.onTap,
  });

  bool get isImageRight => index % 2 == 0;

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
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Row(
                children: isImageRight
                    ? [
                        _buildTextSection(context, CrossAxisAlignment.start),
                        _buildImageSection(isRight: true, imageUrl: imageUrl),
                      ]
                    : [
                        _buildImageSection(isRight: false, imageUrl: imageUrl),
                        _buildTextSection(context, CrossAxisAlignment.end),
                      ],
              ),
              // Decorative circle
              Positioned(
                bottom: -30,
                left: isImageRight ? -30 : null,
                right: isImageRight ? null : -30,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextSection(
    BuildContext context,
    CrossAxisAlignment crossAlign,
  ) {
    return Expanded(
      flex: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: crossAlign,
          children: [
            Text(
              LocalizedTextHelper.get(category.name, context),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A403A),
                letterSpacing: -0.5,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: crossAlign == CrossAxisAlignment.end
                  ? TextAlign.right
                  : TextAlign.left,
            ),
            const SizedBox(height: 8),
            if (category.productCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${category.productCount} ta',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A403A).withValues(alpha: 0.8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection({required bool isRight, required String imageUrl}) {
    return Expanded(
      flex: 5,
      child: ClipPath(
        clipper: isRight ? _CurveLeftClipper() : _CurveRightClipper(),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          height: double.infinity,
          width: double.infinity,
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
      ),
    );
  }
}

class _CurveLeftClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.25, 0);
    path.quadraticBezierTo(0, size.height / 2, size.width * 0.25, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _CurveRightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.75, 0);
    path.quadraticBezierTo(
      size.width,
      size.height / 2,
      size.width * 0.75,
      size.height,
    );
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
