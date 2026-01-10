import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import 'success_screen.dart';

/// Kodni tasdiqlash ekrani - Nabolen Style
class VerifyCodeScreen extends StatefulWidget {
  final String email;
  final String? name;
  final String? password;
  final bool isPasswordReset;

  const VerifyCodeScreen({
    super.key,
    required this.email,
    this.name,
    this.password,
    this.isPasswordReset = false,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );
  bool _isLoading = false;
  int _resendSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
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

  void _resendCode() {
    if (!_canResend) return;
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

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verifyCode() async {
    if (_code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, to\'liq kodni kiriting'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);

      if (widget.isPasswordReset) {
        // Parolni tiklash
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              title: 'Tabriklaymiz!',
              subtitle: 'Parol muvaffaqiyatli o\'zgartirildi',
              isPasswordReset: true,
            ),
          ),
        );
      } else {
        // Ro'yxatdan o'tish
        final authProvider = context.read<AuthProvider>();
        await authProvider.register(
          name: widget.name ?? '',
          phone: widget.email,
          password: widget.password ?? '',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              title: 'Tabriklaymiz!',
              subtitle: 'Siz muvaffaqiyatli ro\'yxatdan o\'tdingiz',
            ),
          ),
        );
      }
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
          onPressed: () => Navigator.pop(context),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Sarlavha
              const Text(
                'Kodni tasdiqlang',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn().slideY(begin: -0.1),
              const SizedBox(height: 12),
              Text(
                'Biz ${widget.email} ga yuborgan\nkodni kiriting',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 50),
              // OTP inputlar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Container(
                    width: 64,
                    height: 64,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : 12,
                    ),
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.surface,
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
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  ).animate().fadeIn(delay: (200 + index * 50).ms).scale(),
                ),
              ),
              const SizedBox(height: 30),
              // Qayta yuborish
              GestureDetector(
                onTap: _canResend ? _resendCode : null,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: _canResend ? 'Kodni qayta yuborish' : 'Qayta yuborish ',
                        style: TextStyle(
                          color: _canResend ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: _canResend ? FontWeight.w600 : FontWeight.normal,
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
              const Spacer(),
              // Tasdiqlash tugmasi
              CustomButton(
                text: 'Tasdiqlash',
                width: double.infinity,
                isLoading: _isLoading,
                onPressed: _verifyCode,
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
