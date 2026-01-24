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
import 'verify_code_screen.dart';

/// Ro'yxatdan o'tish ekrani - Nabolen Style (3 bosqichli)
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeTerms = false;

  // Qaysi bosqichda ekanligimiz (1, 2, 3)
  int _currentStep = 1;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Foydalanuvchi allaqachon mavjud bo'lganda dialog ko'rsatish
  /// Bu Sellerlar o'zlarining mavjud raqamlari bilan Xaridor ilovasiga kirishlari uchun muhim
  void _showUserExistsDialog(BuildContext context, String phone) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: Colors.orange.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'auth.number_exists'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'auth.number_exists_message'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.phone_android,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    phone,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'auth.cancel'.tr(),
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              context.goNamed(
                RouteNames.login,
                queryParameters: {'fromOnboarding': 'true'},
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'auth.go_to_login'.tr(),
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Formatlangan telefon raqami
  String get _formattedPhone {
    String phone = _phoneController.text.trim();
    if (!phone.startsWith('+')) {
      phone = '+998$phone';
    }
    return phone;
  }

  /// 1-Bosqich: Telefon raqamini yuborish va OTP olish
  Future<void> _handleSendOtp() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.enter_phone'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(AuthSendOtpRequested(phone: _formattedPhone));
  }

  /// 2-Bosqich: Ro'yxatdan o'tish (ism va parol)
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.agree_terms_error'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        fullName: _nameController.text.trim(),
        phone: _formattedPhone,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
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
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            if (mounted) {
              context.goNamed(RouteNames.main);
            }
          } else if (state is AuthUserExists) {
            // 409 Conflict - Foydalanuvchi allaqachon mavjud
            // Bu Sellerlar o'zlarining mavjud raqamlari bilan Xaridor ilovasiga kirishlari uchun muhim
            if (mounted) {
              _showUserExistsDialog(context, state.phone);
            }
          } else if (state is AuthUnauthenticated && _currentStep == 1) {
            // OTP yuborildi - VerifyCodeScreen ga o'tish
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerifyCodeScreen(
                  phone: _formattedPhone,
                  isRegistration: true,
                  onVerified: () {
                    // OTP tasdiqlanganda 2-bosqichga o'tish
                    if (mounted) {
                      context.pop();
                      setState(() {
                        _currentStep = 2;
                      });
                    }
                  },
                ),
              ),
            );
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
                        if (_currentStep == 1) {
                          _handleSendOtp();
                        } else {
                          _handleRegister();
                        }
                      },
                      child: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              );
            } else {
              String errorMessage = state.message;
              if (state.message ==
                  'Bu telefon raqami allaqachon ro\'yxatdan o\'tgan') {
                errorMessage = 'auth.phone_already_registered'.tr();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
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
                child: _currentStep == 1
                    ? _buildStep1()
                    : _buildStep2(isLoading),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 1-Bosqich: Telefon raqami
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // Progress indicator
        _buildProgressIndicator(1),
        const SizedBox(height: 30),
        // Sarlavha
        Text(
          'auth.create_account'.tr(),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn().slideX(begin: -0.1),
        const SizedBox(height: 10),
        Text(
          'auth.create_account_subtitle'.tr(),
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
        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
        const SizedBox(height: 40),
        // Davom etish tugmasi
        CustomButton(
          text: 'auth.get_code'.tr(),
          width: double.infinity,
          isLoading: context.read<AuthBloc>().state is AuthLoading,
          onPressed: _handleSendOtp,
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
        const SizedBox(height: 30),
        // Kirish havolasi
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'auth.has_account'.tr(),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            GestureDetector(
              onTap: () {
                context.pushReplacementNamed(
                  RouteNames.login,
                  queryParameters: {'fromOnboarding': 'true'},
                );
              },
              child: Text(
                'auth.login'.tr(),
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
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 30),
      ],
    );
  }

  /// 2-Bosqich: Ism va Parol
  Widget _buildStep2(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // Progress indicator
        _buildProgressIndicator(2),
        const SizedBox(height: 30),
        // Sarlavha
        Text(
          'auth.your_info'.tr(),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn().slideX(begin: -0.1),
        const SizedBox(height: 10),
        Text(
          'auth.your_info_subtitle'.tr(args: [_formattedPhone]),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 36),
        // Ism
        _buildTextField(
          controller: _nameController,
          label: 'auth.full_name'.tr(),
          hint: 'auth.full_name_hint'.tr(),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'auth.enter_name'.tr();
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
            if (value!.length < 6) {
              return 'auth.password_too_short'.tr();
            }
            return null;
          },
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
        const SizedBox(height: 20),
        // Shartlarga rozilik
        GestureDetector(
          onTap: () {
            setState(() => _agreeTerms = !_agreeTerms);
          },
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _agreeTerms ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _agreeTerms
                        ? AppColors.primary
                        : AppColors.lightGrey,
                    width: 2,
                  ),
                ),
                child: _agreeTerms
                    ? const Icon(Icons.check, size: 16, color: AppColors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(text: 'auth.agree_terms_prefix'.tr()),
                      TextSpan(
                        text: 'auth.terms_of_use'.tr(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                      TextSpan(text: 'auth.agree_terms_suffix'.tr()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 30),
        // Ro'yxatdan o'tish tugmasi
        CustomButton(
          text: 'auth.signup'.tr(),
          width: double.infinity,
          isLoading: isLoading,
          onPressed: _handleRegister,
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
        const SizedBox(height: 30),
      ],
    );
  }

  /// Progress indicator
  Widget _buildProgressIndicator(int step) {
    return Row(
      children: [
        _buildStepDot(1, step >= 1),
        Expanded(
          child: Container(
            height: 2,
            color: step >= 2 ? AppColors.primary : AppColors.lightGrey,
          ),
        ),
        _buildStepDot(2, step >= 2),
      ],
    );
  }

  Widget _buildStepDot(int stepNumber, bool isActive) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.lightGrey,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$stepNumber',
          style: TextStyle(
            color: isActive ? AppColors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Telefon raqami uchun maxsus input
  Widget _buildPhoneField({
    required TextEditingController controller,
    required String label,
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
}
