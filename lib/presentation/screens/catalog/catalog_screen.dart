import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/product_model.dart';
import '../../widgets/category_card.dart';
import '../../widgets/product_card.dart';
import '../product/product_detail_screen.dart';

/// Katalog ekrani
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
      padding: const EdgeInsets.all(16),
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
                  // Kategoriyasiz mahsulotlar
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
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(12),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
                icon: const Icon(Icons.arrow_back_ios),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedCategory!.name,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${products.length} ta mahsulot',
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
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
                        color: AppColors.lightGrey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Mahsulotlar topilmadi',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.7,
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
                          begin: const Offset(0.9, 0.9),
                        );
                  },
                ),
        ),
      ],
    );
  }
}
