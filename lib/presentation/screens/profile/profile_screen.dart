import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/order_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/orders_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';
import '../auth/welcome_screen.dart';
import 'edit_profile_screen.dart';

/// Profil ekrani - Nabolen Style
/// iOS Settings uslubida professional dizayn
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isLoggedIn) {
        // Profilni va buyurtmalarni yuklash
        context.read<UserProvider>().fetchUserProfile();
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
        centerTitle: true,
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
                Icons.person_outline_rounded,
                size: 56,
                color: AppColors.primary,
              ),
            ).animate().scale(curve: Curves.elasticOut),
            const SizedBox(height: 28),
            const Text(
              'Buyurtmalaringizni\nboshqaring',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            const Text(
              'Buyurtmalar tarixini ko\'rish va\nboshqarish uchun tizimga kiring',
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
    final userProvider = context.watch<UserProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<UserProvider>().fetchUserProfile();
        await context.read<OrdersProvider>().loadOrders();
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil kartasi
            _buildProfileCard(authProvider, userProvider)
                .animate()
                .fadeIn()
                .slideY(begin: -0.1),
            const SizedBox(height: 24),

            // Asosiy menyu
            _buildMenuSection(
              title: 'Asosiy',
              items: [
                _MenuItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Mening Buyurtmalarim',
                  subtitle: 'Buyurtmalar tarixini ko\'ring',
                  onTap: () => _showOrdersBottomSheet(context),
                ),
                _MenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Manzillar',
                  subtitle: 'Yetkazib berish manzillari',
                  onTap: () {},
                ),
              ],
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 20),

            // Sozlamalar
            _buildMenuSection(
              title: 'Sozlamalar',
              items: [
                _MenuItem(
                  icon: Icons.language_rounded,
                  title: 'Til',
                  subtitle: 'O\'zbek',
                  trailing: _buildLanguageChip(),
                  onTap: () => _showLanguageDialog(context),
                ),
                _MenuItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Bildirishnomalar',
                  subtitle: 'Push xabarnomalar',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppColors.primary,
                  ),
                  onTap: () {},
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 20),

            // Yordam
            _buildMenuSection(
              title: 'Yordam',
              items: [
                _MenuItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Yordam markazi',
                  subtitle: 'Tez-tez so\'raladigan savollar',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.info_outline_rounded,
                  title: 'Ilova haqida',
                  subtitle: 'Versiya 1.0.0',
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 20),

            // Xavfli zona
            _buildDangerZone(context, authProvider, userProvider)
                .animate()
                .fadeIn(delay: 400.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Profil kartasi
  Widget _buildProfileCard(AuthProvider authProvider, UserProvider userProvider) {
    final name = userProvider.fullName ?? authProvider.userName ?? 'Foydalanuvchi';
    final phone = userProvider.phone ?? authProvider.userPhone ?? '';
    final avatarUrl = userProvider.fullAvatarUrl;

    return GestureDetector(
      onTap: () => _navigateToEditProfile(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
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
                color: AppColors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: avatarUrl != null
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        width: 70,
                        height: 70,
                        placeholder: (context, url) => Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'F',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'F',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'F',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
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
                    name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        phone,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tahrirlash tugmasi
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => _navigateToEditProfile(context),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// EditProfileScreen'ga o'tish
  void _navigateToEditProfile(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );

    // Agar profil yangilangan bo'lsa, ma'lumotlarni qayta yuklash
    if (result == true && mounted) {
      context.read<UserProvider>().fetchUserProfile();
    }
  }

  /// Menyu bo'limi
  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _buildMenuItem(item),
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 60,
                      endIndent: 16,
                      color: AppColors.lightGrey.withValues(alpha: 0.5),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Menyu elementi
  Widget _buildMenuItem(_MenuItem item) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(item.icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        item.title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: item.subtitle != null
          ? Text(
              item.subtitle!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            )
          : null,
      trailing: item.trailing ??
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.textSecondary,
          ),
      onTap: item.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  /// Til chipi
  Widget _buildLanguageChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'O\'zbek',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Xavfli zona
  Widget _buildDangerZone(
    BuildContext context,
    AuthProvider authProvider,
    UserProvider userProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Xavfli zona',
            style: TextStyle(
              color: AppColors.error.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Hisobni o'chirish
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Hisobni o\'chirish',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'Barcha ma\'lumotlar o\'chiriladi',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.error,
                ),
                onTap: () => _showDeleteAccountDialog(context, userProvider, authProvider),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
              Divider(
                height: 1,
                indent: 60,
                endIndent: 16,
                color: AppColors.error.withValues(alpha: 0.1),
              ),
              // Chiqish
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Tizimdan chiqish',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                onTap: () => _showLogoutConfirmation(context, authProvider),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================
  // DIALOGS & BOTTOM SHEETS
  // ============================================

  /// Buyurtmalar bottom sheet
  void _showOrdersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Mening Buyurtmalarim',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Orders list
              Expanded(
                child: _buildOrdersListView(scrollController),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Buyurtmalar ro'yxati
  Widget _buildOrdersListView(ScrollController scrollController) {
    final ordersProvider = context.watch<OrdersProvider>();

    if (ordersProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (ordersProvider.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Buyurtmalar yo\'q',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: ordersProvider.orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(ordersProvider.orders[index]);
      },
    );
  }

  /// Buyurtma kartasi
  Widget _buildOrderCard(OrderModel order) {
    Color statusColor;
    IconData statusIcon;

    switch (order.status) {
      case OrderStatus.newOrder:
        statusColor = AppColors.primary;
        statusIcon = Icons.schedule_rounded;
        break;
      case OrderStatus.processing:
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping_outlined;
        break;
      case OrderStatus.delivered:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_outline_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              order.productImage,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: AppColors.secondary,
                  child: const Icon(Icons.image_not_supported, size: 24),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.productName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
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
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.date.toFormattedDate(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
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
                    fontSize: 11,
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

  /// Til tanlash dialogi
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tilni tanlang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('O\'zbek', 'uz', true),
            const SizedBox(height: 8),
            _buildLanguageOption('Русский', 'ru', false),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String name, String code, bool isSelected) {
    return ListTile(
      title: Text(name),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isSelected ? AppColors.secondary.withValues(alpha: 0.3) : null,
      onTap: () => Navigator.pop(context),
    );
  }

  /// Ilova haqida dialogi
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.weekend_rounded,
                size: 40,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mebellar Olami',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Versiya 1.0.0',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Premium mebel do\'koni',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  /// Hisobni o'chirish tasdiqlash dialogi
  void _showDeleteAccountDialog(
    BuildContext context,
    UserProvider userProvider,
    AuthProvider authProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_rounded, color: AppColors.error),
            ),
            const SizedBox(width: 12),
            const Text('Hisobni o\'chirish'),
          ],
        ),
        content: const Text(
          'Haqiqatan ham hisobingizni o\'chirmoqchimisiz?\n\n'
          'Bu amal qaytarib bo\'lmaydi. Barcha ma\'lumotlaringiz '
          '(buyurtmalar, sevimlilar) butunlay o\'chiriladi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );

              final success = await userProvider.deleteAccount();
              
              if (mounted) {
                Navigator.pop(context); // Loading dialog'ni yopish
                
                if (success) {
                  // Auth holatini tozalash
                  await authProvider.logout();
                  context.read<OrdersProvider>().clearOrders();
                  context.read<FavoritesProvider>().clearFavorites();
                  
                  // Welcome screen'ga o'tish
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(userProvider.errorMessage ?? 'Xatolik yuz berdi'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  /// Chiqish tasdiqlash dialogi
  void _showLogoutConfirmation(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tizimdan chiqish'),
        content: const Text('Haqiqatan ham tizimdan chiqmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authProvider.logout();
              context.read<UserProvider>().reset();
              context.read<OrdersProvider>().clearOrders();
              context.read<FavoritesProvider>().clearFavorites();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Chiqish'),
          ),
        ],
      ),
    );
  }
}

/// Menyu elementi modeli
class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });
}
