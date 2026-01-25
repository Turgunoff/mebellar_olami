import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/localized_text_helper.dart';
import '../../data/models/category_model.dart';

class CategoryBigCard extends StatelessWidget {
  final CategoryModel category;
  final int index;
  final VoidCallback onTap;

  const CategoryBigCard({
    super.key,
    required this.category,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Juft indekslar (0, 2, 4...) uchun rasm O'NGDA
    // Toq indekslar (1, 3, 5...) uchun rasm CHAPDA
    final isImageRight = index % 2 == 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          // Har bir kartaga o'ziga xos pastel rang berish mumkin
          // Yoki barchasiga bir xil "Soft Beige" rang
          color: const Color(0xFFEBE5DE), // Mebelbop yumshoq rang
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
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
                        _buildTextSection(
                          context,
                          crossAlign: CrossAxisAlignment.start,
                        ),
                        _buildImageSection(isRight: true),
                      ]
                    : [
                        _buildImageSection(isRight: false),
                        _buildTextSection(
                          context,
                          crossAlign: CrossAxisAlignment.end,
                        ),
                      ],
              ),

              // Dekorativ element (ixtiyoriy)
              Positioned(
                bottom: -20,
                left: isImageRight ? -20 : null,
                right: isImageRight ? null : -20,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Matn Qismi
  Widget _buildTextSection(
    BuildContext context, {
    required CrossAxisAlignment crossAlign,
  }) {
    return Expanded(
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: crossAlign,
          children: [
            Text(
              LocalizedTextHelper.get(category.name, context),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A403A), // To'q jigarrang matn
                letterSpacing: -0.5,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: crossAlign == CrossAxisAlignment.end
                  ? TextAlign.right
                  : TextAlign.left,
            ),
            // const SizedBox(height: 8),
            // if (category.productCount > 0)
            //   Container(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 10,
            //       vertical: 4,
            //     ),
            //     decoration: BoxDecoration(
            //       color: Colors.white.withValues(alpha: 0.6),
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     child: Text(
            //       '${category.productCount} mahsulot',
            //       style: TextStyle(
            //         fontSize: 12,
            //         fontWeight: FontWeight.w600,
            //         color: const Color(0xFF4A403A).withValues(alpha: 0.7),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  // Rasm Qismi (Egri kesish bilan)
  Widget _buildImageSection({required bool isRight}) {
    return Expanded(
      flex: 5,
      child: ClipPath(
        clipper: isRight ? _CurveLeftClipper() : _CurveRightClipper(),
        child: CachedNetworkImage(
          imageUrl: category.iconUrl,
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(color: Colors.white),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Rasm Kesuvchilar (Custom Clippers) - Organik shakl uchun
// -----------------------------------------------------------------------------

// Rasm O'ngda turganda, chap tomoni egri bo'ladi
class _CurveLeftClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Tepadan boshlaymiz (biroz o'ngroqdan)
    path.moveTo(size.width * 0.3, 0);
    // Pastga qarab egri chiziq
    path.quadraticBezierTo(
      0,
      size.height / 2, // Control point (chapga bo'rtib chiqadi)
      size.width * 0.3,
      size.height, // End point
    );
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Rasm Chapda turganda, o'ng tomoni egri bo'ladi
class _CurveRightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.7, 0);
    // Pastga qarab egri chiziq (o'ngga bo'rtib chiqadi)
    path.quadraticBezierTo(
      size.width,
      size.height / 2, // Control point
      size.width * 0.7,
      size.height, // End point
    );
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
