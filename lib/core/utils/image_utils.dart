import '../constants/api_constants.dart';

/// Image URL helper utilities
class ImageUtils {
  /// Get clean domain without /api suffix
  static String get _domain {
    var url = ApiConstants.baseUrl;
    if (url.endsWith('/api')) {
      url = url.substring(0, url.length - 4);
    } else if (url.endsWith('/api/')) {
      url = url.substring(0, url.length - 5);
    }
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  /// Get full image URL from relative path
  static String getFullImageUrl(String path) {
    if (path.isEmpty) return '';

    // Agar to'liq URL bo'lsa (http:// yoki https:// bilan boshlansa)
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Agar relative path bo'lsa (/ bilan boshlansa), clean domain qo'shamiz
    if (path.startsWith('/')) {
      return '$_domain$path';
    }

    // Agar faqat fayl nomi bo'lsa, uploads qo'shamiz
    return '$_domain/uploads/$path';
  }

  /// Get full image URL for products
  static String getProductImageUrl(String path) {
    if (path.isEmpty) return '';

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    if (path.startsWith('/')) {
      return '$_domain$path';
    }

    return '$_domain/uploads/products/$path';
  }

  /// Get full image URL for categories
  static String getCategoryImageUrl(String path) {
    if (path.isEmpty) return '';

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    if (path.startsWith('/')) {
      return '$_domain$path';
    }

    return '$_domain/uploads/categories/$path';
  }
}
