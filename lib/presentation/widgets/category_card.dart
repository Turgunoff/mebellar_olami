import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_theme.dart';
import '../../data/models/product_model.dart';

/// Kategoriya kartasi widgeti - Nabolen Style
class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;
  final bool isExpanded;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.isExpanded = false,
  });

  /// Ikon nomini IconData ga aylantirish
  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'bed':
        return Icons.bed_outlined;
      case 'door_sliding':
        return Icons.door_sliding_outlined;
      case 'nightlight':
        return Icons.nightlight_outlined;
      case 'weekend':
        return Icons.weekend_outlined;
      case 'table_restaurant':
        return Icons.table_restaurant_outlined;
      case 'chair':
        return Icons.chair_outlined;
      case 'chair_alt':
        return Icons.chair_alt_outlined;
      case 'kitchen':
        return Icons.kitchen_outlined;
      case 'shelves':
        return Icons.shelves;
      case 'business_center':
        return Icons.business_center_outlined;
      case 'desk':
        return Icons.desk_outlined;
      case 'deck':
        return Icons.deck_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasChildren = category.subCategories.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Ikon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getIcon(category.iconName),
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                // Nomi va bolalar soni
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (hasChildren) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${category.subCategories.length} ta turkum',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // O'q belgisi
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    hasChildren
                        ? (isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded)
                        : Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary,
                    size: hasChildren ? 24 : 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ichki kategoriya elementi
class SubCategoryItem extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;

  const SubCategoryItem({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 86, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textSecondary,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gorizontal kategoriya elementi (Home uchun)
class HorizontalCategoryItem extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;
  final bool isSelected;

  const HorizontalCategoryItem({
    super.key,
    required this.category,
    this.onTap,
    this.isSelected = false,
  });

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'bed':
        return Icons.bed_outlined;
      case 'weekend':
        return Icons.weekend_outlined;
      case 'kitchen':
        return Icons.kitchen_outlined;
      case 'business_center':
        return Icons.business_center_outlined;
      case 'deck':
        return Icons.deck_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.secondary,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(category.iconName),
              size: 20,
              color: isSelected ? AppColors.white : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
