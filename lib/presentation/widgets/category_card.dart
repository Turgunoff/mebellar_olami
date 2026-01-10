import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';

/// Kategoriya kartasi widgeti
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
    final hasChildren = category.children.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ikon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(category.iconName),
                    color: AppColors.accent,
                    size: 24,
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
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (hasChildren) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${category.children.length} ta turkum',
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // O'q belgisi
                Icon(
                  hasChildren
                      ? (isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down)
                      : Icons.arrow_forward_ios,
                  color: AppColors.textGrey,
                  size: hasChildren ? 24 : 16,
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
          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textGrey,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
