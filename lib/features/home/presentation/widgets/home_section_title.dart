import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_theme.dart';

class HomeSectionTitle extends StatelessWidget {
  final String title;
  final bool showAll;
  final VoidCallback? onShowAllTap;

  const HomeSectionTitle({
    super.key,
    required this.title,
    this.showAll = false,
    this.onShowAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showAll)
            GestureDetector(
              onTap: onShowAllTap,
              child: const Text(
                'Hammasi',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
