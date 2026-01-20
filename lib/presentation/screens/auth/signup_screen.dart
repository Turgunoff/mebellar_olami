import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../widgets/custom_button.dart';
import 'login_screen.dart';
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
        const SnackBar(
          content: Text('Telefon raqamini kiriting'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    final success = await authProvider.sendOtp(_formattedPhone);

    if (success && mounted) {
      // OTP yuborildi - VerifyCodeScreen ga o'tish
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyCodeScreen(
            phone: _formattedPhone,
            isRegistration: true,
            onVerified: () {
              // OTP tasdiqlanganda 2-bosqichga o'tish
              setState(() {
                _currentStep = 2;
              });
            },
          ),
        ),
      );
    } else if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// 2-Bosqich: Ro'yxatdan o'tish (ism va parol)
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, foydalanish shartlariga rozilik bildiring'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    final success = await authProvider.register(
      name: _nameController.text.trim(),
      phone: _formattedPhone,
      password: _passwordController.text,
    );

    if (success && mounted) {
      // Muvaffaqiyatli ro'yxatdan o'tish
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => _SuccessScreen(
            title: 'Tabriklaymiz! 🎉',
            subtitle: 'Siz muvaffaqiyatli ro\'yxatdan o\'tdingiz',
          ),
        ),
      );
    } else if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
              Navigator.pop(context);
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
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const _SuccessScreen(
                  title: 'Tabriklaymiz! 🎉',
                  subtitle: 'Siz muvaffaqiyatli ro\'yxatdan o\'tdingiz',
                ),
              ),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: _currentStep == 1
                        ? _buildStep1(authProvider)
                        : _buildStep2(authProvider, isLoading),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 1-Bosqich: Telefon raqami
  Widget _buildStep1(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // Progress indicator
        _buildProgressIndicator(1),
        const SizedBox(height: 30),
        // Sarlavha
        const Text(
          'Akkount yaratish',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn().slideX(begin: -0.1),
        const SizedBox(height: 10),
        const Text(
          'Telefon raqamingizni kiriting.\nBiz sizga tasdiqlash kodini yuboramiz.',
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
          label: 'Telefon raqami',
        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
        const SizedBox(height: 40),
        // Davom etish tugmasi
        CustomButton(
          text: 'Kod olish',
          width: double.infinity,
          isLoading: authProvider.isLoading,
          onPressed: _handleSendOtp,
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
        const SizedBox(height: 30),
        // Kirish havolasi
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Akkauntingiz bormi? ',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(isFromOnboarding: true),
                  ),
                );
              },
              child: const Text(
                'Kirish',
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
  Widget _buildStep2(AuthProvider authProvider, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // Progress indicator
        _buildProgressIndicator(2),
        const SizedBox(height: 30),
        // Sarlavha
        const Text(
          'Ma\'lumotlaringiz',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn().slideX(begin: -0.1),
        const SizedBox(height: 10),
        Text(
          'Ism va parolingizni kiriting.\nTelefon: $_formattedPhone ✓',
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
          label: 'To\'liq ismingiz',
          hint: 'Ismingizni kiriting',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Ismni kiriting';
            }
            return null;
          },
        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
        const SizedBox(height: 20),
        // Parol
        _buildTextField(
          controller: _passwordController,
          label: 'Parol',
          hint: '••••••••••••',
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
              return 'Parolni kiriting';
            }
            if (value!.length < 6) {
              return 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak';
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
                    color: _agreeTerms ? AppColors.primary : AppColors.lightGrey,
                    width: 2,
                  ),
                ),
                child: _agreeTerms
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.white,
                      )
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
                      const TextSpan(text: 'Men '),
                      TextSpan(
                        text: 'Foydalanish shartlari',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                      const TextSpan(text: 'ga roziman'),
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
          text: 'Ro\'yxatdan o\'tish',
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
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: '90 123 45 67',
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  Container(
                    width: 1,
                    height: 24,
                    color: AppColors.lightGrey,
                  ),
                ],
              ),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              fontSize: 15,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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

/// Muvaffaqiyat ekrani
class _SuccessScreen extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SuccessScreen({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 80,
                  color: AppColors.success,
                ),
              ).animate().scale(delay: 200.ms),
              const SizedBox(height: 32),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 500.ms),
              const Spacer(),
              // Davom etish tugmasi
              CustomButton(
                text: 'Davom etish',
                width: double.infinity,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(isFromOnboarding: true),
                    ),
                    (route) => false,
                  );
                },
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
