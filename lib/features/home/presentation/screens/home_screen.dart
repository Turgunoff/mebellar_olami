import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/route_names.dart';
import '../../../../core/widgets/shimmer/product_card_skeleton.dart';
import '../../../../core/widgets/shimmer/category_skeleton.dart';
import '../../../products/data/models/product_model.dart';
import '../bloc/home_bloc.dart';
import '../widgets/home_banner_slider.dart';
import '../widgets/home_section_title.dart';
import '../widgets/category_item.dart';
import '../widgets/product_card_horizontal.dart';
import '../widgets/product_card_vertical.dart';
import '../../../catalog/data/models/category_model.dart';

/// Asosiy ekran - Nabolen Style
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(const LoadHomeData());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToProduct(ProductModel product) {
    context.pushNamed(
      RouteNames.productDetail,
      pathParameters: {'productId': product.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(const RefreshHomeData());
              },
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(child: _buildHeader()),
                  // Search Bar
                  SliverToBoxAdapter(child: _buildSearchBar()),
                  // Banner Slider
                  const SliverToBoxAdapter(child: HomeBannerSlider()),
                  // Categories Section
                  SliverToBoxAdapter(
                    child: HomeSectionTitle(title: 'home.categories'.tr()),
                  ),
                  SliverToBoxAdapter(child: _buildCategoriesRow(state)),
                  // New Arrivals Section
                  SliverToBoxAdapter(
                    child: HomeSectionTitle(title: 'home.new_arrivals'.tr()),
                  ),
                  SliverToBoxAdapter(child: _buildNewArrivalsRow(state)),
                  // Popular Products Section
                  SliverToBoxAdapter(
                    child: HomeSectionTitle(
                      title: _selectedCategoryId == null
                          ? 'home.popular_products'.tr()
                          : 'home.products'.tr(),
                      showAll: true,
                      onShowAllTap: () {
                        setState(() {
                          _selectedCategoryId = null;
                        });
                      },
                    ),
                  ),
                  // Popular Products Grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: _buildProductsGrid(state),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.chair_outlined,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Mebellar Olami',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightGrey, width: 1),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.favorite_border_rounded,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightGrey, width: 1),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightGrey, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Deliver to Tashkent, Uzbekistan',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(color: AppColors.lightGrey, width: 1),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'What are you looking for?',
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ],
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

  Widget _buildNewArrivalsRow(HomeState state) {
    if (state is HomeLoading) {
      return SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          itemBuilder: (context, index) {
            return const Padding(
              padding: EdgeInsets.only(right: 16),
              child: HorizontalProductCardSkeleton(),
            );
          },
        ),
      );
    }

    final newProducts = state is HomeLoaded
        ? state.newArrivals
        : <ProductModel>[];

    if (newProducts.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'Yangi mahsulotlar hozircha yo\'q',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20, right: 4),
        scrollDirection: Axis.horizontal,
        itemCount: newProducts.length,
        itemBuilder: (context, index) {
          final product = newProducts[index];
          return ProductCardHorizontal(
            product: product,
            onTap: () => _navigateToProduct(product),
          ).animate().fadeIn(delay: (60 * index).ms).slideX(begin: 0.1);
        },
      ),
    );
  }

  Widget _buildCategoriesRow(HomeState state) {
    if (state is HomeLoading) {
      return SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 20),
          itemCount: 6,
          itemBuilder: (context, index) {
            return const Padding(
              padding: EdgeInsets.only(right: 16),
              child: CategorySkeleton(),
            );
          },
        ),
      );
    }

    final categories = state is HomeLoaded
        ? state.categories
        : <CategoryModel>[];

    if (categories.isEmpty) {
      return const SizedBox(height: 20);
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryItem(
            category: category,
          ).animate().fadeIn(delay: (60 * index).ms).slideX(begin: 0.1);
        },
      ),
    );
  }

  Widget _buildProductsGrid(HomeState state) {
    if (state is HomeLoading) {
      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const ProductCardSkeleton(),
          childCount: 6,
        ),
      );
    }

    final products = _selectedCategoryId == null
        ? (state is HomeLoaded ? state.popularProducts : <ProductModel>[])
        : (state is HomeLoaded
              ? state.popularProducts
                    .where((p) => p.categoryId == _selectedCategoryId)
                    .toList()
              : <ProductModel>[]);

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
                const Text(
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
        return ProductCardVertical(
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
