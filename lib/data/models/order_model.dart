/// Buyurtma holati
enum OrderStatus {
  newOrder('Yangi'),
  processing('Jarayonda'),
  delivered('Yetkazildi');

  final String label;
  const OrderStatus(this.label);
}

/// Buyurtma modeli
class OrderModel {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double totalPrice;
  final OrderStatus status;
  final DateTime date;
  final String? selectedColor;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;

  const OrderModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.totalPrice,
    required this.status,
    required this.date,
    this.selectedColor,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
  });

  /// JSON dan model yaratish
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String,
      totalPrice: (json['total_price'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.newOrder,
      ),
      date: DateTime.parse(json['date'] as String),
      selectedColor: json['selected_color'] as String?,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      deliveryAddress: json['delivery_address'] as String,
    );
  }

  /// Modelni JSON ga aylantirish
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'total_price': totalPrice,
      'status': status.name,
      'date': date.toIso8601String(),
      'selected_color': selectedColor,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'delivery_address': deliveryAddress,
    };
  }

  /// Nusxa olish (copyWith)
  OrderModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    double? totalPrice,
    OrderStatus? status,
    DateTime? date,
    String? selectedColor,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
  }) {
    return OrderModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      date: date ?? this.date,
      selectedColor: selectedColor ?? this.selectedColor,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    );
  }
}
