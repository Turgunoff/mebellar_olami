import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_theme.dart';
import '../../data/models/category_model.dart';

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

class SubCategoryItem extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;

  const SubCategoryItem({super.key, required this.category, this.onTap});

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
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.secondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getIcon(category.iconName),
                size: 28,
                color: isSelected ? AppColors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 64,
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
