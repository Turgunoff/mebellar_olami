import '../../../../core/utils/image_utils.dart';
import '../../../../core/utils/localized_text_helper.dart';
import 'package:flutter/material.dart';

/// Kategoriya modeli (Backend API bilan mos)
class CategoryModel {
  final String id;
  final dynamic name; // Map<String, dynamic> yoki String bo'lishi mumkin
  final String? parentId;
  final String iconUrl; // Backend: icon_url
  final String iconName; // Lokal ikon nomi (fallback)
  final int productCount;
  final List<CategoryModel> subCategories; // Backend: sub_categories

  const CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    this.iconUrl = '',
    this.iconName = 'category',
    this.productCount = 0,
    this.subCategories = const [],
  });

  /// Backend API dan kelgan JSON ni parse qilish
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name:
          json['name'], // Map yoki String bo'lishi mumkin, o'z holicha saqlaymiz
      parentId: json['parent_id']?.toString(),
      iconUrl: json['icon_url']?.toString() ?? '',
      iconName: json['icon_name']?.toString() ?? 'category',
      productCount: (json['product_count'] as int?) ?? 0,
      subCategories:
          (json['sub_categories'] as List?)
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
      'icon_url': iconUrl,
      'icon_name': iconName,
      'product_count': productCount,
      'sub_categories': subCategories.map((e) => e.toJson()).toList(),
    };
  }

  /// Sub-kategoriyalar bormi
  bool get hasSubCategories => subCategories.isNotEmpty;

  /// Ikon URL mavjudmi
  bool get hasIconUrl => iconUrl.isNotEmpty;

  /// To'liq icon URL (base URL bilan)
  String get fullIconUrl => ImageUtils.getCategoryImageUrl(iconUrl);

  /// Localized name helper
  String getLocalizedName(BuildContext context) {
    return LocalizedTextHelper.get(name, context);
  }

  /// copyWith
  CategoryModel copyWith({
    String? id,
    dynamic name,
    String? parentId,
    String? iconUrl,
    String? iconName,
    int? productCount,
    List<CategoryModel>? subCategories,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      iconUrl: iconUrl ?? this.iconUrl,
      iconName: iconName ?? this.iconName,
      productCount: productCount ?? this.productCount,
      subCategories: subCategories ?? this.subCategories,
    );
  }
}
