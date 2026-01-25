import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/dependency_injection.dart' as di;
import '../../../../core/utils/route_names.dart';
import '../cubit/sub_category_cubit.dart';
import '../widgets/sub_category_grid_card.dart';

class SubCategoryScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const SubCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<SubCategoryCubit>()..loadSubCategories(categoryId),
      child: _SubCategoryScreenContent(
        categoryId: categoryId,
        categoryName: categoryName,
      ),
    );
  }
}

class _SubCategoryScreenContent extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const _SubCategoryScreenContent({
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Iconsax.arrow_left_2, size: 18),
              color: AppColors.textPrimary,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(
          categoryName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: BlocBuilder<SubCategoryCubit, SubCategoryState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Xatolik yuz berdi',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => context
                        .read<SubCategoryCubit>()
                        .loadSubCategories(categoryId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Qayta yuklash'),
                  ),
                ],
              ),
            );
          }

          if (state.subCategories.isEmpty) {
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
                    'Sub-kategoriyalar topilmadi',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          final subCategories = state.subCategories;

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<SubCategoryCubit>().refresh(categoryId);
            },
            color: AppColors.primary,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemCount: subCategories.length,
              itemBuilder: (context, index) {
                final subCategory = subCategories[index];

                return SubCategoryGridCard(
                      category: subCategory,
                      onTap: () {
                        // TODO: Navigate to ProductListScreen
                        // For now, navigate to product detail or print
                        debugPrint(
                          'SubCategory tapped: ${subCategory.id} - ${subCategory.name}',
                        );
                        // Placeholder navigation - will be updated when ProductListScreen is ready
                        context.pushNamed(
                          RouteNames.categoryProducts,
                          pathParameters: {'categoryId': subCategory.id},
                          extra: {'categoryName': subCategory.name},
                        );
                      },
                    )
                    .animate()
                    .fadeIn(delay: (60 * index).ms)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      curve: Curves.easeOut,
                    );
              },
            ),
          );
        },
      ),
    );
  }
}
