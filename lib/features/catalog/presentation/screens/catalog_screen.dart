import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/localized_text_helper.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/route_names.dart';
import '../../../../core/widgets/product_card.dart';
import '../bloc/catalog_bloc.dart';
import '../../data/models/category_model.dart';

/// Katalog ekrani - Nabolen Style (Dynamic Categories)
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  CategoryModel? _selectedCategory;
  bool _showProducts = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogBloc>().add(const LoadCategories());
    });
  }

  void _onSubCategoryTap(CategoryModel subCategory, CategoryModel parent) {
    setState(() {
      _selectedCategory = subCategory;
      _showProducts = true;
    });
    context.read<CatalogBloc>().add(
      LoadCategoryProducts(categoryId: subCategory.id),
    );
  }

  void _goBack() {
    setState(() {
      _selectedCategory = null;
      _showProducts = false;
    });
    context.read<CatalogBloc>().add(const GoBackToCategories());
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

  /// Kategoriyalar ro'yxati (ExpansionTile bilan)
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

        return RefreshIndicator(
          onRefresh: () async {
            context.read<CatalogBloc>().add(const LoadCategories());
          },
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];
              return _buildCategoryTile(category, index);
            },
          ),
        );
      },
    );
  }

  /// Kategoriya tile (ExpansionTile)
  Widget _buildCategoryTile(CategoryModel category, int index) {
    final hasSubCategories = category.subCategories.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: AppColors.primary.withValues(alpha: 0.1),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          leading: _buildCategoryIcon(category),
          title: Text(
            LocalizedTextHelper.get(category.name, context),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: category.productCount > 0
              ? Text(
                  '${category.productCount} ta mahsulot',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                )
              : null,
          trailing: hasSubCategories
              ? null
              : const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          expandedAlignment: Alignment.centerLeft,
          onExpansionChanged: (expanded) {
            if (!hasSubCategories) {
              setState(() {
                _selectedCategory = category;
                _showProducts = true;
              });
              context.read<CatalogBloc>().add(
                LoadCategoryProducts(categoryId: category.id),
              );
            }
          },
          children: hasSubCategories
              ? category.subCategories
                    .map((sub) => _buildSubCategoryItem(sub, category))
                    .toList()
              : [],
        ),
      ),
    ).animate().fadeIn(delay: (40 * index).ms).slideX(begin: -0.05);
  }

  /// Kategoriya ikoni
  Widget _buildCategoryIcon(CategoryModel category) {
    if (category.hasIconUrl) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: category.fullIconUrl,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Icon(Icons.category_outlined, color: AppColors.primary),
            errorWidget: (context, url, error) =>
                const Icon(Icons.category_outlined, color: AppColors.primary),
          ),
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.category_outlined, color: AppColors.primary),
    );
  }

  /// Sub-kategoriya elementi
  Widget _buildSubCategoryItem(
    CategoryModel subCategory,
    CategoryModel parent,
  ) {
    return InkWell(
      onTap: () => _onSubCategoryTap(subCategory, parent),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Sub-kategoriya ikoni
            if (subCategory.hasIconUrl)
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: subCategory.fullIconUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      child: const Icon(Icons.category, size: 16),
                    ),
                  ),
                ),
              ),
            // Nomi
            Expanded(
              child: Text(
                LocalizedTextHelper.get(subCategory.name, context),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Mahsulotlar soni
            if (subCategory.productCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${subCategory.productCount}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
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

        final products = state.products;

        if (products.isEmpty) {
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

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                      '${products.length} ta mahsulot',
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
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
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
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
