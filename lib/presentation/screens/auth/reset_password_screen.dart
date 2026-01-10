import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import 'login_screen.dart';

/// Parolni yangilash ekrani - Nabolen Style
/// 2 bosqich: OTP kiritish -> Yangi parol
class ResetPasswordScreen extends StatefulWidget {
  final String phone;

  const ResetPasswordScreen({super.key, required this.phone});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  // OTP controllerlari (5 xonali)
  final List<TextEditingController> _otpControllers = List.generate(
    5,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    5,
    (index) => FocusNode(),
  );

  // Parol controllerlari
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Qaysi bosqichda (1 = OTP, 2 = Password)
  int _currentStep = 1;

  // Parol talablari
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;

  // Resend timer
  int _resendSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
    _startResendTimer();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 6;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
    });
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _resendSeconds--;
        if (_resendSeconds <= 0) {
          _canResend = true;
        }
      });
      return _resendSeconds > 0;
    });
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.forgotPassword(widget.phone);

    if (success && mounted) {
      setState(() {
        _resendSeconds = 60;
        _canResend = false;
      });
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yangi kod yuborildi'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 5 xonali OTP kodi
  String get _otpCode => _otpControllers.map((c) => c.text).join();

  /// Backspace bosilganda
  void _handleOtpBackspace(int index) {
    if (_otpControllers[index].text.isEmpty && index > 0) {
      // Bo'sh bo'lsa, oldingi inputga o'tish
      _otpFocusNodes[index - 1].requestFocus();
      _otpControllers[index - 1].clear();
    } else {
      // O'zini tozalash
      _otpControllers[index].clear();
    }
    setState(() {});
  }

  /// Barcha OTP inputlarni tozalash
  void _clearOtp() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _otpFocusNodes[0].requestFocus();
    setState(() {});
  }

  /// 1-Bosqich: OTP tekshirish
  void _handleVerifyOtp() {
    if (_otpCode.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, to\'liq 5 xonali kodni kiriting'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 2-bosqichga o'tish
    setState(() => _currentStep = 2);
  }

  /// 2-Bosqich: Yangi parolni saqlash
  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parollar mos kelmadi'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    final success = await authProvider.resetPassword(
      phone: widget.phone,
      code: _otpCode,
      newPassword: _passwordController.text,
    );

    if (success && mounted) {
      // Muvaffaqiyat ekraniga o'tish
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => _PasswordResetSuccessScreen()),
        (route) => false,
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
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: _currentStep == 1
                    ? _buildStep1OTP(authProvider)
                    : _buildStep2Password(authProvider),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 1-Bosqich: OTP kiritish
  Widget _buildStep1OTP(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        // Sarlavha
        const Text(
          'Kodni kiriting',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn().slideY(begin: -0.1),
        const SizedBox(height: 12),
        Text(
          '${widget.phone} ga yuborilgan\n5 xonali kodni kiriting',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 16),
        // Info banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Kodni backend konsoldan ko\'ring',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 40),
        // 5 xonali OTP input
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => Container(
              width: 56,
              height: 68,
              margin: EdgeInsets.only(left: index == 0 ? 0 : 8),
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.backspace) {
                    _handleOtpBackspace(index);
                  }
                },
                child: TextFormField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SF Pro Display',
                    letterSpacing: 0,
                    height: 1.2,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 4) {
                      _otpFocusNodes[index + 1].requestFocus();
                    }
                  },
                ),
              ),
            ).animate().fadeIn(delay: (200 + index * 50).ms).scale(),
          ),
        ),
        const SizedBox(height: 16),
        // Tozalash tugmasi
        if (_otpCode.isNotEmpty)
          TextButton.icon(
            onPressed: _clearOtp,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Tozalash'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ).animate().fadeIn(),
        const SizedBox(height: 30),
        // Qayta yuborish
        GestureDetector(
          onTap: _canResend ? _resendCode : null,
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14),
              children: [
                TextSpan(
                  text: _canResend ? 'Kodni qayta yuborish' : 'Qayta yuborish ',
                  style: TextStyle(
                    color: _canResend
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: _canResend
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (!_canResend)
                  TextSpan(
                    text: '(${_resendSeconds}s)',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 60),
        // Davom etish tugmasi
        CustomButton(
          text: 'Davom etish',
          width: double.infinity,
          isLoading: authProvider.isLoading,
          onPressed: _handleVerifyOtp,
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
        const SizedBox(height: 40),
      ],
    );
  }

  /// 2-Bosqich: Yangi parol
  Widget _buildStep2Password(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // Sarlavha
        const Text(
          'Yangi parol',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn().slideX(begin: -0.1),
        const SizedBox(height: 10),
        const Text(
          'Hisobingizni himoya qilish uchun\nkuchli va xavfsiz parol o\'rnating.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 40),
        // Yangi parol
        _buildTextField(
          controller: _passwordController,
          label: 'Yangi parol',
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
        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
        const SizedBox(height: 20),
        // Parolni tasdiqlash
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Parolni tasdiqlash',
          hint: '••••••••••••',
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              );
            },
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Parolni tasdiqlang';
            }
            return null;
          },
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
        const SizedBox(height: 24),
        // Parol talablari
        const Text(
          'Parolingiz quyidagilardan iborat bo\'lishi kerak:',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 14),
        _buildRequirement(
          'Kamida 6 ta belgi',
          _hasMinLength,
        ).animate().fadeIn(delay: 450.ms),
        _buildRequirement(
          'Kamida 1 ta katta harf (A-Z)',
          _hasUppercase,
        ).animate().fadeIn(delay: 500.ms),
        _buildRequirement(
          'Kamida 1 ta raqam (0-9)',
          _hasNumber,
        ).animate().fadeIn(delay: 550.ms),
        const SizedBox(height: 40),
        // Tasdiqlash tugmasi
        CustomButton(
          text: 'Parolni yangilash',
          width: double.infinity,
          isLoading: authProvider.isLoading,
          onPressed: _handleResetPassword,
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
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

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isMet ? AppColors.success : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isMet ? AppColors.success : AppColors.lightGrey,
                width: 2,
              ),
            ),
            child: isMet
                ? const Icon(Icons.check, size: 14, color: AppColors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isMet ? AppColors.success : AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Parol muvaffaqiyatli yangilandi ekrani
class _PasswordResetSuccessScreen extends StatelessWidget {
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
              const Text(
                'Parol yangilandi! 🎉',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 12),
              const Text(
                'Parolingiz muvaffaqiyatli o\'zgartirildi.\nEndi yangi parol bilan kirishingiz mumkin.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 500.ms),
              const Spacer(),
              // Kirish tugmasi
              CustomButton(
                text: 'Kirish',
                width: double.infinity,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const LoginScreen(isFromOnboarding: true),
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
