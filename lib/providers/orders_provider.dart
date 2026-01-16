import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../data/models/order_model.dart';
import '../data/models/product_model.dart';
import '../core/services/api_service.dart';

/// Buyurtmalar provideri
class OrdersProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Log helper
  void _log(String message) {
    developer.log(message, name: 'ORDERS');
    // ignore: avoid_print
    print('🛒 [ORDERS] $message');
  }

  /// Buyurtmalar ro'yxati
  List<OrderModel> get orders => List.unmodifiable(_orders);

  /// Yuklanmoqdami?
  bool get isLoading => _isLoading;

  /// Xatolik xabari
  String? get errorMessage => _errorMessage;

  /// Buyurtmalar soni
  int get ordersCount => _orders.length;

  /// Xatolikni tozalash
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Yangi buyurtma yaratish (Backend API)
  Future<OrderModel?> createOrder({
    required String shopId, // Do'kon ID (majburiy)
    required ProductModel product,
    required int quantity,
    String? selectedColor,
    required String customerName,
    required String customerPhone,
    required String deliveryAddress,
    String? clientNote,
  }) async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('🛒 Creating order...');
    _log('Shop ID: $shopId');
    _log('Product ID: ${product.id}');
    _log('Quantity: $quantity');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Backend API ga so'rov yuborish
      final response = await _apiService.createOrder(
        shopId: shopId,
        clientName: customerName,
        clientPhone: customerPhone,
        clientAddress: deliveryAddress,
        clientNote: clientNote,
        items: [
          {
            'product_id': product.id,
            'quantity': quantity,
          },
        ],
      );

      _isLoading = false;

      if (response.success) {
        _log('✅ Order created successfully');
        
        // Backend order_id qaytaradi, lekin to'liq order ma'lumotlari yo'q
        // Shuning uchun lokal OrderModel yaratamiz
        final newOrder = OrderModel(
          id: response.order?['id']?.toString() ?? 
              response.order?['order_id']?.toString() ?? 
              'order_${DateTime.now().millisecondsSinceEpoch}',
          shopId: shopId,
          productId: product.id,
          productName: product.name,
          productImage: product.imageUrl,
          totalPrice: product.actualPrice * quantity,
          status: OrderStatus.newOrder,
          date: DateTime.now(),
          selectedColor: selectedColor,
          customerName: customerName,
          customerPhone: customerPhone,
          deliveryAddress: deliveryAddress,
          clientNote: clientNote,
          itemsCount: quantity,
        );

        _orders.insert(0, newOrder);
        notifyListeners();
        return newOrder;
      } else {
        _errorMessage = response.message;
        _log('❌ Order creation failed: $_errorMessage');
        notifyListeners();
        return null;
      }
    } catch (e, stackTrace) {
      _log('❌ Exception: $e');
      _log('❌ StackTrace: $stackTrace');
      _isLoading = false;
      _errorMessage = 'Xatolik yuz berdi: $e';
      notifyListeners();
      return null;
    }
  }

  /// Buyurtma holatini yangilash (Lokal - backend API yo'q)
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  /// Buyurtmani bekor qilish (Lokal)
  Future<void> cancelOrder(String orderId) async {
    _orders.removeWhere((o) => o.id == orderId);
    notifyListeners();
  }

  /// Buyurtmalarni tozalash (Chiqishda)
  void clearOrders() {
    _orders.clear();
    _errorMessage = null;
    notifyListeners();
  }

  /// Provider ni reset qilish
  void reset() {
    _orders.clear();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
