import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/route_names.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/di/dependency_injection.dart' as di;

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
      image: 'assets/images/photo-1555041469-a586c61ea9bc.jpeg',
      title: 'onboarding.easy_shopping'.tr(),
      subtitle: 'onboarding.easy_shopping_subtitle'.tr(),
      backgroundColor: AppColors.secondary,
      isDark: false,
    ),
    OnboardingData(
      image: 'assets/images/photo-1567538096630-e0c55bd6374c.jpeg',
      title: 'onboarding.easy_design'.tr(),
      subtitle: 'onboarding.easy_design_subtitle'.tr(),
      backgroundColor: const Color(0xFF4A5043),
      isDark: true,
    ),
    OnboardingData(
      image: 'assets/images/photo-1586023492125-27b2c045efd7.jpeg',
      title: 'onboarding.view_place'.tr(),
      subtitle: 'onboarding.view_place_subtitle'.tr(),
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

  void _goToWelcome() {
    // Dispatch event to complete onboarding
    // Navigation will happen via BlocListener when state updates
    di.sl<AuthBloc>().add(const CompleteOnboardingEvent());
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
    return BlocListener<AuthBloc, AuthState>(
      bloc: di.sl<AuthBloc>(),
      listener: (context, state) {
        // Navigate to welcome when onboarding is completed
        if (state.isOnboardingCompleted && mounted) {
          context.goNamed(RouteNames.welcome);
        }
      },
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          color: _currentBgColor,
          child: SafeArea(
            child: Column(
            children: [
              // O'tkazish tugmasi (yuqori o'ng) - FIXED
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
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
                        child: Text('onboarding.skip'.tr()),
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
                        child: Image.asset(
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
                                  ? (_isDark
                                        ? AppColors.white
                                        : AppColors.primary)
                                  : (_isDark
                                        ? AppColors.white.withValues(alpha: 0.3)
                                        : AppColors.primary.withValues(
                                            alpha: 0.3,
                                          )),
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
                            color: _isDark
                                ? AppColors.white
                                : AppColors.textPrimary,
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
                                borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadius,
                                ),
                              ),
                            ),
                            child: Text(
                              'onboarding.start'.tr(),
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
                              color: _isDark
                                  ? AppColors.white
                                  : AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (_isDark
                                              ? AppColors.white
                                              : AppColors.primary)
                                          .withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: _isDark
                                  ? AppColors.primary
                                  : AppColors.white,
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
