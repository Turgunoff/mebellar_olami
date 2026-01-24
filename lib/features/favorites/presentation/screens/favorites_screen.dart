import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/localized_text_helper.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/route_names.dart';
import '../../../products/data/models/product_model.dart';
import '../bloc/favorites_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/widgets/custom_button.dart';

/// Sevimlilar ekrani - Nabolen Style
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, favoritesState) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Sevimlilar'),
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            actions: [
              if (favoritesState.favorites.isNotEmpty)
                TextButton(
                  onPressed: () {
                    _showClearConfirmation(context);
                  },
                  child: const Text(
                    'Tozalash',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
            ],
          ),
          body: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final isGuest = authState is! AuthAuthenticated;

              if (isGuest) return _buildGuestView(context);
              if (favoritesState.favorites.isEmpty) return _buildEmptyView();
              return _buildFavoritesList(context, favoritesState);
            },
          ),
        );
      },
    );
  }

  /// Mehmon ko'rinishi
  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_outline_rounded,
                size: 56,
                color: AppColors.primary,
              ),
            ).animate().scale(curve: Curves.elasticOut),
            const SizedBox(height: 28),
            const Text(
              'Sevimli mahsulotlaringiz',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            const Text(
              'Sevimli mahsulotlaringizni saqlash va\nkeyinroq ko\'rish uchun tizimga kiring',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 36),
            CustomButton(
              text: 'Tizimga kirish',
              icon: Icons.login_rounded,
              width: 200,
              onPressed: () {
                context.pushNamed(RouteNames.login);
              },
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  /// Bo'sh ko'rinish
  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 56,
                color: AppColors.textSecondary,
              ),
            ).animate().scale(curve: Curves.elasticOut),
            const SizedBox(height: 28),
            const Text(
              'Sevimlilar bo\'sh',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            const Text(
              'Siz hali birorta mahsulotni\nsevimliga qo\'shmagansiz',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }

  /// Sevimlilar ro'yxati
  Widget _buildFavoritesList(
    BuildContext context,
    FavoritesState favoritesState,
  ) {
    final favorites = favoritesState.favorites
        .map((json) => ProductModel.fromJson(json))
        .toList();

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final product = favorites[index];
        return Dismissible(
          key: Key(product.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
          ),
          onDismissed: (direction) {
            context.read<FavoritesBloc>().add(
              ToggleFavoriteEvent(
                product: {
                  'id': product.id,
                  'name': product.name,
                  'price': product.price,
                  'image_url': product.imageUrl,
                },
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${LocalizedTextHelper.get(product.name, context)} o\'chirildi',
                ),
              ),
            );
          },
          child: ProductCard(
            product: product,
            onTap: () {
              context.pushNamed(
                RouteNames.productDetail,
                pathParameters: {'productId': product.id},
              );
            },
          ).animate().fadeIn(delay: (50 * index).ms),
        );
      },
    );
  }

  /// Tozalash tasdiqlash dialogi
  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        title: const Text('Sevimlilarni tozalash'),
        content: const Text(
          'Barcha sevimli mahsulotlaringiz o\'chiriladi. Davom etasizmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: ClearFavoritesEvent ni FavoritesBloc ga qo'shish kerak
              context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }
}
