import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Banner modeli - backenddan keladigan banner ma'lumotlari
class BannerModel {
  final String id;
  final Map<String, dynamic> title;
  final Map<String, dynamic>? subtitle;
  final String imageUrl;
  final String targetType;
  final String? targetId;
  final int sortOrder;
  final bool isActive;
  final DateTime? createdAt;

  BannerModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.targetType = 'none',
    this.targetId,
    this.sortOrder = 0,
    this.isActive = true,
    this.createdAt,
  });

  /// JSON dan BannerModel yaratish
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as Map<String, dynamic>? ?? {},
      subtitle: json['subtitle'] as Map<String, dynamic>?,
      imageUrl: json['image_url'] as String? ?? '',
      targetType: json['target_type'] as String? ?? 'none',
      targetId: json['target_id'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// BannerModel ni JSON ga aylantirish
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'target_type': targetType,
      'target_id': targetId,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Joriy tilga mos sarlavhani olish
  /// [context] - BuildContext, tilni aniqlash uchun
  /// Fallback: 'uz' tiliga qaytadi agar joriy til topilmasa
  String getLocalizedTitle(BuildContext context) {
    final langCode = context.locale.languageCode;

    // Joriy tilda qiymat mavjudmi?
    if (title.containsKey(langCode) && title[langCode] != null) {
      final value = title[langCode];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    // Fallback: 'uz' tiliga qaytish
    if (title.containsKey('uz') && title['uz'] != null) {
      final value = title['uz'];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    // Agar hech narsa topilmasa, birinchi mavjud qiymatni qaytarish
    for (final value in title.values) {
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  /// Joriy tilga mos qo'shimcha matnni olish
  /// [context] - BuildContext, tilni aniqlash uchun
  /// Fallback: 'uz' tiliga qaytadi agar joriy til topilmasa
  String getLocalizedSubtitle(BuildContext context) {
    if (subtitle == null) return '';

    final langCode = context.locale.languageCode;

    // Joriy tilda qiymat mavjudmi?
    if (subtitle!.containsKey(langCode) && subtitle![langCode] != null) {
      final value = subtitle![langCode];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    // Fallback: 'uz' tiliga qaytish
    if (subtitle!.containsKey('uz') && subtitle!['uz'] != null) {
      final value = subtitle!['uz'];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    // Agar hech narsa topilmasa, birinchi mavjud qiymatni qaytarish
    for (final value in subtitle!.values) {
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  /// Banner bosilganda qayerga yo'naltirish kerakligini aniqlash
  bool get hasTarget => targetType != 'none' && targetId != null;

  @override
  String toString() {
    return 'BannerModel(id: $id, title: $title, imageUrl: $imageUrl)';
  }
}
