import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
                  // Floating AppBar with Header
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    pinned: false,
                    backgroundColor: AppColors.background,
                    elevation: 10,
                    surfaceTintColor: Colors.transparent,
                    toolbarHeight: 70,
                    title: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.lightGrey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/logo/app_logo_removebg.png',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.chair_outlined,
                                          color: AppColors.white,
                                          size: 24,
                                        ),
                                      );
                                    },
                                  ),
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
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.lightGrey,
                                width: 1,
                              ),
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
                    ),
                    // bottom: PreferredSize(
                    //   preferredSize: const Size.fromHeight(50),
                    //   child: Padding(
                    //     padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    //     child: GestureDetector(
                    //       onTap: () {},
                    //       child: Container(
                    //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    //         decoration: BoxDecoration(
                    //           color: AppColors.surface,
                    //           borderRadius: BorderRadius.circular(12),
                    //           border: Border.all(color: AppColors.lightGrey, width: 1),
                    //         ),
                    //         child: Row(
                    //           mainAxisSize: MainAxisSize.min,
                    //           children: [
                    //             const Icon(
                    //               Icons.location_on_outlined,
                    //               color: AppColors.primary,
                    //               size: 18,
                    //             ),
                    //             const SizedBox(width: 6),
                    //             const Text(
                    //               'Deliver to Tashkent, Uzbekistan',
                    //               style: TextStyle(
                    //                 color: AppColors.textSecondary,
                    //                 fontSize: 13,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //             const SizedBox(width: 4),
                    //             const Icon(
                    //               Icons.keyboard_arrow_down_rounded,
                    //               color: AppColors.textSecondary,
                    //               size: 18,
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ),
                  // Search Bar
                  SliverToBoxAdapter(child: _buildSearchBar()),
                  // Banner Slider
                  const SliverToBoxAdapter(child: HomeBannerSlider()),
                  // Categories Section
                  SliverToBoxAdapter(child: _buildCategoriesHeader()),
                  SliverToBoxAdapter(child: _buildCategoriesRow(state)),
                  // New Arrivals Section
                  SliverToBoxAdapter(child: _buildNewArrivalsHeader()),
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
          readOnly: true,
          onTap: () {
            context.pushNamed(RouteNames.search);
          },
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
            // suffixIcon: Row(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     Container(
            //       margin: const EdgeInsets.only(right: 8),
            //       padding: const EdgeInsets.all(8),
            //       decoration: BoxDecoration(
            //         color: AppColors.primary,
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //       child: const Icon(
            //         Icons.tune_rounded,
            //         color: AppColors.white,
            //         size: 18,
            //       ),
            //     ),
            //   ],
            // ),
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

  Widget _buildNewArrivalsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Chap taraf: Sarlavha + Kichik Ikonka
          Row(
            children: [
              Text(
                'home.new_arrivals'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              // "Hot/New" ekanligini bildiruvchi vizual element
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(
                    0.1,
                  ), // Juda och olovrang fon
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  size: 16,
                  color: Colors.orange, // Olovrang
                ),
              ),
            ],
          ),

          // O'ng taraf: Harakat tugmasi
          TextButton(
            onPressed: () {
              // Yangi mahsulotlar sahifasiga o'tish
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              "Barchasi", // Yoki 'home.see_all'.tr()
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1);
  }

  Widget _buildNewArrivalsRow(HomeState state) {
    if (state is HomeLoading) {
      return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 20, right: 4),
          itemCount: 3,
          itemBuilder: (context, index) {
            return const Padding(
              padding: EdgeInsets.only(right: 20),
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
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.lightGrey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: AppColors.textSecondary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'Yangi mahsulotlar hozircha yo\'q',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 180,
        child: ListView.builder(
          padding: const EdgeInsets.only(left: 20, right: 4),
          scrollDirection: Axis.horizontal,
          itemCount: newProducts.length,
          itemBuilder: (context, index) {
            final product = newProducts[index];
            return ProductCardHorizontal(
                  product: product,
                  onTap: () => _navigateToProduct(product),
                )
                .animate()
                .fadeIn(delay: (80 * index).ms)
                .slideX(begin: 0.2)
                .scale(begin: const Offset(0.9, 0.9), duration: 400.ms);
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'home.categories'.tr(), // Yoki tr()
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          TextButton(
            onPressed: () {
              // Kategoriyalar sahifasiga o'tish logikasi
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              "Barchasi",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary, // Asosiy rangda
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow(HomeState state) {
    // Loading State
    if (state is HomeLoading) {
      return SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 6,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) => const CategorySkeleton(),
        ),
      );
    }

    final categories = state is HomeLoaded
        ? state.categories
        : <CategoryModel>[];

    // Empty State (Minimalist)
    if (categories.isEmpty) {
      return Center(
        child: TextButton.icon(
          onPressed: () =>
              context.read<HomeBloc>().add(const RefreshHomeData()),
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Kategoriyalarni yuklash'),
        ),
      );
    }

    // Loaded State
    return SizedBox(
      height: 120,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return CategoryItem(category: categories[index])
              .animate()
              .fadeIn(delay: (50 * index).ms)
              .slideX(begin: 0.1, curve: Curves.easeOut);
        },
      ),
    );
  }

  Widget _buildProductsGrid(HomeState state) {
    // Loading holati uchun oddiy grid qoldiramiz (Masonry skeleton qiyinroq)
    if (state is HomeLoading) {
      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.70,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const ProductCardSkeleton(),
          childCount: 4,
        ),
      );
    }

    // Filtrlash shart emas dedingiz, shunchaki borini olamiz
    final products = state is HomeLoaded
        ? state.popularProducts
        : <ProductModel>[];

    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text("Mahsulotlar topilmadi"), // Soddalashtirilgan
          ),
        ),
      );
    }

    // 🔥 Masonry Grid (Staggered)
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ), // Yonlardan joy
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2, // 2 ta ustun
        mainAxisSpacing: 16, // Vertikal oraliq
        crossAxisSpacing: 16, // Gorizontal oraliq
        childCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCardVertical(
            product: product,
            onTap: () => _navigateToProduct(product),
            onAddToCart: () {
              // TODO: Savatga qo'shish logikasi
            },
          ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1);
        },
      ),
    );
  }
}
