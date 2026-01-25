import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/localized_text_helper.dart';
import '../../../catalog/data/models/category_model.dart';

class HorizontalCategoryItem extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const HorizontalCategoryItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.textPrimary.withValues(alpha: 0.06),
                    blurRadius: isSelected ? 16 : 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: category.hasIconUrl
                    ? CachedNetworkImage(
                        imageUrl: category.fullIconUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: AppColors.secondary.withValues(alpha: 0.3),
                          highlightColor:
                              AppColors.secondary.withValues(alpha: 0.1),
                          child: Container(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            _buildIconFallback(),
                      )
                    : _buildIconFallback(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              LocalizedTextHelper.get(category.name, context),
              style: TextStyle(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconFallback() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          Icons.category_outlined,
          color: AppColors.primary,
          size: 28,
        ),
      ),
    );
  }
}
