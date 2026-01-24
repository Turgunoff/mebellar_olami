import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../../../../core/utils/localized_text_helper.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/route_names.dart';
import '../../../products/data/models/product_model.dart';
import '../../../../core/widgets/custom_button.dart';
import '../bloc/checkout_bloc.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';

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
  Point? _selectedLocation;
  String _locationName = '';

  double get _totalPrice => widget.product.price * widget.quantity;

  @override
  void initState() {
    super.initState();
    // TODO: AuthProvider ni topib ma'lumotlarni olish
    // final authProvider = context.read<AuthProvider>();
    // _nameController.text = authProvider.userName ?? '';
    // _phoneController.text = authProvider.userPhone ?? '';
    // _addressController.text = authProvider.userAddress ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitOrder() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, manzilni xaritadan tanlang'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Mahsulotni cart formatiga aylantirish
    final cartItems = [
      {
        'product_id': widget.product.id,
        'product': {
          'id': widget.product.id,
          'name': widget.product.name,
          'price': widget.product.price,
          'image_url': widget.product.imageUrl,
        },
        'quantity': widget.quantity,
      },
    ];

    context.read<CheckoutBloc>().add(
      CreateOrder(
        items: cartItems,
        deliveryAddress: _addressController.text.trim(),
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        paymentMethod: 'cash',
        notes: widget.selectedColor != null
            ? 'Rang: ${widget.selectedColor}'
            : null,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
      ),
    );
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
                  context.goNamed(RouteNames.main);
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
    return BlocListener<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state is OrderCreatedSuccess) {
          // Clear cart if exists
          final cartBloc = context.read<CartBloc>();
          cartBloc.add(const ClearCart());

          _showSuccessDialog();
        } else if (state is CheckoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xatolik yuz berdi: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          final isLoading = state is CheckoutLoading;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Buyurtma berish'),
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                onPressed: () => context.pop(),
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
                    // Manzil tanlash tugmasi
                    _buildAddressSelector()
                        .animate()
                        .fadeIn(delay: 250.ms)
                        .slideX(begin: -0.1),
                    const SizedBox(height: 18),
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
                      isLoading: isLoading,
                      onPressed: _submitOrder,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
              placeholder: (context, url) =>
                  Container(width: 90, height: 90, color: AppColors.secondary),
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
                  LocalizedTextHelper.get(widget.product.category, context),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  LocalizedTextHelper.get(widget.product.name, context),
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

  /// Manzil tanlash widgeti
  Widget _buildAddressSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Yetkazib berish manzili',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _selectLocationFromMap,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              border: Border.all(
                color: _selectedLocation != null
                    ? AppColors.primary
                    : AppColors.lightGrey,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _selectedLocation != null
                          ? Icons.check_circle
                          : Icons.location_on_outlined,
                      color: _selectedLocation != null
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedLocation != null
                            ? 'Manzil tanlandi'
                            : 'Manzilni xaritadan tanlang',
                        style: TextStyle(
                          color: _selectedLocation != null
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                  ],
                ),
                if (_selectedLocation != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _locationName.isNotEmpty
                              ? _locationName
                              : 'Tanlangan manzil',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Koordinatalar: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Xaritadan manzil tanlash
  Future<void> _selectLocationFromMap() async {
    final result = await context.pushNamed<Map<String, dynamic>>(
      RouteNames.mapSelection,
    );

    if (result != null) {
      final location = result['location'] as Point;
      final name = result['name'] as String;

      setState(() {
        _selectedLocation = location;
        _locationName = name;
        _addressController.text = _locationName;
      });

      // BLoC ga manzil tanlanganligini xabar qilish
      context.read<CheckoutBloc>().add(SelectLocation(location, name));
    }
  }

  /// To'lov ma'lumotlari
  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: AppColors.secondary),
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
