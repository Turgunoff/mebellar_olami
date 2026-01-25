import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/localized_text_helper.dart';
import '../../../catalog/data/models/category_model.dart';

class CategoryItem extends StatefulWidget {
  final CategoryModel category;
  final VoidCallback? onTap;

  const CategoryItem({super.key, required this.category, this.onTap});

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _animationController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: widget.category.hasIconUrl
                      ? CachedNetworkImage(
                          imageUrl: widget.category.fullIconUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: AppColors.secondary.withValues(
                              alpha: 0.3,
                            ),
                            highlightColor: AppColors.secondary.withValues(
                              alpha: 0.1,
                            ),
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
                LocalizedTextHelper.get(widget.category.name, context),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
