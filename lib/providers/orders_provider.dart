import 'package:flutter/foundation.dart';
import '../data/models/order_model.dart';
import '../data/models/product_model.dart';
import '../data/mock/mock_data.dart';

/// Buyurtmalar provideri
class OrdersProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  /// Buyurtmalar ro'yxati
  List<OrderModel> get orders => List.unmodifiable(_orders);

  /// Yuklanmoqdami?
  bool get isLoading => _isLoading;

  /// Buyurtmalar soni
  int get ordersCount => _orders.length;

  /// Buyurtmalarni yuklash (Mock)
  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    // Mock delay
    await Future.delayed(const Duration(milliseconds: 500));

    _orders = List.from(MockData.sampleOrders);

    _isLoading = false;
    notifyListeners();
  }

  /// Yangi buyurtma yaratish
  Future<OrderModel> createOrder({
    required ProductModel product,
    required String selectedColor,
    required String customerName,
    required String customerPhone,
    required String deliveryAddress,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Mock delay - backend simulyatsiyasi
    await Future.delayed(const Duration(seconds: 1));

    final newOrder = OrderModel(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      productId: product.id,
      productName: product.name,
      productImage: product.imageUrl,
      totalPrice: product.price,
      status: OrderStatus.newOrder,
      date: DateTime.now(),
      selectedColor: selectedColor,
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryAddress: deliveryAddress,
    );

    _orders.insert(0, newOrder);

    _isLoading = false;
    notifyListeners();

    return newOrder;
  }

  /// Buyurtma holatini yangilash (Mock - kelajakda backend)
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  /// Buyurtmani bekor qilish
  Future<void> cancelOrder(String orderId) async {
    _orders.removeWhere((o) => o.id == orderId);
    notifyListeners();
  }

  /// Buyurtmalarni tozalash (Chiqishda)
  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
