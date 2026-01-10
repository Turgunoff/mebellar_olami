/// Mahsulot modeli
class ProductModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final String category;
  final String categoryId;
  final String imageUrl;
  final List<String> colors;
  final double rating;
  final bool isNew;
  final bool isPopular;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.categoryId,
    required this.imageUrl,
    required this.colors,
    required this.rating,
    this.isNew = false,
    this.isPopular = false,
  });

  /// JSON dan model yaratish (kelajakda backend uchun)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      categoryId: json['category_id'] as String,
      imageUrl: json['image_url'] as String,
      colors: List<String>.from(json['colors'] as List),
      rating: (json['rating'] as num).toDouble(),
      isNew: json['is_new'] as bool? ?? false,
      isPopular: json['is_popular'] as bool? ?? false,
    );
  }

  /// Modelni JSON ga aylantirish
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'category_id': categoryId,
      'image_url': imageUrl,
      'colors': colors,
      'rating': rating,
      'is_new': isNew,
      'is_popular': isPopular,
    };
  }

  /// Nusxa olish (copyWith)
  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? category,
    String? categoryId,
    String? imageUrl,
    List<String>? colors,
    double? rating,
    bool? isNew,
    bool? isPopular,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      colors: colors ?? this.colors,
      rating: rating ?? this.rating,
      isNew: isNew ?? this.isNew,
      isPopular: isPopular ?? this.isPopular,
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
