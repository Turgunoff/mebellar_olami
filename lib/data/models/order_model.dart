/// Buyurtma holati (Backend bilan mos)
enum OrderStatus {
  newOrder('new', 'Yangi'),
  confirmed('confirmed', 'Tasdiqlangan'),
  shipping('shipping', 'Yetkazilmoqda'),
  completed('completed', 'Yakunlangan'),
  cancelled('cancelled', 'Bekor qilingan');

  final String value; // Backend status qiymati
  final String label; // UI uchun o'zbekcha nom
  const OrderStatus(this.value, this.label);

  /// Backend status string dan OrderStatus ga o'tkazish
  static OrderStatus fromString(String? status) {
    if (status == null) return OrderStatus.newOrder;
    for (final s in OrderStatus.values) {
      if (s.value == status) return s;
    }
    return OrderStatus.newOrder;
  }
}

/// Buyurtma modeli (Backend bilan mos)
class OrderModel {
  final String id;
  final String shopId; // Backend: shop_id
  final String productId; // UI uchun (birinchi mahsulot)
  final String productName; // UI uchun (birinchi mahsulot)
  final String productImage; // UI uchun (birinchi mahsulot)
  final double totalPrice; // Backend: total_amount
  final double? deliveryPrice; // Backend: delivery_price
  final OrderStatus status;
  final DateTime date; // Backend: created_at
  final String? selectedColor; // UI uchun
  final String customerName; // Backend: client_name
  final String customerPhone; // Backend: client_phone
  final String deliveryAddress; // Backend: client_address
  final String? clientNote; // Backend: client_note
  final int itemsCount; // Backend: items_count

  const OrderModel({
    required this.id,
    required this.shopId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.totalPrice,
    this.deliveryPrice,
    required this.status,
    required this.date,
    this.selectedColor,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    this.clientNote,
    this.itemsCount = 1,
  });

  /// JSON dan model yaratish (Backend response)
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Items array dan birinchi mahsulotni olish (UI uchun)
    String productId = '';
    String productName = '';
    String productImage = '';
    
    if (json['items'] != null && (json['items'] as List).isNotEmpty) {
      final firstItem = (json['items'] as List).first as Map<String, dynamic>;
      productId = firstItem['product_id']?.toString() ?? '';
      productName = firstItem['product_name']?.toString() ?? '';
      productImage = firstItem['product_image']?.toString() ?? '';
    } else {
      // Fallback: agar items bo'lmasa, to'g'ridan-to'g'ri maydonlardan olish
      productId = json['product_id']?.toString() ?? '';
      productName = json['product_name']?.toString() ?? '';
      productImage = json['product_image']?.toString() ?? '';
    }

    // Date parsing
    DateTime? date;
    if (json['created_at'] != null) {
      if (json['created_at'] is String) {
        date = DateTime.tryParse(json['created_at'] as String);
      }
    }
    date ??= DateTime.now();

    return OrderModel(
      id: json['id']?.toString() ?? '',
      shopId: json['shop_id']?.toString() ?? '',
      productId: productId,
      productName: productName,
      productImage: productImage,
      totalPrice: (json['total_amount'] as num?)?.toDouble() ?? 
                  (json['total_price'] as num?)?.toDouble() ?? 0.0,
      deliveryPrice: json['delivery_price'] != null
          ? (json['delivery_price'] as num?)?.toDouble()
          : null,
      status: OrderStatus.fromString(json['status']?.toString()),
      date: date,
      selectedColor: json['selected_color']?.toString(),
      customerName: json['client_name']?.toString() ?? 
                    json['customer_name']?.toString() ?? '',
      customerPhone: json['client_phone']?.toString() ?? 
                      json['customer_phone']?.toString() ?? '',
      deliveryAddress: json['client_address']?.toString() ?? 
                       json['delivery_address']?.toString() ?? '',
      clientNote: json['client_note']?.toString(),
      itemsCount: json['items_count'] as int? ?? 
                  (json['items'] != null ? (json['items'] as List).length : 1),
    );
  }

  /// Modelni JSON ga aylantirish (Backend format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'client_name': customerName,
      'client_phone': customerPhone,
      'client_address': deliveryAddress,
      if (clientNote != null) 'client_note': clientNote,
      'total_amount': totalPrice,
      if (deliveryPrice != null) 'delivery_price': deliveryPrice,
      'status': status.value,
      'created_at': date.toIso8601String(),
      // UI uchun qo'shimcha maydonlar
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      if (selectedColor != null) 'selected_color': selectedColor,
      'items_count': itemsCount,
    };
  }

  /// Nusxa olish (copyWith)
  OrderModel copyWith({
    String? id,
    String? shopId,
    String? productId,
    String? productName,
    String? productImage,
    double? totalPrice,
    double? deliveryPrice,
    OrderStatus? status,
    DateTime? date,
    String? selectedColor,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    String? clientNote,
    int? itemsCount,
  }) {
    return OrderModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      totalPrice: totalPrice ?? this.totalPrice,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      status: status ?? this.status,
      date: date ?? this.date,
      selectedColor: selectedColor ?? this.selectedColor,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      clientNote: clientNote ?? this.clientNote,
      itemsCount: itemsCount ?? this.itemsCount,
    );
  }
}
