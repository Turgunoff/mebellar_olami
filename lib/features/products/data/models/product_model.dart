import '../../../../core/utils/image_utils.dart';
import '../../../../core/utils/localized_text_helper.dart';
import 'package:flutter/material.dart';

/// Mahsulot modeli (MVP uchun moslashuvchan)
class ProductModel {
  final String id;
  final String? categoryId;
  final dynamic category; // Kategoriya nomi - Map yoki String bo'lishi mumkin
  final String?
  shopId; // Do'kon ID (Backend: shop_id, lekin hozircha qaytarmaydi)
  final dynamic name; // Map<String, dynamic> yoki String bo'lishi mumkin
  final dynamic description; // Map<String, dynamic> yoki String bo'lishi mumkin
  final double price;
  final double? discountPrice;
  final List<String> images;
  final Map<String, dynamic> specs;
  final List<Map<String, dynamic>> variants;
  final double rating;
  final bool isNew;
  final bool isPopular;
  final DateTime? createdAt;

  const ProductModel({
    required this.id,
    this.categoryId,
    this.category,
    this.shopId,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.images,
    this.specs = const {},
    this.variants = const [],
    this.rating = 4.5,
    this.isNew = false,
    this.isPopular = false,
    this.createdAt,
  });

  /// Chegirma foizi (masalan: 20)
  int get discountPercent {
    if (discountPrice == null || discountPrice! <= 0 || price <= 0) {
      return 0;
    }
    return ((price - discountPrice!) / price * 100).round();
  }

  /// Chegirma bormi
  bool get hasDiscount =>
      discountPrice != null && discountPrice! > 0 && discountPrice! < price;

  /// Asosiy rasm (to'liq URL yoki relative path)
  String get imageUrl {
    if (images.isEmpty) return '';
    return ImageUtils.getProductImageUrl(images.first);
  }

  /// Barcha rasmlar (to'liq URL lar bilan)
  List<String> get imageUrls {
    return images.map((img) => ImageUtils.getProductImageUrl(img)).toList();
  }

  /// Ranglar ro'yxati (variants dan)
  List<String> get colors {
    return variants
        .where((v) => v['colorCode'] != null)
        .map((v) => v['colorCode'] as String)
        .toList();
  }

  /// Aktual narx (chegirmali yoki oddiy)
  double get actualPrice => hasDiscount ? discountPrice! : price;

  /// Localized name helper
  String getLocalizedName(BuildContext context) {
    return LocalizedTextHelper.get(name, context);
  }

  /// Localized description helper
  String getLocalizedDescription(BuildContext context) {
    return LocalizedTextHelper.get(description, context);
  }

  /// JSON dan model yaratish (Backend response)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      categoryId: json['category_id']?.toString(),
      category: json['category'], // Map yoki String bo'lishi mumkin
      shopId: json['shop_id']?.toString(),
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: json['discount_price'] != null
          ? (json['discount_price'] as num?)?.toDouble()
          : null,
      // Safely parse lists to ensure they are never null
      images:
          (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      specs: (json['specs'] is Map)
          ? Map<String, dynamic>.from(json['specs'])
          : {},
      variants:
          (json['variants'] as List?)
              ?.map(
                (v) => v is Map
                    ? Map<String, dynamic>.from(v)
                    : <String, dynamic>{},
              )
              .toList() ??
          [],
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      isNew: json['is_new'] as bool? ?? false,
      isPopular: json['is_popular'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  /// Modelni JSON ga aylantirish
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'category': category,
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'images': images,
      'specs': specs,
      'variants': variants,
      'rating': rating,
      'is_new': isNew,
      'is_popular': isPopular,
    };
  }

  /// Nusxa olish (copyWith)
  ProductModel copyWith({
    String? id,
    String? categoryId,
    dynamic category,
    String? shopId,
    dynamic name,
    dynamic description,
    double? price,
    double? discountPrice,
    List<String>? images,
    Map<String, dynamic>? specs,
    List<Map<String, dynamic>>? variants,
    double? rating,
    bool? isNew,
    bool? isPopular,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      images: images ?? this.images,
      specs: specs ?? this.specs,
      variants: variants ?? this.variants,
      rating: rating ?? this.rating,
      isNew: isNew ?? this.isNew,
      isPopular: isPopular ?? this.isPopular,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
