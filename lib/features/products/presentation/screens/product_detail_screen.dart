import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/localized_text_helper.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/route_names.dart';
import '../bloc/product_detail_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/login_dialog.dart';
import '../../data/models/product_model.dart';

/// Mahsulot tafsilotlari ekrani - Nabolen Style
/// Rang va miqdor tanlash bilan
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedVariantIndex = 0;
  int _currentImageIndex = 0;
  int _quantity = 1;
  late PageController _imagePageController;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
    // Load product details when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductDetailBloc>().add(
        LoadProductDetails(widget.productId),
      );
    });
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  /// Tanlangan variant
  Map<String, dynamic>? get _selectedVariant {
    final state = context.read<ProductDetailBloc>().state;
    if (state is ProductDetailLoaded) {
      if (state.product.variants.isEmpty) return null;
      return state.product.variants[_selectedVariantIndex];
    }
    return null;
  }

  /// Tanlangan rangning stoklari
  int get _selectedStock {
    return (_selectedVariant?['stock'] as int?) ?? 0;
  }

  /// Aktual narx (chegirmali yoki oddiy)
  double get _actualPrice {
    final state = context.read<ProductDetailBloc>().state;
    if (state is ProductDetailLoaded) {
      return state.product.actualPrice;
    }
    return 0.0;
  }

  /// Jami narx
  double get _totalPrice => _actualPrice * _quantity;

  void _handleBuyNow() {
    final state = context.read<ProductDetailBloc>().state;
    if (state is! ProductDetailLoaded) return;

    final isGuest = context.read<AuthBloc>().state is! AuthAuthenticated;

    if (isGuest) {
      showDialog(
        context: context,
        builder: (context) =>
            const LoginDialog(message: 'Sotib olish uchun tizimga kiring'),
      );
    } else {
      context.pushNamed(
        RouteNames.checkout,
        extra: {
          'product': state.product,
          'selectedColor': _selectedVariant?['colorCode'] as String?,
          'quantity': _quantity,
        },
      );
    }
  }

  void _handleFavorite() {
    final state = context.read<ProductDetailBloc>().state;
    if (state is! ProductDetailLoaded) return;

    final isGuest = context.read<AuthBloc>().state is! AuthAuthenticated;

    if (isGuest) {
      showDialog(
        context: context,
        builder: (context) => const LoginDialog(
          message: 'Sevimli mahsulotlarni saqlash uchun tizimga kiring',
        ),
      );
    } else {
      // TODO: Implement FavoritesBloc integration
      // context.read<FavoritesBloc>().add(ToggleFavorite(state.product));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailBloc, ProductDetailState>(
      builder: (context, state) {
        if (state is ProductDetailLoading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is ProductDetailError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Xatolik',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Qayta urinish',
                    onPressed: () {
                      context.read<ProductDetailBloc>().add(
                        LoadProductDetails(widget.productId),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }

        if (state is ProductDetailLoaded) {
          return _buildContent(state.product);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(ProductModel product) {
    final hasImages = product.images.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // SliverAppBar - Rasm galereyasi
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _handleFavorite,
                    icon: Icon(
                      Icons.favorite_border_rounded,
                      size: 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Rasm galereyasi
                  if (hasImages)
                    Hero(
                      tag: 'product_${product.id}',
                      child: PageView.builder(
                        controller: _imagePageController,
                        itemCount: product.images.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: product.imageUrls[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.secondary.withValues(alpha: 0.3),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.secondary.withValues(alpha: 0.3),
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                size: 48,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                  // Badjelar (Yangi, Popular)
                  Positioned(
                    top: 100,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.isNew)
                          _buildBadge('YANGI', AppColors.success),
                        if (product.isPopular) ...[
                          const SizedBox(height: 8),
                          _buildBadge('OMMABOP', Colors.orange),
                        ],
                        if (product.hasDiscount) ...[
                          const SizedBox(height: 8),
                          _buildBadge(
                            '-${product.discountPercent}%',
                            AppColors.error,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Rasm indikatorlari
                  if (product.images.length > 1)
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          product.images.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentImageIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? AppColors.primary
                                  : AppColors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.textPrimary.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Tarkib
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              transform: Matrix4.translationValues(0, -24, 0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategoriya va reyting
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (product.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              LocalizedTextHelper.get(
                                product.category,
                                context,
                              ),
                              style: const TextStyle(
                                color: AppColors.primary,
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
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 18),
                    // Nomi
                    Text(
                      LocalizedTextHelper.get(product.name, context),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.1),
                    const SizedBox(height: 14),
                    // Narx qismi
                    _buildPriceSection(
                      product,
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                    const SizedBox(height: 28),
                    // Variant (rang) tanlash
                    if (product.variants.isNotEmpty) ...[
                      const Text(
                        'Rang',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildVariantSelector(
                        product,
                      ).animate().fadeIn(delay: 250.ms),
                      const SizedBox(height: 28),
                    ],
                    // Miqdor tanlash
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Miqdor',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_selectedStock > 0)
                          Text(
                            'Mavjud: $_selectedStock dona',
                            style: TextStyle(
                              color: _selectedStock <= 5
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildQuantitySelector().animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 28),
                    // Tavsif
                    const Text(
                      'Tavsif',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      LocalizedTextHelper.get(product.description, context),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ).animate().fadeIn(delay: 350.ms),
                    const SizedBox(height: 28),
                    // Spetsifikatsiyalar
                    if (product.specs.isNotEmpty) ...[
                      _buildSpecsSection(
                        product,
                      ).animate().fadeIn(delay: 380.ms),
                      const SizedBox(height: 28),
                    ],
                    // Xususiyatlar
                    _buildFeatures().animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 120),
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
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Jami narx
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jami:',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _totalPrice.toCurrency(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Sotib olish tugmasi
              Expanded(
                child: CustomButton(
                  text: _selectedStock > 0 ? 'Hozir sotib olish' : 'Tugagan',
                  height: 58,
                  borderRadius: AppTheme.borderRadius,
                  onPressed: _selectedStock > 0 ? _handleBuyNow : null,
                ),
              ),
            ],
          ),
        ),
      ).animate().slideY(begin: 1, duration: 400.ms, curve: Curves.easeOut),
    );
  }

  /// Badge yaratish
  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Narx bo'limi
  Widget _buildPriceSection(ProductModel product) {
    if (product.hasDiscount) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            product.discountPrice!.toCurrency(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            product.price.toCurrency(),
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      );
    }

    return Text(
      product.price.toCurrency(),
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Variant (rang) tanlash
  Widget _buildVariantSelector(ProductModel product) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: product.variants.asMap().entries.map((entry) {
        final index = entry.key;
        final variant = entry.value;
        final colorHex = variant['colorCode'] as String? ?? 'CCCCCC';
        final colorName = variant['color'] as String? ?? '';
        final stock = variant['stock'] as int? ?? 0;
        final color = colorHex.toColor();
        final isSelected = _selectedVariantIndex == index;
        final isOutOfStock = stock <= 0;

        return GestureDetector(
          onTap: isOutOfStock
              ? null
              : () {
                  setState(() {
                    _selectedVariantIndex = index;
                    // Reset quantity if exceeds stock
                    if (_quantity > stock) {
                      _quantity = stock > 0 ? stock : 1;
                    }
                  });
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : isOutOfStock
                    ? AppColors.lightGrey
                    : AppColors.lightGrey,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Opacity(
              opacity: isOutOfStock ? 0.5 : 1.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rang doirasi
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.lightGrey, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: _getContrastColor(color),
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  // Rang nomi va stok
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        colorName,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      Text(
                        isOutOfStock ? 'Tugagan' : '$stock dona',
                        style: TextStyle(
                          color: isOutOfStock
                              ? AppColors.error
                              : AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Miqdor tanlash
  Widget _buildQuantitySelector() {
    final maxQuantity = _selectedStock > 0 ? _selectedStock : 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: Icons.remove_rounded,
            onTap: () {
              if (_quantity > 1) {
                setState(() => _quantity--);
              }
            },
            enabled: _quantity > 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '$_quantity',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add_rounded,
            onTap: () {
              if (_quantity < maxQuantity) {
                setState(() => _quantity++);
              }
            },
            enabled: _quantity < maxQuantity,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.white : AppColors.textSecondary,
          size: 22,
        ),
      ),
    );
  }

  /// Kontrast rang
  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? AppColors.textPrimary : AppColors.white;
  }

  /// Spetsifikatsiyalar bo'limi
  Widget _buildSpecsSection(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Xususiyatlar',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...product.specs.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Xususiyatlar
  Widget _buildFeatures() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Column(
        children: [
          _buildFeatureItem(
            icon: Icons.local_shipping_outlined,
            title: 'Bepul yetkazib berish',
            subtitle: 'Toshkent bo\'ylab',
          ),
          const Divider(height: 28, color: AppColors.lightGrey),
          _buildFeatureItem(
            icon: Icons.verified_outlined,
            title: 'Kafolat',
            subtitle: '2 yil ishlab chiqaruvchi kafolati',
          ),
          const Divider(height: 28, color: AppColors.lightGrey),
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
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
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
