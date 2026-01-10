import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/product_model.dart';
import '../../widgets/category_card.dart';
import '../../widgets/product_card.dart';
import '../product/product_detail_screen.dart';

/// Katalog ekrani - Nabolen Style
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String? _expandedCategoryId;
  CategoryModel? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Katalog'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: _selectedCategory != null
          ? _buildProductsList()
          : _buildCategoryList(),
    );
  }

  /// Kategoriyalar ro'yxati
  Widget _buildCategoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: MockData.categories.length,
      itemBuilder: (context, index) {
        final category = MockData.categories[index];
        final isExpanded = _expandedCategoryId == category.id;
        final hasChildren = category.children.isNotEmpty;

        return Column(
          children: [
            CategoryCard(
              category: category,
              isExpanded: isExpanded,
              onTap: () {
                if (hasChildren) {
                  setState(() {
                    _expandedCategoryId = isExpanded ? null : category.id;
                  });
                } else {
                  setState(() {
                    _selectedCategory = category;
                  });
                }
              },
            ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: -0.1),
            // Ichki kategoriyalar
            if (isExpanded && hasChildren)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
                child: Column(
                  children: category.children.map((subCategory) {
                    return SubCategoryItem(
                      category: subCategory,
                      onTap: () {
                        setState(() {
                          _selectedCategory = subCategory;
                        });
                      },
                    );
                  }).toList(),
                ),
              ).animate().fadeIn().slideY(begin: -0.1),
          ],
        );
      },
    );
  }

  /// Mahsulotlar ro'yxati
  Widget _buildProductsList() {
    final products = MockData.getProductsByCategory(_selectedCategory!.id);

    return Column(
      children: [
        // Orqaga tugmasi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withValues(alpha: 0.06),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _selectedCategory!.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${products.length} ta',
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
        // Mahsulotlar
        Expanded(
          child: products.isEmpty
              ? Center(
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
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                    ).animate().fadeIn(delay: (50 * index).ms).scale(
                          begin: const Offset(0.95, 0.95),
                        );
                  },
                ),
        ),
      ],
    );
  }
}
