import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/widgets/custom_button.dart';

/// Kodni tasdiqlash ekrani - Nabolen Style
/// 5 xonali OTP kiritish
class VerifyCodeScreen extends StatefulWidget {
  final String phone;
  final bool isRegistration;
  final bool isPasswordReset;
  final VoidCallback? onVerified;

  const VerifyCodeScreen({
    super.key,
    required this.phone,
    this.isRegistration = false,
    this.isPasswordReset = false,
    this.onVerified,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  // 5 xonali kod uchun controllerlar
  final List<TextEditingController> _controllers = List.generate(
    5,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(5, (index) => FocusNode());

  int _resendSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    // Har bir controller uchun listener qo'shish
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() => _onTextChanged(i));
    }
  }

  void _onTextChanged(int index) {
    setState(() {}); // UI yangilash
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

    if (widget.isPasswordReset) {
      context.read<AuthBloc>().add(
        AuthForgotPasswordRequested(phone: widget.phone),
      );
    } else {
      context.read<AuthBloc>().add(AuthSendOtpRequested(phone: widget.phone));
    }
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

  /// 5 xonali kodni olish
  String get _code => _controllers.map((c) => c.text).join();

  /// Barcha inputlarni tozalash
  void _clearAll() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _verifyCode() async {
    if (_code.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, to\'liq 5 xonali kodni kiriting'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthVerifyOtpRequested(phone: widget.phone, code: _code),
    );
  }

  /// Backspace bosilganda
  void _handleBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      // Bo'sh bo'lsa, oldingi inputga o'tish
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    } else {
      // O'zini tozalash
      _controllers[index].clear();
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
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return SafeArea(
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
                    'Biz ${widget.phone} ga yuborgan\n5 xonali kodni kiriting',
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
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Kodni backend konsoldan ko\'ring',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 150.ms),
                  const SizedBox(height: 40),
                  // 5 ta OTP input
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
                                event.logicalKey ==
                                    LogicalKeyboardKey.backspace) {
                              _handleBackspace(index);
                            }
                          },
                          child: TextFormField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
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
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: AppColors.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.lightGrey,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.lightGrey,
                                ),
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
                                _focusNodes[index + 1].requestFocus();
                              }
                              // Auto-submit when all 5 digits entered
                              if (_code.length == 5) {
                                _verifyCode();
                              }
                            },
                          ),
                        ),
                      ).animate().fadeIn(delay: (200 + index * 50).ms).scale(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tozalash tugmasi
                  if (_code.isNotEmpty)
                    TextButton.icon(
                      onPressed: _clearAll,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Tozalash'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(),
                  const SizedBox(height: 10),
                  // Qayta yuborish
                  GestureDetector(
                    onTap: _canResend ? _resendCode : null,
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14),
                        children: [
                          TextSpan(
                            text: _canResend
                                ? 'Kodni qayta yuborish'
                                : 'Qayta yuborish ',
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
                  const Spacer(),
                  // Tasdiqlash tugmasi
                  CustomButton(
                    text: 'Tasdiqlash',
                    width: double.infinity,
                    isLoading: context.read<AuthBloc>().state is AuthLoading,
                    onPressed: _verifyCode,
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
