import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/custom_button.dart';
import '../product/product_detail_screen.dart';
import '../auth/login_screen.dart';

/// Sevimlilar ekrani
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sevimlilar'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (favoritesProvider.favorites.isNotEmpty)
            TextButton(
              onPressed: () {
                _showClearConfirmation(context, favoritesProvider);
              },
              child: const Text(
                'Tozalash',
                style: TextStyle(color: AppColors.accent),
              ),
            ),
        ],
      ),
      body: authProvider.isGuest
          ? _buildGuestView(context)
          : favoritesProvider.favorites.isEmpty
              ? _buildEmptyView()
              : _buildFavoritesList(context, favoritesProvider),
    );
  }

  /// Mehmon ko'rinishi
  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_outline_rounded,
                size: 60,
                color: AppColors.accent,
              ),
            ).animate().scale(curve: Curves.elasticOut),
            const SizedBox(height: 24),
            const Text(
              'Sevimli mahsulotlaringiz',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            const Text(
              'Sevimli mahsulotlaringizni saqlash va\nkeyinroq ko\'rish uchun tizimga kiring',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Tizimga kirish',
              icon: Icons.login_rounded,
              width: 200,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 60,
                color: AppColors.textGrey,
              ),
            ).animate().scale(curve: Curves.elasticOut),
            const SizedBox(height: 24),
            const Text(
              'Sevimlilar bo\'sh',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            const Text(
              'Siz hali birorta mahsulotni\nsevimliga qo\'shmagansiz',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
                height: 1.5,
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
    FavoritesProvider favoritesProvider,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: favoritesProvider.favorites.length,
      itemBuilder: (context, index) {
        final product = favoritesProvider.favorites[index];
        return Dismissible(
          key: Key(product.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
          ),
          onDismissed: (direction) {
            favoritesProvider.removeFromFavorites(product.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.name} o\'chirildi'),
                action: SnackBarAction(
                  label: 'Qaytarish',
                  onPressed: () {
                    favoritesProvider.addToFavorites(product);
                  },
                ),
              ),
            );
          },
          child: ProductCard(
            product: product,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                ),
              );
            },
          ).animate().fadeIn(delay: (50 * index).ms),
        );
      },
    );
  }

  /// Tozalash tasdiqlash dialogi
  void _showClearConfirmation(
    BuildContext context,
    FavoritesProvider favoritesProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sevimlilarni tozalash'),
        content: const Text(
          'Barcha sevimli mahsulotlaringiz o\'chiriladi. Davom etasizmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              favoritesProvider.clearFavorites();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }
}
