class SearchResultModel {
  final String id;
  final String name;
  final String? imageUrl;
  final double? price;
  final double? rating;
  final String? category;
  final bool? inStock;
  final String? description;

  SearchResultModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.price,
    this.rating,
    this.category,
    this.inStock,
    this.description,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['title'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? json['image'],
      price: json['price']?.toDouble(),
      rating: json['rating']?.toDouble(),
      category: json['category'] ?? json['category_name'],
      inStock: json['in_stock'] ?? json['available'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'price': price,
      'rating': rating,
      'category': category,
      'in_stock': inStock,
      'description': description,
    };
  }
}
