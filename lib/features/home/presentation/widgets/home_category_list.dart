import 'package:flutter/material.dart';
import '../../../catalog/data/models/category_model.dart';
import 'horizontal_category_item.dart';

class HomeCategoryList extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  const HomeCategoryList({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox(height: 20);
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return HorizontalCategoryItem(
            category: category,
            isSelected: selectedCategoryId == category.id,
            onTap: () {
              onCategorySelected(
                selectedCategoryId == category.id ? null : category.id,
              );
            },
          );
        },
      ),
    );
  }
}
