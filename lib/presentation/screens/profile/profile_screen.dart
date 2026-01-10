import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/order_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/orders_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';

/// Profil ekrani
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Buyurtmalarni yuklash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isLoggedIn) {
        context.read<OrdersProvider>().loadOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: authProvider.isGuest
          ? _buildGuestView(context)
          : _buildUserView(context, authProvider),
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
                Icons.person_outline_rounded,
                size: 60,
                color: AppColors.accent,
              ),
            ).animate().scale(curve: Curves.elasticOut),
            const SizedBox(height: 24),
            const Text(
              'Buyurtmalaringizni boshqaring',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            const Text(
              'Buyurtmalar tarixini ko\'rish va\nboshqarish uchun tizimga kiring',
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

  /// Foydalanuvchi ko'rinishi
  Widget _buildUserView(BuildContext context, AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profil kartasi
          _buildProfileCard(authProvider)
              .animate()
              .fadeIn()
              .slideY(begin: -0.1),
          const SizedBox(height: 24),
          // Buyurtmalarim
          const Text(
            'Buyurtmalarim',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildOrdersList(),
          const SizedBox(height: 24),
          // Sozlamalar
          _buildSettingsSection(context, authProvider),
        ],
      ),
    );
  }

  /// Profil kartasi
  Widget _buildProfileCard(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent,
                  AppColors.accent.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                authProvider.userName?.isNotEmpty == true
                    ? authProvider.userName![0].toUpperCase()
                    : 'F',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Ma'lumotlar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authProvider.userName ?? 'Foydalanuvchi',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authProvider.userPhone ?? '',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Tahrirlash tugmasi
          IconButton(
            onPressed: () {
              // Profil tahrirlash
            },
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  /// Buyurtmalar ro'yxati
  Widget _buildOrdersList() {
    final ordersProvider = context.watch<OrdersProvider>();

    if (ordersProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    if (ordersProvider.orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: AppColors.lightGrey,
            ),
            const SizedBox(height: 12),
            const Text(
              'Buyurtmalar yo\'q',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: ordersProvider.orders.asMap().entries.map((entry) {
        final index = entry.key;
        final order = entry.value;
        return _buildOrderCard(order)
            .animate()
            .fadeIn(delay: (100 * index).ms)
            .slideX(begin: 0.1);
      }).toList(),
    );
  }

  /// Buyurtma kartasi
  Widget _buildOrderCard(OrderModel order) {
    Color statusColor;
    IconData statusIcon;

    switch (order.status) {
      case OrderStatus.newOrder:
        statusColor = AppColors.accent;
        statusIcon = Icons.schedule;
        break;
      case OrderStatus.processing:
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping_outlined;
        break;
      case OrderStatus.delivered:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_outline;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rasm
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              order.productImage,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  color: AppColors.lightGrey,
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Ma'lumotlar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.productName,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  order.totalPrice.toCurrency(),
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.date.toFormattedDate(),
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Holat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  order.status.label,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sozlamalar bo'limi
  Widget _buildSettingsSection(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sozlamalar',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          icon: Icons.person_outline,
          title: 'Profil ma\'lumotlari',
          onTap: () {},
        ),
        _buildSettingItem(
          icon: Icons.location_on_outlined,
          title: 'Manzillar',
          onTap: () {},
        ),
        _buildSettingItem(
          icon: Icons.notifications_none_rounded,
          title: 'Bildirishnomalar',
          onTap: () {},
        ),
        _buildSettingItem(
          icon: Icons.help_outline_rounded,
          title: 'Yordam',
          onTap: () {},
        ),
        _buildSettingItem(
          icon: Icons.info_outline_rounded,
          title: 'Ilova haqida',
          onTap: () {},
        ),
        const SizedBox(height: 16),
        // Chiqish tugmasi
        CustomButton(
          text: 'Chiqish',
          icon: Icons.logout_rounded,
          isOutlined: true,
          backgroundColor: AppColors.error,
          textColor: AppColors.error,
          width: double.infinity,
          onPressed: () {
            _showLogoutConfirmation(context, authProvider);
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  /// Sozlama elementi
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 15,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textGrey,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Chiqish tasdiqlash dialogi
  void _showLogoutConfirmation(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tizimdan chiqish'),
        content: const Text('Haqiqatan ham tizimdan chiqmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              authProvider.logout();
              context.read<OrdersProvider>().clearOrders();
              context.read<FavoritesProvider>().clearFavorites();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Chiqish'),
          ),
        ],
      ),
    );
  }
}
