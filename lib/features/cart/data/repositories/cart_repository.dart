import '../../../../core/local/hive_service.dart';

class CartRepository {
  /// Savatchaga mahsulot qo'shish
  Future<Map<String, dynamic>> addToCart(
    Map<String, dynamic> product,
    int quantity,
  ) async {
    try {
      final cartItems = _getCartItems();
      final productId = product['id']?.toString() ?? '';

      // Mahsulot allaqachon savatchada borligini tekshirish
      final existingIndex = cartItems.indexWhere(
        (item) => item['product_id']?.toString() == productId,
      );

      List<Map<String, dynamic>> updatedCart;

      if (existingIndex != -1) {
        // Mahsulot bor bo'lsa, sonini oshirish
        final existingItem = cartItems[existingIndex];
        final currentQuantity = existingItem['quantity'] as int? ?? 0;
        updatedCart = List.from(cartItems);
        updatedCart[existingIndex] = {
          ...existingItem,
          'quantity': currentQuantity + quantity,
          'updated_at': DateTime.now().toIso8601String(),
        };
      } else {
        // Yangi mahsulot qo'shish
        updatedCart = List.from(cartItems)
          ..add({
            'product_id': productId,
            'product': product,
            'quantity': quantity,
            'added_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
      }

      await _saveCartItems(updatedCart);

      return {
        'success': true,
        'message': existingIndex != -1
            ? 'Mahsulot soni oshirildi'
            : 'Savatchaga qo\'shildi',
        'cart_items': updatedCart,
      };
    } catch (e) {
      return {'success': false, 'message': 'Xatolik: ${e.toString()}'};
    }
  }

  /// Savatchadan mahsulot o'chirish
  Future<Map<String, dynamic>> removeFromCart(String productId) async {
    try {
      final cartItems = _getCartItems();
      final updatedCart = cartItems
          .where((item) => item['product_id']?.toString() != productId)
          .toList();

      await _saveCartItems(updatedCart);

      return {
        'success': true,
        'message': 'Savatchadan o\'chirildi',
        'cart_items': updatedCart,
      };
    } catch (e) {
      return {'success': false, 'message': 'Xatolik: ${e.toString()}'};
    }
  }

  /// Mahsulot sonini o'zgartirish
  Future<Map<String, dynamic>> updateQuantity(
    String productId,
    int newQuantity,
  ) async {
    try {
      if (newQuantity <= 0) {
        return await removeFromCart(productId);
      }

      final cartItems = _getCartItems();
      final existingIndex = cartItems.indexWhere(
        (item) => item['product_id']?.toString() == productId,
      );

      if (existingIndex == -1) {
        return {'success': false, 'message': 'Mahsulot savatchada topilmadi'};
      }

      final updatedCart = List<Map<String, dynamic>>.from(cartItems);
      updatedCart[existingIndex] = {
        ...updatedCart[existingIndex],
        'quantity': newQuantity,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _saveCartItems(updatedCart);

      return {
        'success': true,
        'message': 'Mahsulot soni o\'zgartirildi',
        'cart_items': updatedCart,
      };
    } catch (e) {
      return {'success': false, 'message': 'Xatolik: ${e.toString()}'};
    }
  }

  /// Savatchani tozalash
  Future<Map<String, dynamic>> clearCart() async {
    try {
      await HiveService.cartBox.clear();

      return {
        'success': true,
        'message': 'Savatcha tozalandi',
        'cart_items': [],
      };
    } catch (e) {
      return {'success': false, 'message': 'Xatolik: ${e.toString()}'};
    }
  }

  /// Savatchadagi mahsulotlarni olish
  List<Map<String, dynamic>> getCartItems() {
    return _getCartItems();
  }

  /// Savatchadagi mahsulotlar soni
  int get itemCount {
    final cartItems = _getCartItems();
    return cartItems.fold<int>(
      0,
      (sum, item) => sum + (item['quantity'] as int? ?? 0),
    );
  }

  /// Savatchaning jami summasi
  double getCartTotal() {
    final cartItems = _getCartItems();
    double total = 0.0;

    for (final item in cartItems) {
      final product = item['product'] as Map<String, dynamic>?;
      if (product != null) {
        final quantity = item['quantity'] as int? ?? 0;
        final price = _getProductPrice(product);
        total += price * quantity;
      }
    }

    return total;
  }

  /// Mahsulot savatchada borligini tekshirish
  bool isInCart(String productId) {
    final cartItems = _getCartItems();
    return cartItems.any((item) => item['product_id']?.toString() == productId);
  }

  /// Mahsulotning savatchadagi sonini olish
  int getProductQuantity(String productId) {
    final cartItems = _getCartItems();
    final item = cartItems.firstWhere(
      (item) => item['product_id']?.toString() == productId,
      orElse: () => <String, dynamic>{},
    );
    return item['quantity'] as int? ?? 0;
  }

  // Private helper methods

  List<Map<String, dynamic>> _getCartItems() {
    try {
      final cartData = HiveService.cartBox.values.toList();
      return cartData
          .whereType<Map<String, dynamic>>()
          .cast<Map<String, dynamic>>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveCartItems(List<Map<String, dynamic>> items) async {
    try {
      await HiveService.cartBox.clear();
      for (int i = 0; i < items.length; i++) {
        await HiveService.cartBox.put(i, items[i]);
      }
    } catch (e) {
      // Xatolikni log qilish mumkin
      throw Exception('Savatchani saqlashda xatolik: ${e.toString()}');
    }
  }

  double _getProductPrice(Map<String, dynamic> product) {
    // Chegirma borligini tekshirish
    final hasDiscount = product['has_discount'] as bool? ?? false;

    if (hasDiscount && product['discount_price'] != null) {
      return (product['discount_price'] as num?)?.toDouble() ?? 0.0;
    }

    return (product['price'] as num?)?.toDouble() ?? 0.0;
  }

  /// Savatcha statistikasi
  Map<String, dynamic> getCartStats() {
    final cartItems = _getCartItems();
    final itemCount = cartItems.fold<int>(
      0,
      (sum, item) => sum + (item['quantity'] as int? ?? 0),
    );
    final totalAmount = getCartTotal();

    return {
      'item_count': itemCount,
      'total_amount': totalAmount,
      'unique_products': cartItems.length,
      'average_price': itemCount > 0 ? totalAmount / itemCount : 0.0,
    };
  }
}
