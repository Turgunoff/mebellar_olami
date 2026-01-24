import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/route_names.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/widgets/custom_button.dart';

/// Kirish ekrani - Nabolen Style
class LoginScreen extends StatefulWidget {
  final bool isFromOnboarding;

  const LoginScreen({super.key, this.isFromOnboarding = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Telefon raqamini formatlash (+998 qo'shish)
    String phone = _phoneController.text.trim();
    if (!phone.startsWith('+')) {
      phone = '+998$phone';
    }

    context.read<AuthBloc>().add(
      AuthLoginRequested(phone: phone, password: _passwordController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isFromOnboarding
            ? IconButton(
                onPressed: () => context.pop(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              )
            : IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            if (mounted) {
              context.goNamed(RouteNames.main);
            }
          } else if (state is AuthFailure) {
            const noInternetMessage =
                "Internet aloqasi yo'q. Iltimos, tarmoqni tekshiring.";
            if (state.message == noInternetMessage) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Internet yo\'q'),
                  content: const Text(noInternetMessage),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Bekor qilish'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pop();
                        _handleLogin();
                      },
                      child: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Sarlavha
                    Text(
                      'auth.login'.tr(),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn().slideX(begin: -0.1),
                    const SizedBox(height: 10),
                    Text(
                      'auth.login_subtitle'.tr(),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 40),
                    // Telefon raqami
                    _buildPhoneField(
                      controller: _phoneController,
                      label: 'auth.phone'.tr(),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'auth.enter_phone'.tr();
                        }
                        // Raqamlarni tekshirish
                        final digits = value!.replaceAll(RegExp(r'[^0-9]'), '');
                        if (digits.length < 9) {
                          return 'auth.invalid_phone'.tr();
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                    const SizedBox(height: 20),
                    // Parol
                    _buildTextField(
                      controller: _passwordController,
                      label: 'auth.password'.tr(),
                      hint: 'auth.password_hint'.tr(),
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'auth.enter_password'.tr();
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                    const SizedBox(height: 16),
                    // Eslab qolish va Parolni unutdim
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Remember me
                        GestureDetector(
                          onTap: () {
                            setState(() => _rememberMe = !_rememberMe);
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: _rememberMe
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _rememberMe
                                        ? AppColors.primary
                                        : AppColors.lightGrey,
                                    width: 2,
                                  ),
                                ),
                                child: _rememberMe
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: AppColors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'auth.remember_me'.tr(),
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Forgot password
                        TextButton(
                          onPressed: () {
                            context.pushNamed(RouteNames.forgotPassword);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'auth.forgot_password'.tr(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 30),
                    // Kirish tugmasi
                    CustomButton(
                      text: 'auth.login'.tr(),
                      width: double.infinity,
                      isLoading: isLoading,
                      onPressed: _handleLogin,
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                    const SizedBox(height: 30),
                    // Yoki
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: AppColors.lightGrey),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'auth.or_login'.tr(),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: AppColors.lightGrey),
                        ),
                      ],
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 24),
                    // Ijtimoiy tarmoqlar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(icon: 'G', onTap: () {}),
                        const SizedBox(width: 16),
                        _buildSocialButton(icon: '', onTap: () {}),
                        const SizedBox(width: 16),
                        _buildSocialButton(icon: 'f', onTap: () {}),
                      ],
                    ).animate().fadeIn(delay: 700.ms),
                    const SizedBox(height: 40),
                    // Ro'yxatdan o'tish
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'auth.no_account'.tr(),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.pushReplacementNamed(RouteNames.signup);
                          },
                          child: Text(
                            'auth.signup'.tr(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 800.ms),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Telefon raqami uchun maxsus input
  Widget _buildPhoneField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          validator: validator,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
          ],
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'auth.phone_hint'.tr(),
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              fontSize: 15,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '🇺🇿 +998',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 24, color: AppColors.lightGrey),
                ],
              ),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              fontSize: 15,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    IconData iconData;
    if (icon == 'G') {
      iconData = Icons.g_mobiledata;
    } else if (icon == '') {
      iconData = Icons.apple;
    } else {
      iconData = Icons.facebook;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Icon(
          iconData,
          size: icon == 'G' ? 36 : 28,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
