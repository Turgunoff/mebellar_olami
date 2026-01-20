import 'package:equatable/equatable.dart';

/// Savatcha elementi modeli
class CartItemModel extends Equatable {
  const CartItemModel({
    required this.productId,
    required this.product,
    required this.quantity,
    this.addedAt,
    this.updatedAt,
  });

  final String productId;
  final Map<String, dynamic> product;
  final int quantity;
  final DateTime? addedAt;
  final DateTime? updatedAt;

  /// Mahsulotning joriy narxini olish (chegirma bilan)
  double get currentPrice {
    final hasDiscount = product['has_discount'] as bool? ?? false;
    if (hasDiscount && product['discount_price'] != null) {
      return (product['discount_price'] as num?)?.toDouble() ?? 0.0;
    }
    return (product['price'] as num?)?.toDouble() ?? 0.0;
  }

  /// Mahsulotning jami narxi (soniga ko'paytirilgan)
  double get totalPrice => currentPrice * quantity;

  /// Mahsulot nomi
  String get productName => product['name']?.toString() ?? 'Mahsulot';

  /// Mahsulot rasmi
  String get productImage => product['image_url']?.toString() ?? '';

  /// Mahsulot tavsifi
  String get productDescription => product['description']?.toString() ?? '';

  /// Chegirma borligi
  bool get hasDiscount => product['has_discount'] as bool? ?? false;

  /// Chegirma narxi
  double? get discountPrice {
    if (!hasDiscount) return null;
    return (product['discount_price'] as num?)?.toDouble();
  }

  /// Asl narx
  double get originalPrice => (product['price'] as num?)?.toDouble() ?? 0.0;

  CartItemModel copyWith({
    String? productId,
    Map<String, dynamic>? product,
    int? quantity,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON dan CartItemModel yaratish
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['product_id']?.toString() ?? '',
      product: json['product'] as Map<String, dynamic>? ?? {},
      quantity: json['quantity'] as int? ?? 1,
      addedAt: json['added_at'] != null
          ? DateTime.tryParse(json['added_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// JSON ga o'tkazish
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product': product,
      'quantity': quantity,
      'added_at': addedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [productId, product, quantity, addedAt, updatedAt];

  @override
  String toString() {
    return 'CartItemModel(productId: $productId, quantity: $quantity, productName: $productName)';
  }
}
