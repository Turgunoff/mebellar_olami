import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/localized_text_helper.dart';
import '../../../../core/utils/extensions.dart';
import '../../../products/data/models/product_model.dart';

class ProductCardHorizontal extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onAddToCart;
  final double width;
  final double height;

  const ProductCardHorizontal({
    super.key,
    required this.product,
    this.onTap,
    this.onFavoriteTap,
    this.onAddToCart,
    this.width = 340,
    this.height = 160,
  });

  @override
  State<ProductCardHorizontal> createState() => _ProductCardHorizontalState();
}

class _ProductCardHorizontalState extends State<ProductCardHorizontal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  String _getCategoryName(BuildContext context) {
    if (widget.product.category == null) {
      return "Living Room Furniture";
    }

    if (widget.product.category is String) {
      return widget.product.category as String;
    }

    if (widget.product.category is Map) {
      final categoryMap = widget.product.category as Map<String, dynamic>;
      return LocalizedTextHelper.get(categoryMap, context);
    }

    return "Living Room Furniture";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          margin: const EdgeInsets.only(right: 16, bottom: 8, top: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.lightGrey.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                // 1. Rasm qismi - Gradient overlay bilan
                _buildImageSection(),

                // 2. Ma'lumot qismi
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: _buildInfoSection(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      width: 145,
      child: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.secondary.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),

          // Asosiy rasm
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: widget.product.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(color: Colors.white),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[50],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey[400],
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rasm yo\'q',
                      style: TextStyle(color: Colors.grey[400], fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Gradient overlay (rasm ustida)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.03),
                  ],
                ),
              ),
            ),
          ),

          // Chegirma badge
          if (widget.product.hasDiscount)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.error,
                      AppColors.error.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '-${widget.product.discountPercent}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // "Yangi" badge (agar yangi mahsulot bo'lsa)
          if (widget.product.isNew)
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.new_releases_rounded,
                      color: AppColors.primary,
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Yangi',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Sevimlilar tugmasi
          Positioned(top: 6, right: 6, child: _buildFavoriteButton()),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onFavoriteTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Kategoriya va Nomi (Tepa qism)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getCategoryName(context),
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              LocalizedTextHelper.get(widget.product.name, context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15, // Nomi biroz ixchamroq
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.2,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),

        const Spacer(), // O'rtadagi bo'sh joyni egallaydi
        // 2. NARX (Markaziy Figura)
        _buildPriceCentered(),

        const Spacer(), // Pastga itaradi
        // 3. Pastki qator (Reyting + Ko'rishlar --- Savat)
        _buildBottomActionRow(),
      ],
    );
  }

  Widget _buildPriceCentered() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Asosiy Narx
        Text(
          widget.product.actualPrice.toCurrency(),
          style: const TextStyle(
            fontSize: 18, // KATTA va QALIN
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        // Eski narx va Chegirma foizi (Narxning tagida)
        if (widget.product.hasDiscount)
          Row(
            children: [
              Text(
                widget.product.price.toCurrency(),
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  fontSize: 11,
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '-${widget.product.discountPercent}%',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildBottomActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Chap taraf: Reyting va Ko'rishlar
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Yulduzcha
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  widget.product.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                // Nuqta ajratgich
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: CircleAvatar(
                    radius: 1.5,
                    backgroundColor: AppColors.textSecondary.withValues(
                      alpha: 0.4,
                    ),
                  ),
                ),
                // Ko'rishlar soni (Review count)
                Text(
                  "120", // Yoki widget.product.reviewCount
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons
                      .visibility_outlined, // Yoki 'sharh' deb yozsa ham bo'ladi
                  size: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ],
            ),
          ],
        ),

        // O'ng taraf: Savat Tugmasi
        _buildAddToCartButton(),
      ],
    );
  }

  Widget _buildCategoryRating() {
    return Row(
      children: [
        // Kategoriya
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _getCategoryName(context),
              style: TextStyle(
                color: AppColors.primary.withValues(alpha: 0.9),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Reyting
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 13),
              const SizedBox(width: 3),
              Text(
                widget.product.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end, // Pastki qismdan tekislash
      children: [
        // Narxlar (Chap taraf - Kengaytirilgan)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Eski narx (Agar chegirma bo'lsa)
              if (widget.product.hasDiscount)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2), // Biroz joy
                  child: Text(
                    widget.product.price.toCurrency(),
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      fontSize: 11,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.textSecondary.withOpacity(0.5),
                      fontWeight: FontWeight.w500, // Qalinroq
                    ),
                  ),
                ),

              // Asosiy Narx
              FittedBox(
                // ⚠️ MUHIM: Agar narx juda uzun bo'lsa, kichraytiradi
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      widget.product.actualPrice.toCurrency(),
                      style: const TextStyle(
                        fontSize: 16, // 17 dan 16 ga tushirdik (ixchamroq)
                        fontWeight: FontWeight.w800, // Juda qalin
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),

                    // "Tejash" belgisi (Narxni yonida)
                    if (widget.product.hasDiscount) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${widget.product.discountPercent}%', // "tejash" o'rniga aniq foiz
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8), // Tugma va narx orasidagi masofa
        // Savatcha tugmasi (O'ng taraf - Ixcham)
        _buildAddToCartButton(),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return Material(
      color: Colors.transparent, // Orqa fon shaffof
      child: InkWell(
        onTap: widget.onAddToCart,
        borderRadius: BorderRadius.circular(10), // Kvadratroq shakl
        child: Container(
          width: 36, // 38 dan 36 ga
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.textPrimary, // Qora fon
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            // Ikonkani markazlash
            child: Icon(
              Icons.add_shopping_cart_rounded,
              color: Colors.white,
              size: 18, // Ikonka o'lchami
            ),
          ),
        ),
      ),
    );
  }
}
