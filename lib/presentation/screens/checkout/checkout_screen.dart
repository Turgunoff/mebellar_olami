import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/orders_provider.dart';
import '../../widgets/custom_button.dart';

/// Buyurtma berish ekrani - Nabolen Style
class CheckoutScreen extends StatefulWidget {
  final ProductModel product;
  final String? selectedColor;
  final int quantity;

  const CheckoutScreen({
    super.key,
    required this.product,
    this.selectedColor,
    this.quantity = 1,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  double get _totalPrice => widget.product.price * widget.quantity;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _nameController.text = authProvider.userName ?? '';
    _phoneController.text = authProvider.userPhone ?? '';
    _addressController.text = authProvider.userAddress ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final ordersProvider = context.read<OrdersProvider>();

      // Shop ID ni olish (product dan yoki default)
      // Eslatma: Backend hozircha shop_id ni product response da qaytarmaydi
      // Shuning uchun vaqtincha hardcoded yoki product dan olish kerak
      // Kelajakda backend shop_id ni qaytarishi kerak
      final shopId = widget.product.shopId ?? 
                     '00000000-0000-0000-0000-000000000000'; // Default shop ID

      if (shopId.isEmpty || shopId == '00000000-0000-0000-0000-000000000000') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mahsulot do\'koni topilmadi. Iltimos, keyinroq urinib ko\'ring.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final order = await ordersProvider.createOrder(
        shopId: shopId,
        product: widget.product,
        quantity: widget.quantity,
        selectedColor: widget.selectedColor,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        deliveryAddress: _addressController.text.trim(),
        clientNote: null, // Kelajakda note field qo'shish mumkin
      );

      if (mounted) {
        if (order != null) {
          _showSuccessDialog();
        } else {
          final errorMsg = ordersProvider.errorMessage ?? 'Buyurtma yaratishda xatolik yuz berdi';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik yuz berdi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius + 4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Muvaffaqiyat ikoni
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 56,
                ),
              )
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.elasticOut)
                  .then()
                  .shimmer(duration: 1000.ms),
              const SizedBox(height: 28),
              // Sarlavha
              const Text(
                'Buyurtma qabul qilindi!',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 14),
              // Xabar
              const Text(
                'Tez orada operatorlarimiz\nsiz bilan bog\'lanishadi',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 32),
              // Asosiy sahifaga qaytish
              CustomButton(
                text: 'Asosiy sahifa',
                width: double.infinity,
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            ],
          ),
        ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buyurtma berish'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mahsulot kartasi
              _buildProductCard().animate().fadeIn().slideY(begin: -0.1),
              const SizedBox(height: 28),
              // Yetkazib berish ma'lumotlari
              const Text(
                'Yetkazib berish ma\'lumotlari',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 18),
              // Ism
              _buildTextField(
                controller: _nameController,
                label: 'Ism familiya',
                hint: 'Ismingizni kiriting',
                icon: Icons.person_outline_rounded,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Ismni kiriting';
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.1),
              const SizedBox(height: 18),
              // Telefon
              _buildTextField(
                controller: _phoneController,
                label: 'Telefon raqam',
                hint: '+998 90 123 45 67',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Telefon raqamni kiriting';
                  }
                  if (value!.length < 9) {
                    return 'Telefon raqam noto\'g\'ri';
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
              const SizedBox(height: 18),
              // Manzil
              _buildTextField(
                controller: _addressController,
                label: 'Yetkazib berish manzili',
                hint: 'Shahar, tuman, ko\'cha, uy',
                icon: Icons.location_on_outlined,
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Manzilni kiriting';
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.1),
              const SizedBox(height: 28),
              // To'lov ma'lumotlari
              _buildPaymentInfo().animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      // Tasdiqlash tugmasi
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Jami summa
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jami to\'lov:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _totalPrice.toCurrency(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${widget.quantity} dona',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Tasdiqlash tugmasi
              CustomButton(
                text: 'Buyurtmani tasdiqlash',
                icon: Icons.check_circle_outline_rounded,
                width: double.infinity,
                height: 58,
                isLoading: _isLoading,
                onPressed: _submitOrder,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mahsulot kartasi
  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rasm
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: widget.product.imageUrl,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 90,
                height: 90,
                color: AppColors.secondary,
              ),
              errorWidget: (context, url, error) => Container(
                width: 90,
                height: 90,
                color: AppColors.secondary,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Ma'lumotlar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.category,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Rang
                    if (widget.selectedColor != null) ...[
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: widget.selectedColor!.toColor(),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.lightGrey,
                            width: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      widget.product.price.toCurrency(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Matn kiritish maydoni
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
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
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              borderSide: const BorderSide(color: AppColors.lightGrey),
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

  /// To'lov ma'lumotlari
  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(
          color: AppColors.secondary,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To\'lov usuli',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Yetkazib berilganda naqd pul',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
