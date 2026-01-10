import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/category_card.dart';
import '../product/product_detail_screen.dart';

/// Asosiy ekran - Nabolen Style
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _startBannerAutoScroll();
    // Mahsulotlarni yuklash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchAll();
    });
  }

  void _startBannerAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _bannerController.hasClients) {
        final nextPage = (_currentBannerIndex + 1) % MockData.banners.length;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startBannerAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  void _navigateToProduct(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  List<ProductModel> _getFilteredProducts(ProductProvider productProvider) {
    // Backenddan kelgan mahsulotlar
    final products = productProvider.popularProducts.isNotEmpty
        ? productProvider.popularProducts
        : MockData.popularProducts;

    if (_selectedCategoryId == null) {
      return products;
    }

    // Kategoriya bo'yicha filtrlash
    final categoryPrefix = _selectedCategoryId!.split('_').take(2).join('_');
    return products.where((p) {
      final productCat = p.categoryId ?? '';
      return productCat.startsWith(categoryPrefix);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => productProvider.fetchAll(),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(child: _buildHeader()),
              // Qidiruv
              SliverToBoxAdapter(child: _buildSearchBar()),
              // Banner
              SliverToBoxAdapter(child: _buildPromoBanner()),

              // ===== YANGI KELGANLAR (Gorizontal) =====
              SliverToBoxAdapter(child: _buildSectionHeader('Yangi kelganlar')),
              SliverToBoxAdapter(child: _buildNewArrivalsRow(productProvider)),

              // ===== KATEGORIYALAR =====
              SliverToBoxAdapter(child: _buildSectionHeader('Kategoriyalar')),
              SliverToBoxAdapter(child: _buildCategoriesRow()),

              // ===== OMMABOP MAHSULOTLAR (Grid) =====
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  _selectedCategoryId == null ? 'Ommabop' : 'Mahsulotlar',
                  showAll: true,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: _buildProductsGrid(productProvider),
              ),

              // Pastki bo'shliq
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  /// Header
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assalomu alaykum! 👋',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 4),
              const Text(
                'Mebellar Olami',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
            ],
          ),
          // Bildirishnomalar
          Container(
            width: 50,
            height: 50,
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
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textPrimary,
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).scale(),
        ],
      ),
    );
  }

  /// Qidiruv
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Mebel qidirish...',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
            ),
            suffixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: AppColors.white,
                size: 20,
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
    );
  }

  /// Promo Banner
  Widget _buildPromoBanner() {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: MockData.banners.length,
            itemBuilder: (context, index) {
              final banner = MockData.banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: banner['image']!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: AppColors.secondary),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.secondary,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.85),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Banner matni
                      Positioned(
                        left: 24,
                        top: 0,
                        bottom: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              banner['title']!,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              banner['subtitle']!,
                              style: TextStyle(
                                color: AppColors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Ko\'rish',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
        const SizedBox(height: 14),
        // Indikatorlar
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            MockData.banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBannerIndex == index ? 28 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index
                    ? AppColors.primary
                    : AppColors.secondary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Yangi kelganlar (Gorizontal ListView)
  Widget _buildNewArrivalsRow(ProductProvider productProvider) {
    // Loading holati
    if (productProvider.isLoadingNew) {
      return SizedBox(
        height: 240,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    // Backenddan yoki MockData dan olish
    final newProducts = productProvider.newArrivals.isNotEmpty
        ? productProvider.newArrivals
        : MockData.newProducts;

    if (newProducts.isEmpty) {
      return const SizedBox(height: 20);
    }

    return SizedBox(
      height: 260,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20, right: 4),
        scrollDirection: Axis.horizontal,
        itemCount: newProducts.length,
        itemBuilder: (context, index) {
          final product = newProducts[index];
          return HorizontalProductCard(
            product: product,
            width: 170,
            onTap: () => _navigateToProduct(product),
          ).animate().fadeIn(delay: (60 * index).ms).slideX(begin: 0.1);
        },
      ),
    );
  }

  /// Bo'lim sarlavhasi
  Widget _buildSectionHeader(String title, {bool showAll = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showAll)
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryId = null;
                });
              },
              child: const Text(
                'Hammasi',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Kategoriyalar (Gorizontal)
  Widget _buildCategoriesRow() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20),
        scrollDirection: Axis.horizontal,
        itemCount: MockData.categories.length,
        itemBuilder: (context, index) {
          final category = MockData.categories[index];
          return HorizontalCategoryItem(
            category: category,
            isSelected: _selectedCategoryId == category.id,
            onTap: () {
              setState(() {
                _selectedCategoryId = _selectedCategoryId == category.id
                    ? null
                    : category.id;
              });
            },
          ).animate().fadeIn(delay: (80 * index).ms).slideX(begin: 0.1);
        },
      ),
    );
  }

  /// Mahsulotlar (Grid)
  Widget _buildProductsGrid(ProductProvider productProvider) {
    // Loading holati
    if (productProvider.isLoadingPopular) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Mahsulotlar yuklanmoqda...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final products = _getFilteredProducts(productProvider);

    // Bo'sh holat
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Mahsulotlar topilmadi',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final product = products[index];
        return ProductCard(
              product: product,
              onTap: () => _navigateToProduct(product),
            )
            .animate()
            .fadeIn(delay: (80 * index).ms)
            .scale(begin: const Offset(0.95, 0.95));
      }, childCount: products.length),
    );
  }
}
