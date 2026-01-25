import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/utils/localized_text_helper.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/route_names.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../products/data/models/product_model.dart';
import '../bloc/catalog_bloc.dart';
import '../cubit/category_cubit.dart';
import '../widgets/category_list_card.dart';
import '../widgets/filter_chips.dart';
import '../../data/models/category_model.dart';

/// Katalog ekrani - Nabolen Style (Dynamic Categories)
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  CategoryModel? _selectedCategory;
  CategoryModel? _parentCategory; // Asosiy kategoriya (sub-kategoriyalar uchun)
  bool _showProducts = false;
  String? _selectedFilterId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryCubit>().loadMainCategories();
    });
  }

  void _goBack() {
    setState(() {
      _selectedCategory = null;
      _parentCategory = null;
      _showProducts = false;
      _selectedFilterId = null;
    });
    context.read<CatalogBloc>().add(const GoBackToCategories());
  }

  /// Sub-kategoriyalardan filterlar yaratish
  /// Barcha sub-kategoriyalarni ko'rsatish (productCount 0 bo'lsa ham)
  List<FilterChipModel> _getFiltersFromSubCategories(
    List<CategoryModel> subCategories,
  ) {
    final filters = <FilterChipModel>[
      const FilterChipModel(id: 'all', label: 'Barchasi', isDefault: true),
    ];

    // Barcha sub-kategoriyalarni qo'shish (productCount 0 bo'lsa ham)
    for (final subCategory in subCategories) {
      filters.add(
        FilterChipModel(
          id: subCategory.id,
          label: LocalizedTextHelper.get(subCategory.name, context),
        ),
      );
    }

    return filters;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors
            .transparent, // Scroll bo'lganda rang o'zgarishini oldini oladi
        elevation: 0,
        centerTitle: true, // Sarlavhani markazlashtirish
        // 1. CHAP TARAF (Back Button)
        leading: _showProducts
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface, // Oq fon
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _goBack,
                    icon: Icon(Iconsax.arrow_left_2, size: 18),
                    color: AppColors.textPrimary,
                    padding: EdgeInsets.zero, // Ikonkani markazga to'g'irlash
                  ),
                ),
              )
            : null, // Asosiy katalogda orqaga tugmasi yo'q
        // 2. SARLAVHA (Title)
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _showProducts
                ? (_selectedCategory != null
                      ? LocalizedTextHelper.get(
                          _selectedCategory!.name,
                          context,
                        )
                      : 'Katalog')
                : 'Katalog',
            key: ValueKey(_showProducts), // Animatsiya uchun kalit
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: _showProducts ? 18 : 22, // Katalogda kattaroq
              fontWeight: _showProducts ? FontWeight.w600 : FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),

        // 3. O'NG TARAF (Actions)
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _showProducts
                ? IconButton(
                    onPressed: () {
                      // Filter menyusini ochish (Keyinchalik qo'shamiz)
                      // _showFilterModal();
                    },
                    icon: Icon(Iconsax.filter, size: 22), // Filter ikonka
                    color: AppColors.textPrimary,
                  )
                : IconButton(
                    onPressed: () {
                      // Qidiruv sahifasiga o'tish
                      context.pushNamed(RouteNames.search);
                    },
                    icon: Icon(
                      Iconsax.search_normal_1,
                      size: 22,
                    ), // Qidiruv ikonka
                    color: AppColors.textPrimary,
                    iconSize: 26,
                  ),
          ),
        ],
      ),

      body: _showProducts ? _buildProductsList() : _buildCategoryList(),
    );
  }

  /// Kategoriyalar ro'yxati (List Layout with alternating pattern)
  Widget _buildCategoryList() {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage ?? 'Xatolik yuz berdi',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () =>
                      context.read<CategoryCubit>().loadMainCategories(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Qayta yuklash'),
                ),
              ],
            ),
          );
        }

        if (state.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 64,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kategoriyalar topilmadi',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () =>
                      context.read<CategoryCubit>().loadMainCategories(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Qayta yuklash'),
                ),
              ],
            ),
          );
        }

        final mainCategories = state.categories;

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<CategoryCubit>().refresh();
          },
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: mainCategories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final category = mainCategories[index];

              return CategoryListCard(
                    category: category,
                    index: index,
                    onTap: () {
                      if (category.hasSubCategories) {
                        setState(() {
                          _selectedCategory = category;
                          _parentCategory = category;
                          _showProducts = true;
                          _selectedFilterId = 'all';
                        });
                        context.read<CatalogBloc>().add(
                          LoadGroupedProductsPreview(
                            parentId: category.id,
                            limitPerCat: 10,
                          ),
                        );
                        context.read<CatalogBloc>().add(
                          LoadCategoryProducts(
                            categoryId: null,
                            parentId: category.id,
                          ),
                        );
                      } else {
                        setState(() {
                          _selectedCategory = category;
                          _parentCategory = category;
                          _showProducts = true;
                          _selectedFilterId = 'all';
                        });
                        context.read<CatalogBloc>().add(
                          LoadCategoryProducts(
                            categoryId: category.id,
                            parentId: null,
                          ),
                        );
                      }
                    },
                  )
                  .animate()
                  .fadeIn(delay: (80 * index).ms)
                  .slideY(begin: 0.15, curve: Curves.easeOut);
            },
          ),
        );
      },
    );
  }

  /// Mahsulotlar ro'yxati
  Widget _buildProductsList() {
    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        if (state.isProductsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final allProducts = state.products;

        // Filterlar ro'yxatini olish
        // Agar parent kategoriya mavjud bo'lsa va uning sub-kategoriyalari bo'lsa, ularni ishlatish
        final filters = _parentCategory?.hasSubCategories == true
            ? _getFiltersFromSubCategories(_parentCategory!.subCategories)
            : const [
                FilterChipModel(id: 'all', label: 'Barchasi', isDefault: true),
              ];

        // Filtrlangan mahsulotlar
        final filteredProducts = _getFilteredProducts(
          allProducts,
          _selectedFilterId,
        );

        // Agar sub-kategoriya tanlangan va mahsulotlar bo'sh bo'lsa, maxsus xabar ko'rsatish
        if (_selectedFilterId != null &&
            _selectedFilterId != 'all' &&
            allProducts.isEmpty) {
          // Tanlangan sub-kategoriya nomini topish
          final selectedSubCategory = _parentCategory?.subCategories.firstWhere(
            (sub) => sub.id == _selectedFilterId,
            orElse: () => _parentCategory!,
          );

          return CustomScrollView(
            slivers: [
              // Filter Chips
              SliverToBoxAdapter(
                child: FilterChips(
                  filters: filters,
                  selectedFilterId: _selectedFilterId,
                  onFilterSelected: (filterId) {
                    // IN-PLACE FILTERING: No navigation, only state update and BLoC event
                    // This ensures the screen stays on the same page and only the product list updates

                    // Update local state to highlight the selected chip
                    setState(() {
                      _selectedFilterId = filterId ?? 'all';
                    });

                    // Netflix-style instant switching: Use cache first, avoid redundant API calls
                    if (filterId != null && filterId != 'all') {
                      // Sub-category selected - use SwitchToSubCategory for smart cache checking
                      if (_parentCategory?.subCategories.any(
                            (sub) => sub.id == filterId,
                          ) ==
                          true) {
                        // This will check cache first and only make API call if not cached
                        context.read<CatalogBloc>().add(
                          SwitchToSubCategory(
                            categoryId: filterId,
                            useCache:
                                true, // Use cache for instant switching (0ms latency)
                          ),
                        );
                      }
                    } else {
                      // "All" selected - load products for parent category and all sub-categories
                      if (_parentCategory != null) {
                        context.read<CatalogBloc>().add(
                          LoadCategoryProducts(
                            categoryId: null,
                            parentId: _parentCategory!
                                .id, // Use parentId to get all sub-category products
                          ),
                        );
                      }
                    }
                    // NOTE: No context.push, context.go, Navigator.push, or any navigation here
                    // The screen remains on the same page, only the product list updates
                  },
                ),
              ),
              // Empty state for sub-category with no products
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 80,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Bu turdagi categoriyada maxsulot qo\'shilmagan',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        if (allProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 80,
                  color: AppColors.secondary,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Mahsulotlar topilmadi',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // Filter Chips
            SliverToBoxAdapter(
              child: FilterChips(
                filters: filters,
                selectedFilterId: _selectedFilterId,
                onFilterSelected: (filterId) {
                  // IN-PLACE FILTERING: No navigation, only state update and BLoC event
                  // This ensures the screen stays on the same page and only the product list updates

                  // Update local state to highlight the selected chip
                  setState(() {
                    _selectedFilterId = filterId ?? 'all';
                  });

                  // Netflix-style instant switching: Check cache first, then load if needed
                  if (filterId != null && filterId != 'all') {
                    // Sub-category selected - use cached products for instant display
                    if (_parentCategory?.subCategories.any(
                          (sub) => sub.id == filterId,
                        ) ==
                        true) {
                      // Try instant switch using cache
                      context.read<CatalogBloc>().add(
                        SwitchToSubCategory(
                          categoryId: filterId,
                          useCache: true, // Use cache for instant switching
                        ),
                      );
                    }
                  } else {
                    // "All" selected - load products for parent category and all sub-categories
                    if (_parentCategory != null) {
                      context.read<CatalogBloc>().add(
                        LoadCategoryProducts(
                          categoryId: null,
                          parentId: _parentCategory!
                              .id, // Use parentId to get all sub-category products
                        ),
                      );
                    }
                  }
                  // NOTE: No context.push, context.go, Navigator.push, or any navigation here
                  // The screen remains on the same page, only the product list updates
                },
              ),
            ),
            // Mahsulotlar soni
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${filteredProducts.length} ta mahsulot',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Mahsulotlar Grid
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: filteredProducts.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.filter_alt_outlined,
                                size: 64,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tanlangan filter bo\'yicha mahsulotlar topilmadi',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.72,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = filteredProducts[index];
                        return ProductCard(
                              product: product,
                              onTap: () {
                                context.pushNamed(
                                  RouteNames.productDetail,
                                  pathParameters: {'productId': product.id},
                                );
                              },
                            )
                            .animate()
                            .fadeIn(delay: (40 * index).ms)
                            .scale(begin: const Offset(0.95, 0.95));
                      }, childCount: filteredProducts.length),
                    ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  /// Mahsulotlarni filtrlash
  List<ProductModel> _getFilteredProducts(
    List<ProductModel> products,
    String? filterId,
  ) {
    if (filterId == null || filterId == 'all') {
      return products;
    }

    // Sub-kategoriya ID bo'lsa, backenddan kelgan mahsulotlar allaqachon filtrlangan
    // Statik filterlar uchun mahsulotlarni filtrlash
    // Hozircha barcha mahsulotlarni qaytaramiz, chunki asosiy filtrlash backendda bo'ladi
    return products;
  }
}
