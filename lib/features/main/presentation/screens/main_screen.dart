import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mebel_customer/core/constants/app_colors.dart';
import 'package:mebel_customer/core/constants/app_theme.dart';
import 'package:mebel_customer/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:mebel_customer/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:mebel_customer/features/home/presentation/screens/home_screen.dart';
import 'package:mebel_customer/features/catalog/presentation/screens/catalog_screen.dart';
import 'package:mebel_customer/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:mebel_customer/features/cart/presentation/screens/cart_screen.dart';
import 'package:mebel_customer/features/profile/presentation/screens/profile_screen.dart';
import '../cubit/navigation_cubit.dart';

/// Asosiy ekran - Bottom Navigation - Nabolen Style
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const CatalogScreen(),
    const FavoritesScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          body: IndexedStack(index: currentIndex, children: _screens),
          bottomNavigationBar: _buildBottomNavigationBar(currentIndex),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Asosiy',
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
                label: 'Katalog',
                currentIndex: currentIndex,
              ),
              _buildFavoritesNavItem(currentIndex),
              _buildCartNavItem(currentIndex),
              _buildNavItem(
                index: 4,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profil',
                currentIndex: currentIndex,
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 1, duration: 500.ms, curve: Curves.easeOut);
  }

  Widget _buildFavoritesNavItem(int currentIndex) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        final isActive = currentIndex == 2;
        final favoritesCount = state.favorites.length;

        return GestureDetector(
          onTap: () {
            context.read<NavigationCubit>().changeIndex(2);
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Badge(
                  isLabelVisible: favoritesCount > 0,
                  label: Text(
                    favoritesCount > 99 ? '99+' : favoritesCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: AppColors.error,
                  child: Icon(
                    isActive
                        ? Icons.favorite_rounded
                        : Icons.favorite_outline_rounded,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sevimli',
                  style: TextStyle(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: isActive
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartNavItem(int currentIndex) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final isActive = currentIndex == 3;
        final itemCount = state.itemCount;

        return GestureDetector(
          onTap: () {
            context.read<NavigationCubit>().changeIndex(3);
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive
                          ? Icons.shopping_cart_rounded
                          : Icons.shopping_cart_outlined,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Savatcha',
                      style: TextStyle(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface,
                          width: 1.5,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        itemCount > 99 ? '99+' : itemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int currentIndex,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        context.read<NavigationCubit>().changeIndex(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
