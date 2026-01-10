/// Mahsulot modeli (MVP uchun moslashuvchan)
class ProductModel {
  final String id;
  final String? categoryId;
  final String name;
  final String description;
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
  bool get hasDiscount => discountPrice != null && discountPrice! > 0 && discountPrice! < price;

  /// Asosiy rasm
  String get imageUrl => images.isNotEmpty ? images.first : '';

  /// Ranglar ro'yxati (variants dan)
  List<String> get colors {
    return variants
        .where((v) => v['colorCode'] != null)
        .map((v) => v['colorCode'] as String)
        .toList();
  }

  /// Aktual narx (chegirmali yoki oddiy)
  double get actualPrice => hasDiscount ? discountPrice! : price;

  /// JSON dan model yaratish (Backend response)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Images massivini parse qilish
    List<String> parseImages(dynamic imagesData) {
      if (imagesData == null) return [];
      if (imagesData is List) {
        return imagesData.map((e) => e.toString()).toList();
      }
      return [];
    }

    // Specs parse qilish
    Map<String, dynamic> parseSpecs(dynamic specsData) {
      if (specsData == null) return {};
      if (specsData is Map) {
        return Map<String, dynamic>.from(specsData);
      }
      return {};
    }

    // Variants parse qilish
    List<Map<String, dynamic>> parseVariants(dynamic variantsData) {
      if (variantsData == null) return [];
      if (variantsData is List) {
        return variantsData
            .map((v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{})
            .toList();
      }
      return [];
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      categoryId: json['category_id']?.toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: json['discount_price'] != null 
          ? (json['discount_price'] as num?)?.toDouble() 
          : null,
      images: parseImages(json['images']),
      specs: parseSpecs(json['specs']),
      variants: parseVariants(json['variants']),
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
    String? name,
    String? description,
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

/// Kategoriya modeli
class CategoryModel {
  final String id;
  final String name;
  final String? parentId;
  final String iconName;
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    required this.iconName,
    this.children = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parent_id'] as String?,
      iconName: json['icon_name'] as String,
      children: (json['children'] as List?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'icon_name': iconName,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}
