import 'package:dio/dio.dart';
import '../../../../core/di/dependency_injection.dart' as di;
import '../../../../data/models/order_model.dart';

/// Buyurtmalar bilan ishlash uchun repository
class OrderRepository {
  final Dio _dio;

  OrderRepository() : _dio = di.sl<Dio>();

  /// Yangi buyurtma yaratish
  Future<OrderModel> createOrder({
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    required double latitude,
    required double longitude,
    required String paymentMethod,
    String? notes,
    required String customerName,
    required String customerPhone,
  }) async {
    try {
      final response = await _dio.post(
        '/orders',
        data: {
          'items': items
              .map(
                (item) => {
                  'product_id': item['product_id'],
                  'quantity': item['quantity'],
                  'price': item['product']['price'],
                  'product_name': item['product']['name'],
                  'product_image': item['product']['image_url'],
                },
              )
              .toList(),
          'delivery_address': deliveryAddress,
          'latitude': latitude,
          'longitude': longitude,
          'payment_method': paymentMethod,
          'notes': notes,
          'status': 'new',
          'client_name': customerName,
          'client_phone': customerPhone,
          'total_amount': items.fold<double>(
            0,
            (sum, item) => sum + (item['product']['price'] * item['quantity']),
          ),
          'items_count': items.length,
        },
      );

      if (response.statusCode == 201) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw Exception('Buyurtma yaratishda xatolik: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Noma\'lum xatolik';
        throw Exception('Server xatosi: $errorMessage');
      } else {
        throw Exception('Internet aloqasini tekshiring');
      }
    } catch (e) {
      throw Exception('Buyurtma yaratishda xatolik: ${e.toString()}');
    }
  }

  /// Foydalanuvchi buyurtmalarini olish
  Future<List<OrderModel>> getUserOrders() async {
    try {
      final response = await _dio.get('/orders');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((order) => OrderModel.fromJson(order)).toList();
      } else {
        throw Exception(
          'Buyurtmalarni olishda xatolik: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Noma\'lum xatolik';
        throw Exception('Server xatosi: $errorMessage');
      } else {
        throw Exception('Internet aloqasini tekshiring');
      }
    } catch (e) {
      throw Exception('Buyurtmalarni olishda xatolik: ${e.toString()}');
    }
  }

  /// Buyurtma ma'lumotlarini olish
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId');

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Buyurtma ma\'lumotlarini olishda xatolik: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Noma\'lum xatolik';
        throw Exception('Server xatosi: $errorMessage');
      } else {
        throw Exception('Internet aloqasini tekshiring');
      }
    } catch (e) {
      throw Exception(
        'Buyurtma ma\'lumotlarini olishda xatolik: ${e.toString()}',
      );
    }
  }

  /// Buyurtma statusini yangilash
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _dio.patch(
        '/orders/$orderId',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Buyurtma statusini yangilashda xatolik: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Noma\'lum xatolik';
        throw Exception('Server xatosi: $errorMessage');
      } else {
        throw Exception('Internet aloqasini tekshiring');
      }
    } catch (e) {
      throw Exception(
        'Buyurtma statusini yangilashda xatolik: ${e.toString()}',
      );
    }
  }

  /// Buyurtmani bekor qilish
  Future<bool> cancelOrder(String orderId, String? reason) async {
    try {
      final response = await _dio.patch(
        '/orders/$orderId/cancel',
        data: {'reason': reason},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Buyurtmani bekor qilishda xatolik: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Noma\'lum xatolik';
        throw Exception('Server xatosi: $errorMessage');
      } else {
        throw Exception('Internet aloqasini tekshiring');
      }
    } catch (e) {
      throw Exception('Buyurtmani bekor qilishda xatolik: ${e.toString()}');
    }
  }
}
