import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/login_dialog.dart';
import '../checkout/checkout_screen.dart';

/// Mahsulot tafsilotlari ekrani
class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedColor;

  @override
  void initState() {
    super.initState();
    // Birinchi rangni tanlash
    if (widget.product.colors.isNotEmpty) {
      _selectedColor = widget.product.colors.first;
    }
  }

  void _handleBuyNow() {
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isGuest) {
      // Mehmon - Login dialog ko'rsatish
      showDialog(
        context: context,
        builder: (context) => const LoginDialog(
          message: 'Sotib olish uchun tizimga kiring',
        ),
      );
    } else {
      // Foydalanuvchi - Checkout ekraniga o'tish
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            product: widget.product,
            selectedColor: _selectedColor,
          ),
        ),
      );
    }
  }

  void _handleFavorite() {
    final authProvider = context.read<AuthProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();

    if (authProvider.isGuest) {
      showDialog(
        context: context,
        builder: (context) => const LoginDialog(
          message: 'Sevimli mahsulotlarni saqlash uchun tizimga kiring',
        ),
      );
    } else {
      favoritesProvider.toggleFavorite(widget.product);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorite = favoritesProvider.isFavorite(widget.product.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // SliverAppBar - Parallax effekti
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: AppColors.cardColor,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: AppColors.white,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: AppColors.white,
                  child: IconButton(
                    onPressed: _handleFavorite,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isFavorite ? AppColors.accent : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_${widget.product.id}',
                child: CachedNetworkImage(
                  imageUrl: widget.product.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.lightGrey,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.lightGrey,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Tarkib
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategoriya va reyting
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.product.category,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 20,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 16),
                    // Nomi
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.1),
                    const SizedBox(height: 12),
                    // Narx
                    Text(
                      widget.product.price.toCurrency(),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                    const SizedBox(height: 24),
                    // Ranglar
                    if (widget.product.colors.isNotEmpty) ...[
                      const Text(
                        'Rangni tanlang',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildColorSelector().animate().fadeIn(delay: 250.ms),
                      const SizedBox(height: 24),
                    ],
                    // Tavsif
                    const Text(
                      'Tavsif',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.product.description,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 24),
                    // Xususiyatlar
                    _buildFeatures().animate().fadeIn(delay: 350.ms),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Pastki qism - Sotib olish
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Sevimli tugmasi
              Container(
                width: 56,
                height: 56,
                margin: const EdgeInsets.only(right: 12),
                child: OutlinedButton(
                  onPressed: _handleFavorite,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: AppColors.lightGrey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.accent : AppColors.primary,
                  ),
                ),
              ),
              // Sotib olish tugmasi
              Expanded(
                child: CustomButton(
                  text: 'Sotib olish',
                  icon: Icons.shopping_bag_outlined,
                  height: 56,
                  borderRadius: 16,
                  onPressed: _handleBuyNow,
                ),
              ),
            ],
          ),
        ),
      ).animate().slideY(begin: 1, duration: 400.ms, curve: Curves.easeOut),
    );
  }

  /// Rang tanlash
  Widget _buildColorSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: widget.product.colors.map((colorHex) {
        final color = colorHex.toColor();
        final isSelected = _selectedColor == colorHex;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = colorHex;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.accent : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: _getContrastColor(color),
                    size: 20,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  /// Kontrast rang (oq yoki qora)
  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? AppColors.primary : AppColors.white;
  }

  /// Xususiyatlar
  Widget _buildFeatures() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildFeatureItem(
            icon: Icons.local_shipping_outlined,
            title: 'Bepul yetkazib berish',
            subtitle: 'Toshkent bo\'ylab',
          ),
          const Divider(height: 24),
          _buildFeatureItem(
            icon: Icons.verified_outlined,
            title: 'Kafolat',
            subtitle: '2 yil ishlab chiqaruvchi kafolati',
          ),
          const Divider(height: 24),
          _buildFeatureItem(
            icon: Icons.refresh_rounded,
            title: 'Qaytarish',
            subtitle: '14 kun ichida qaytarish mumkin',
          ),
        ],
      ),
    );
  }

  /// Xususiyat elementi
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
