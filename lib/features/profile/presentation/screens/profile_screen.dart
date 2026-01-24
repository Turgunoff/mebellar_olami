import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/route_names.dart';
import '../../bloc/profile_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../checkout/data/models/order_model.dart';

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
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        // Profilni yuklash
        context.read<ProfileBloc>().add(LoadProfile());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthUnauthenticated) {
            return _buildGuestView(context);
          }

          if (authState is AuthAuthenticated) {
            return _buildUserView(context, authState);
          }

          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          );
        },
      ),
    );
  }

  /// Mehmon ko'rinishi
  Widget _buildGuestView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Mehmon kartasi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
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
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mehmon',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tizimga kirishingiz kerak',
                  style: TextStyle(fontSize: 14, color: AppColors.white),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1),

          const SizedBox(height: 30),

          // Kirish tugmalari
          _buildAuthButtons(context).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  /// Avtorizatsiya tugmalari
  Widget _buildAuthButtons(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: 'Kirish',
          onPressed: () => context.pushNamed(RouteNames.login),
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Ro\'yxatdan o\'tish',
          isOutlined: true,
          onPressed: () => context.pushNamed(RouteNames.welcome),
        ),
      ],
    );
  }

  /// Foydalanuvchi ko'rinishi
  Widget _buildUserView(BuildContext context, AuthAuthenticated authState) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        return RefreshIndicator(
          onRefresh: () async {
            context.read<ProfileBloc>().add(LoadProfile());
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profil kartasi
                _buildProfileCard(
                  authState,
                  profileState,
                ).animate().fadeIn().slideY(begin: -0.1),
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
                      icon: Icons.language_outlined,
                      title: 'Til',
                      subtitle: 'O\'zbekcha',
                      onTap: () => _showLanguageDialog(context),
                      trailing: _buildLanguageChip('UZ'),
                    ),
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Bildirishnomalar',
                      subtitle: 'Barcha bildirishnomalar yoqilgan',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.help_outline,
                      title: 'Yordam',
                      subtitle: 'Savol va javoblar',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.info_outline,
                      title: 'Ilova haqida',
                      subtitle: 'Versiya 1.0.0',
                      onTap: () => _showAboutDialog(context),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 20),

                // Xavfli zona
                _buildDangerZone(
                  context,
                  authState,
                  profileState,
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Profil kartasi
  Widget _buildProfileCard(
    AuthAuthenticated authState,
    ProfileState profileState,
  ) {
    final userName = authState.user?['full_name'] ?? 'Foydalanuvchi';
    final userPhone = authState.user?['phone'] ?? '';
    final name = profileState.fullName ?? userName;
    final phone = profileState.phone ?? userPhone;
    final avatarUrl = profileState.fullAvatarUrl;

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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              child: avatarUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : Icon(Icons.person, size: 40, color: AppColors.primary),
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone.isNotEmpty ? phone : 'Telefon raqami kiritilmagan',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Profilni tahrirlash →',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.map((item) => _buildMenuItem(item)).toList(),
          ),
        ),
      ],
    );
  }

  /// Menyu elementi
  Widget _buildMenuItem(_MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.trailing != null) item.trailing!,
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  /// Xavfli zona
  Widget _buildDangerZone(
    BuildContext context,
    AuthAuthenticated authState,
    ProfileState profileState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Xavfli zona',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
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
                    Icons.delete_forever_outlined,
                    size: 20,
                    color: AppColors.error,
                  ),
                ),
                title: const Text(
                  'Hisobni o\'chirish',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
                subtitle: const Text(
                  'Barcha ma\'lumotlaringiz o\'chiriladi',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () =>
                    _showDeleteAccountDialog(context, profileState, authState),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
              // Chiqish
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.logout_outlined,
                    size: 20,
                    color: AppColors.error,
                  ),
                ),
                title: const Text(
                  'Chiqish',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
                subtitle: const Text(
                  'Tizimdan chiqish',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () => _showLogoutConfirmation(context, authState),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Til tanlash chipi
  Widget _buildLanguageChip(String language) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        language,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }

  /// Tahrirlashga o'tish
  void _navigateToEditProfile(BuildContext context) async {
    final result = await context.pushNamed<bool>(RouteNames.editProfile);

    // Agar profil yangilangan bo'lsa, ma'lumotlarni qayta yuklash
    if (result == true && mounted) {
      context.read<ProfileBloc>().add(LoadProfile());
    }
  }

  /// Hisobni o'chirish tasdiqlash dialogi
  void _showDeleteAccountDialog(
    BuildContext context,
    ProfileState profileState,
    AuthAuthenticated authState,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hisobni o\'chirish'),
        content: const Text(
          'Hisobni o\'chirgandan so\'ng barcha ma\'lumotlaringiz '
          'qaytarib bo\'lmasligini tushunasizmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              context.pop(); // Dialogni yopish

              // Loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Hisob o\'chirilmoqda...'),
                    ],
                  ),
                ),
              );

              context.read<ProfileBloc>().add(const DeleteAccount());

              // Natijani kutish
              await Future.delayed(const Duration(seconds: 2));

              if (mounted) {
                context.pop(); // Loading dialog'ni yopish

                final currentState = context.read<ProfileBloc>().state;
                if (currentState.isDeleted) {
                  // Muvaffaqiyatli o'chirilgan bo'lsa, tizimdan chiqarish
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                } else {
                  // Xatolik bo'lsa, xabar berish
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        currentState.errorMessage ?? 'Xatolik yuz berdi',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  /// Chiqish tasdiqlash dialogi
  void _showLogoutConfirmation(
    BuildContext context,
    AuthAuthenticated authState,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chiqish'),
        content: const Text('Tizimdan chiqishni istaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              if (mounted) context.pop();
            },
            child: const Text('Chiqish'),
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
        title: const Text('Tilni tanlang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('O\'zbekcha', 'UZ', context),
            _buildLanguageOption('Русский', 'RU', context),
            _buildLanguageOption('English', 'EN', context),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Bekor qilish'),
          ),
        ],
      ),
    );
  }

  /// Til varianti
  Widget _buildLanguageOption(String title, String code, BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: code == 'UZ'
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        // Tilni o'zgartirish logikasi
        context.pop();
      },
    );
  }

  /// Buyurtmalarni ko'rsatish
  void _showOrdersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Mening Buyurtmalarim',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Orders list
            Expanded(child: _buildOrdersListView()),
          ],
        ),
      ),
    );
  }

  /// Buyurtmalar ro'yxati
  Widget _buildOrdersListView() {
    // Mock data - real implementation would fetch from API
    final mockOrders = <OrderModel>[];

    if (mockOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Sizda hali buyurtmalar yo\'q',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: mockOrders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(mockOrders[index]);
      },
    );
  }

  /// Buyurtma kartasi
  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Buyurtma #${order.id}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${order.totalPrice} so\'m',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.status.label,
            style: TextStyle(
              fontSize: 14,
              color: order.status == OrderStatus.completed
                  ? AppColors.success
                  : AppColors.error,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${order.date.day}.${order.date.month}.${order.date.year}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Ilova haqida dialog
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Mebellar Olami',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.weekend_rounded,
        size: 48,
        color: AppColors.primary,
      ),
      children: const [
        Text(
          'Premium mebellar uchun onlayn do\'kon',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

/// Menyu elementi modeli
class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
  });
}
