import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/orders_provider.dart';
import '../../widgets/custom_button.dart';

/// Kirish ekrani
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login form controllers
  final _loginPhoneController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Register form controllers
  final _registerNameController = TextEditingController();
  final _registerPhoneController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginPhoneController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerPhoneController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        phone: _loginPhoneController.text.trim(),
        password: _loginPasswordController.text,
      );

      if (success && mounted) {
        // Buyurtmalarni yuklash
        context.read<OrdersProvider>().loadOrders();
        Navigator.pop(context);
        _showSuccessSnackBar('Tizimga muvaffaqiyatli kirdingiz!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Kirish muvaffaqiyatsiz');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.register(
        name: _registerNameController.text.trim(),
        phone: _registerPhoneController.text.trim(),
        password: _registerPasswordController.text,
      );

      if (success && mounted) {
        Navigator.pop(context);
        _showSuccessSnackBar('Ro\'yxatdan muvaffaqiyatli o\'tdingiz!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Ro\'yxatdan o\'tish muvaffaqiyatsiz');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: AppColors.primary),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent,
                          AppColors.accent.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.chair_alt_rounded,
                      color: AppColors.white,
                      size: 40,
                    ),
                  ).animate().scale(curve: Curves.elasticOut),
                  const SizedBox(height: 16),
                  const Text(
                    'Mebellar Olami',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 8),
                  const Text(
                    'Premium mebellar dunyosiga xush kelibsiz',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
                    ),
                  ).animate().fadeIn(delay: 150.ms),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.textGrey,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Kirish'),
                  Tab(text: 'Ro\'yxatdan o\'tish'),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLoginForm(),
                  _buildRegisterForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kirish formasi
  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            // Telefon
            _buildTextField(
              controller: _loginPhoneController,
              label: 'Telefon raqam',
              hint: '+998 90 123 45 67',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Telefon raqamni kiriting';
                }
                return null;
              },
            ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.1),
            const SizedBox(height: 16),
            // Parol
            _buildTextField(
              controller: _loginPasswordController,
              label: 'Parol',
              hint: '••••••••',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textGrey,
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Parolni kiriting';
                }
                return null;
              },
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
            const SizedBox(height: 12),
            // Parolni unutdingizmi?
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Parolni unutdingizmi?',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 24),
            // Kirish tugmasi
            CustomButton(
              text: 'Kirish',
              width: double.infinity,
              isLoading: _isLoading,
              onPressed: _handleLogin,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Ro'yxatdan o'tish formasi
  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          children: [
            // Ism
            _buildTextField(
              controller: _registerNameController,
              label: 'Ism familiya',
              hint: 'Ismingizni kiriting',
              icon: Icons.person_outline,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Ismni kiriting';
                }
                return null;
              },
            ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.1),
            const SizedBox(height: 16),
            // Telefon
            _buildTextField(
              controller: _registerPhoneController,
              label: 'Telefon raqam',
              hint: '+998 90 123 45 67',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Telefon raqamni kiriting';
                }
                return null;
              },
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
            const SizedBox(height: 16),
            // Parol
            _buildTextField(
              controller: _registerPasswordController,
              label: 'Parol',
              hint: '••••••••',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textGrey,
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
            ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.1),
            const SizedBox(height: 24),
            // Ro'yxatdan o'tish tugmasi
            CustomButton(
              text: 'Ro\'yxatdan o\'tish',
              width: double.infinity,
              isLoading: _isLoading,
              onPressed: _handleRegister,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 16),
            // Shartlar
            Text(
              'Ro\'yxatdan o\'tish orqali siz foydalanish\nshartlarimizga rozilik bildirasiz',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 450.ms),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Matn kiritish maydoni
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
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
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textGrey),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
