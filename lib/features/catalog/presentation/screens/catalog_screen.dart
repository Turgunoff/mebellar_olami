import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/localized_text_helper.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/route_names.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../products/data/models/product_model.dart';
import '../bloc/catalog_bloc.dart';
import '../widgets/category_grid_card.dart';
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
      context.read<CatalogBloc>().add(const LoadCategories());
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
        title: Text(
          _showProducts
              ? (_selectedCategory != null
                    ? LocalizedTextHelper.get(_selectedCategory!.name, context)
                    : 'Katalog')
              : 'Katalog',
        ),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: _showProducts
            ? IconButton(
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              )
            : null,
      ),
      body: _showProducts ? _buildProductsList() : _buildCategoryList(),
    );
  }

  /// Kategoriyalar ro'yxati (Zamonaviy Grid View)
  Widget _buildCategoryList() {
    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
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
                      context.read<CatalogBloc>().add(const LoadCategories()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Qayta yuklash'),
                ),
              ],
            ),
          );
        }

        // Faqat mahsulotlari bo'lgan kategoriyalarni ko'rsatish (productCount > 0)
        final categoriesWithProducts = state.categories
            .where((category) => category.productCount > 0)
            .toList();

        if (categoriesWithProducts.isEmpty) {
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
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<CatalogBloc>().add(const LoadCategories());
          },
          color: AppColors.primary,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categoriesWithProducts.length,
            itemBuilder: (context, index) {
              final category = categoriesWithProducts[index];
              return CategoryGridCard(
                    category: category,
                    onTap: () {
                      // Agar sub-kategoriyalar bo'lsa, parent kategoriya sifatida saqlash
                      if (category.hasSubCategories) {
                        setState(() {
                          _selectedCategory = category;
                          _parentCategory =
                              category; // Asosiy kategoriya sifatida saqlash
                          _showProducts = true;
                          _selectedFilterId = 'all'; // Default "Barchasi"
                        });
                        // Parent ID orqali barcha sub-kategoriyalardagi mahsulotlarni yuklash
                        context.read<CatalogBloc>().add(
                          LoadCategoryProducts(
                            categoryId: null,
                            parentId: category.id,
                          ),
                        );
                      } else {
                        // Sub-kategoriyalar yo'q bo'lsa, to'g'ridan-to'g'ri mahsulotlarni ko'rsatish
                        setState(() {
                          _selectedCategory = category;
                          _parentCategory =
                              category; // Asosiy kategoriya sifatida saqlash
                          _showProducts = true;
                          _selectedFilterId = 'all'; // Default "Barchasi"
                        });
                        context.read<CatalogBloc>().add(
                          LoadCategoryProducts(
                            categoryId: category.id,
                            parentId: null, // To'g'ridan-to'g'ri kategoriya
                          ),
                        );
                      }
                    },
                  )
                  .animate()
                  .fadeIn(delay: (60 * index).ms)
                  .scale(begin: const Offset(0.9, 0.9), duration: 400.ms);
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

                    // Trigger BLoC event to refresh products IN-PLACE (no navigation)
                    if (filterId != null && filterId != 'all') {
                      // Sub-category selected - load products for this specific sub-category
                      if (_parentCategory?.subCategories.any(
                            (sub) => sub.id == filterId,
                          ) ==
                          true) {
                        context.read<CatalogBloc>().add(
                          LoadCategoryProducts(
                            categoryId: filterId,
                            parentId:
                                null, // Sub-category selected, use categoryId
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
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _goBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Kategoriyalarga qaytish'),
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

                  // Trigger BLoC event to refresh products IN-PLACE (no navigation)
                  if (filterId != null && filterId != 'all') {
                    // Sub-category selected - load products for this specific sub-category
                    if (_parentCategory?.subCategories.any(
                          (sub) => sub.id == filterId,
                        ) ==
                        true) {
                      context.read<CatalogBloc>().add(
                        LoadCategoryProducts(
                          categoryId: filterId,
                          parentId:
                              null, // Sub-category selected, use categoryId
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
