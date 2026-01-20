import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/data/auth_repository.dart';
import '../auth/welcome_screen.dart';

/// Onboarding ekrani - Nabolen Style
/// Faqat rasm va rang scroll bo'ladi, matn va indikator fixed
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      image: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
      title: 'Oson Xarid Qiling',
      subtitle: 'Mukammal joy yaratishda yordam kerakmi?\nBizning dizayn xizmatimiz sizni\nprofessionallar bilan bog\'laydi.',
      backgroundColor: AppColors.secondary,
      isDark: false,
    ),
    OnboardingData(
      image: 'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=800',
      title: 'Dizayn Oson!',
      subtitle: 'Mukammal joy yaratishda yordam kerakmi?\nBizning konsultatsiya xizmatimiz sizning\nfikringizni hayotga tatbiq etadi.',
      backgroundColor: const Color(0xFF4A5043),
      isDark: true,
    ),
    OnboardingData(
      image: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800',
      title: 'Ko\'ring, Joylashtiring!',
      subtitle: 'Mebellaringizni kengaytirilgan\nreallikda ko\'ring. Sotib olishdan oldin\nbo\'shliqda joylashtiring.',
      backgroundColor: const Color(0xFF3D4A3A),
      isDark: true,
      isLast: true,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToWelcome() async {
    final authRepository = context.read<AuthRepository>();
    await authRepository.setOnboardingCompleted();
    if (mounted) {
      context.read<AuthBloc>().add(const AuthCheckStatus());
    }
    
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _currentPage == _pages.length - 1;
  bool get _isDark => _pages[_currentPage].isDark;
  Color get _currentBgColor => _pages[_currentPage].backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: _currentBgColor,
        child: SafeArea(
          child: Column(
            children: [
              // O'tkazish tugmasi (yuqori o'ng) - FIXED
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _goToWelcome,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          color: _isDark ? AppColors.white : AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        child: const Text('O\'tkazish'),
                      ),
                    ),
                  ],
                ),
              ),
              // FAQAT RASM - PageView (scroll bo'ladigan qism)
              Expanded(
                flex: 5,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          _pages[index].image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.surface,
                              child: const Icon(
                                Icons.image_outlined,
                                size: 60,
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppColors.surface,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              // FIXED QISM - Indikator, Matn va Tugmalar
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Page indicator - FIXED
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? (_isDark ? AppColors.white : AppColors.primary)
                                  : (_isDark
                                      ? AppColors.white.withValues(alpha: 0.3)
                                      : AppColors.primary.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Sarlavha - FIXED, faqat matn animatsiya bilan o'zgaradi
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _pages[_currentPage].title,
                          key: ValueKey(_pages[_currentPage].title),
                          style: TextStyle(
                            color: _isDark ? AppColors.white : AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Izoh - FIXED, faqat matn animatsiya bilan o'zgaradi
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _pages[_currentPage].subtitle,
                          key: ValueKey(_pages[_currentPage].subtitle),
                          style: TextStyle(
                            color: _isDark
                                ? AppColors.white.withValues(alpha: 0.8)
                                : AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Spacer(),
                      // Tugmalar - FIXED
                      if (_isLastPage) ...[
                        // Oxirgi sahifa - Boshlash tugmasi
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: _goToWelcome,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                              ),
                            ),
                            child: const Text(
                              'Boshlash',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Keyingi tugmasi
                        GestureDetector(
                          onTap: _nextPage,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: _isDark ? AppColors.white : AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_isDark ? AppColors.white : AppColors.primary)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: _isDark ? AppColors.primary : AppColors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Onboarding ma'lumotlari
class OnboardingData {
  final String image;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final bool isDark;
  final bool isLast;

  OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    this.isDark = false,
    this.isLast = false,
  });
}
