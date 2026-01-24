import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// Project imports
import '../../../../core/utils/localized_text_helper.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/route_names.dart';
import '../bloc/product_detail_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/widgets/login_dialog.dart';
import '../../data/models/product_model.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;
  late PageController _imagePageController;

  // --- LOCALIZATION MAPS ---

  // Xususiyat nomlari (Keys)
  final Map<String, String> _specKeys = {
    'bed_size': "O'lchami",
    'dimensions': "O'lchamlari",
    'material': "Material",
    'color': "Rangi",
    'warranty': "Kafolat",
    'manufacturer': "Ishlab chiqaruvchi",
    'storage': "Saqlash qutisi",
    'lift_mechanism': "Ko'tarish mexanizmi",
    'mattress_included': "Matras qo'shilgan",
    'headboard': "Bosh qismi",
    'headboard_type': "Bosh qismi turi",
    'mirror': "Ko'zgu",
    'door_type': "Eshik turi",
    'doors_count': "Eshiklar soni",
    'hanging_rail': "Kiyim ilgich",
  };

  // Xususiyat qiymatlari (Values)
  final Map<String, String> _specValues = {
    'mdf': "MDF",
    'dsp': "DSP",
    'lmdf': "LMDF",
    'ldsp': "LDSP",
    'wood': "Yog'och",
    'metal': "Metall",
    'sliding': "Kupe (Sirpanchiq)",
    'hinged': "Ochiladigan",
    'soft': "Yumshoq",
    'hard': "Qattiq",
    '2_years': "2 yil",
    '3_years': "3 yil",
    '1_year': "1 yil",
    'brown': "Jigarrang",
    'purple': "Binafsha",
    'white': "Oq",
    'black': "Qora",
    'red': "Qizil",
    'blue': "Ko'k",
    'green': "Yashil",
    'yellow': "Sariq",
    'orange': "To'q sariq",
    'gray': "Kulrang",
    'beige': "Bej",
    'pink': "Pushti",
  };

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductDetailBloc>().add(
        LoadProductDetails(widget.productId),
      );
    });
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  // --- HELPER METHODS ---

  // Xususiyat nomini tarjima qilish
  String _getLocalizedKey(String key) {
    return _specKeys[key.toLowerCase()] ??
        key.replaceAll('_', ' ').capitalize();
  }

  // Xususiyat qiymatini tozalash va tarjima qilish
  String _formatSpecValue(dynamic value) {
    if (value == null) return "—";

    // 1. Boolean logic
    if (value is bool) {
      return value ? "Mavjud" : "Mavjud emas";
    }

    String stringValue = value.toString();

    // 2. Agar "[[white, black], ...]" kabi buzuq list kelsa
    if (stringValue.startsWith('[') || stringValue.contains(',')) {
      // Barcha belgilarni tozalaymiz va so'zlarni ajratib olamiz
      final cleanString = stringValue.replaceAll(RegExp(r'[\[\]"]'), '');
      final items = cleanString.split(',');

      // Har bir so'zni tarjima qilamiz va unikal qilamiz
      final translatedItems = items
          .map((item) {
            final trimmed = item.trim().toLowerCase();
            return _specValues[trimmed] ?? item.trim().capitalize();
          })
          .toSet()
          .toList(); // toSet dublikatlarni o'chiradi

      return translatedItems.join(', ');
    }

    // 3. Oddiy string qiymatni tarjima qilish
    return _specValues[stringValue.toLowerCase()] ?? stringValue;
  }

  // Ikonkalarni aniqlash
  IconData _getSpecIcon(String key) {
    switch (key.toLowerCase()) {
      case 'bed_size':
      case 'dimensions':
        return Icons.straighten;
      case 'material':
        return Icons.layers;
      case 'color':
        return Icons.palette;
      case 'warranty':
        return Icons.verified_user;
      case 'storage':
        return Icons.inventory_2;
      case 'mirror':
        return Icons.wb_sunny; // Mirror icon substitute
      case 'door_type':
      case 'doors_count':
        return Icons.sensor_door;
      case 'lift_mechanism':
        return Icons.keyboard_double_arrow_up;
      case 'headboard':
      case 'headboard_type':
        return Icons.bedroom_parent;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailBloc, ProductDetailState>(
      builder: (context, state) {
        if (state is ProductDetailLoading) return _buildLoadingState();
        if (state is ProductDetailError) return _buildErrorState(state.message);
        if (state is ProductDetailLoaded) return _buildContent(state.product);
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(ProductModel product) {
    final size = MediaQuery.of(context).size;
    final hasImages = (product.images as List?)?.isNotEmpty ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 1. Rasm (Sliver App Bar)
          SliverAppBar(
            expandedHeight: size.height * 0.45,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Center(
              child: _buildGlassButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => context.pop(),
              ),
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildGlassButton(
                    icon: Icons.favorite_border_rounded,
                    onTap: () {}, // Favorite logic
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImages)
                    PageView.builder(
                      controller: _imagePageController,
                      itemCount: product.images.length,
                      onPageChanged: (idx) =>
                          setState(() => _currentImageIndex = idx),
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: product.imageUrls[index],
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              const Center(child: Icon(Icons.broken_image)),
                        );
                      },
                    )
                  else
                    Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 64),
                    ),

                  // Image Indicator
                  if (product.images.length > 1)
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          product.images.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentImageIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? AppColors.primary
                                  : Colors.white54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 2. Asosiy Ma'lumotlar
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Kategoriya & Rating
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.isNew ? "Yangi" : "Mashhur",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${product.rating}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          " (12 sharh)",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Sarlavha
                    Text(
                      LocalizedTextHelper.get(product.name, context),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Narx
                    _buildPriceSection(product),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),

                    // Tavsif
                    const Text(
                      "Tavsif",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      LocalizedTextHelper.get(product.description, context),
                      style: TextStyle(color: Colors.grey[700], height: 1.5),
                    ),

                    const SizedBox(height: 24),

                    // Xususiyatlar (Dynamic Specs)
                    if (product.specs.isNotEmpty) ...[
                      const Text(
                        "Xususiyatlar",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDynamicSpecs(product.specs),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(product),
    );
  }

  Widget _buildPriceSection(ProductModel product) {
    final currencyFormat = NumberFormat.currency(
      locale: 'uz_UZ',
      symbol: "so'm",
      decimalDigits: 0,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          currencyFormat.format(
            product.price,
          ), // Aslida bu yerda actualPrice logikasini ishlatish kerak
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        if (product.discountPrice != null) ...[
          // Chegirma bor bo'lsa
          const SizedBox(width: 10),
          Text(
            currencyFormat.format(product.price * 1.2), // Mock eski narx
            style: const TextStyle(
              fontSize: 16,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDynamicSpecs(Map<String, dynamic> specs) {
    // Agar 'color' specs ichida bo'lsa, uni alohida chiroyli qilib chiqaramiz
    List<Widget> specWidgets = [];

    // 1. Ranglar (Agar ro'yxat bo'lsa)
    if (specs.containsKey('color')) {
      final colorValue = specs['color'];
      // Ranglarni ajratib olamiz
      String rawColors = colorValue.toString().replaceAll(
        RegExp(r'[\[\]"]'),
        '',
      );
      List<String> colors = rawColors
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toList();

      if (colors.isNotEmpty) {
        specWidgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mavjud ranglar",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: colors
                    .map((colorName) => _buildColorChip(colorName))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    }

    // 2. Qolgan xususiyatlar Grid ko'rinishida
    final otherSpecs = Map<String, dynamic>.from(specs)..remove('color');

    if (otherSpecs.isNotEmpty) {
      specWidgets.add(
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3, // Yupqaroq kartochkalar
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: otherSpecs.length,
          itemBuilder: (context, index) {
            String key = otherSpecs.keys.elementAt(index);
            dynamic value = otherSpecs[key];

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    _getSpecIcon(key),
                    size: 20,
                    color: AppColors.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getLocalizedKey(key),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatSpecValue(value),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: specWidgets,
    );
  }

  Widget _buildColorChip(String colorName) {
    // Rang nomiga qarab Color obyektini topishga harakat qilamiz
    Color? color;
    switch (colorName) {
      case 'white':
        color = Colors.white;
        break;
      case 'black':
        color = Colors.black;
        break;
      case 'brown':
        color = const Color(0xFF795548);
        break;
      case 'red':
        color = Colors.red;
        break;
      case 'blue':
        color = Colors.blue;
        break;
      case 'green':
        color = Colors.green;
        break;
      case 'yellow':
        color = Colors.yellow;
        break;
      case 'purple':
        color = Colors.purple;
        break;
      case 'gray':
        color = Colors.grey;
        break;
      case 'beige':
        color = const Color(0xFFF5F5DC);
        break;
      case 'pink':
        color = Colors.pink;
        break;
    }

    // Agar rangni tanib olsak, doira chizamiz
    if (color != null) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
          ],
        ),
      );
    }

    // Agar rang noma'lum bo'lsa (masalan "mdf"), text chip chiqaramiz
    return Chip(
      label: Text(_specValues[colorName] ?? colorName.capitalize()),
      backgroundColor: Colors.grey[100],
      labelStyle: const TextStyle(fontSize: 12),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildBottomBar(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            final isInCart = state.cartItems.any(
              (item) => item['product_id'] == product.id,
            );

            return SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (isInCart) {
                    context.pushNamed(RouteNames.cart);
                  } else {
                    final isGuest =
                        context.read<AuthBloc>().state is! AuthAuthenticated;

                    if (isGuest) {
                      showDialog(
                        context: context,
                        builder: (context) => const LoginDialog(
                          message: 'Sotib olish uchun tizimga kiring',
                        ),
                      );
                      return;
                    }

                    context.read<CartBloc>().add(
                      AddToCart(product: product.toJson(), quantity: 1),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInCart ? Colors.green : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isInCart
                          ? Icons.check_circle_outline
                          : Icons.shopping_bag_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isInCart ? "Savatda bor" : "Savatga qo'shish",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.black87),
          ),
        ),
      ),
    );
  }

  // Loading va Error statelarini oldingi koddan olishingiz mumkin...
  Widget _buildLoadingState() =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
  Widget _buildErrorState(String msg) =>
      Scaffold(body: Center(child: Text(msg)));
}
