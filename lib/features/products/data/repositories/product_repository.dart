import '../../../../core/network/dio_client.dart';

class ProductRepository {
  final DioClient _dioClient;

  ProductRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Mahsulotlarni olish
  Future<Map<String, dynamic>> getProducts({
    String? categoryId,
    String? parentId,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (parentId != null) queryParams['parent_id'] = parentId;
      if (search != null) queryParams['search'] = search;

      final response = await _dioClient.get(
        '/products',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': true,
          'products': data['products'] ?? [],
          'total': data['total'] ?? 0,
          'page': data['page'] ?? page,
          'total_pages': data['total_pages'] ?? 1,
        };
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
        'products': <Map<String, dynamic>>[],
      };
    }
  }

  /// Tavsiya etilgan mahsulotlar (Cross-selling)
  Future<Map<String, dynamic>> getRecommendedProducts({
    int limit = 10,
    String? category,
    List<String>? excludeIds,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'type':
            'recommended', // API ga bu turdagi mahsulotlar kerakligini bildiramiz
      };

      if (category != null) queryParams['category'] = category;
      if (excludeIds != null && excludeIds.isNotEmpty) {
        queryParams['exclude_ids'] = excludeIds.join(',');
      }

      final response = await _dioClient.get(
        '/products/recommended',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': true,
          'products': data['products'] ?? [],
          'title': data['title'] ?? 'Sizga yoqishi mumkin',
          'subtitle': data['subtitle'] ?? 'Mashhur mahsulotlar',
        };
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      // API xatoligi bo'lsa, mahsulotlarni olishga urinib ko'ramiz
      return await _getPopularProductsFallback(
        limit: limit,
        excludeIds: excludeIds,
      );
    }
  }

  /// Mashhur mahsulotlar (Fallback)
  Future<Map<String, dynamic>> getPopularProducts({
    int limit = 10,
    List<String>? excludeIds,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'sort': 'popularity',
        'order': 'desc',
      };

      if (excludeIds != null && excludeIds.isNotEmpty) {
        queryParams['exclude_ids'] = excludeIds.join(',');
      }

      final response = await _dioClient.get(
        '/products/popular',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': true,
          'products': data['products'] ?? [],
          'title': 'Mashhur mahsulotlar',
          'subtitle': 'Eng ko\'p sotiladiganlar',
        };
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
        'products': <Map<String, dynamic>>[],
        'title': 'Tavsiyalar',
        'subtitle': 'Mahsulotlar vaqtinchalik mavjud emas',
      };
    }
  }

  /// Yangi kelgan mahsulotlar
  Future<Map<String, dynamic>> getNewProducts({
    int limit = 10,
    List<String>? excludeIds,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'sort': 'created_at',
        'order': 'desc',
        'is_new': true,
      };

      if (excludeIds != null && excludeIds.isNotEmpty) {
        queryParams['exclude_ids'] = excludeIds.join(',');
      }

      final response = await _dioClient.get(
        '/products/new',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': true,
          'products': data['products'] ?? [],
          'title': 'Yangi mahsulotlar',
          'subtitle': 'So\'nggi qo\'shilganlar',
        };
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
        'products': <Map<String, dynamic>>[],
        'title': 'Yangi mahsulotlar',
        'subtitle': 'Mahsulotlar vaqtinchalik mavjud emas',
      };
    }
  }

  /// Chegirmali mahsulotlar
  Future<Map<String, dynamic>> getDiscountedProducts({
    int limit = 10,
    List<String>? excludeIds,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'has_discount': true,
        'sort': 'discount_percent',
        'order': 'desc',
      };

      if (excludeIds != null && excludeIds.isNotEmpty) {
        queryParams['exclude_ids'] = excludeIds.join(',');
      }

      final response = await _dioClient.get(
        '/products/discounted',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': true,
          'products': data['products'] ?? [],
          'title': 'Chegirmali mahsulotlar',
          'subtitle': 'Aksiya va chegirmalar',
        };
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
        'products': <Map<String, dynamic>>[],
        'title': 'Chegirmali mahsulotlar',
        'subtitle': 'Aksiya vaqtinchalik mavjud emas',
      };
    }
  }

  /// Mahsulot detallari
  Future<Map<String, dynamic>> getProductDetails(String productId) async {
    try {
      final response = await _dioClient.get('/products/$productId');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return {'success': true, 'product': data['product']};
      } else {
        throw Exception('Product not found');
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  /// Mahsulot qidiruvi
  Future<Map<String, dynamic>> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    return await getProducts(search: query, page: page, limit: limit);
  }

  /// Sub-kategoriyalar bo'yicha guruhlangan mahsulotlar (Netflix-style preview)
  Future<Map<String, dynamic>> getProductsGroupedBySubcategory({
    required String parentId,
    int limitPerCat = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'parent_id': parentId,
        'limit_per_cat': limitPerCat,
      };

      final response = await _dioClient.get(
        '/products/grouped-by-subcategory',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': true,
          'groups': data['groups'] ?? [],
          'count': data['count'] ?? 0,
        };
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
        'groups': <Map<String, dynamic>>[],
        'count': 0,
      };
    }
  }

  /// Kategoriyalar ro'yxati
  Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await _dioClient.get('/categories');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return {'success': true, 'categories': data['categories'] ?? []};
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
        'categories': <Map<String, dynamic>>[],
      };
    }
  }

  // Private helper methods

  Future<Map<String, dynamic>> _getPopularProductsFallback({
    int limit = 10,
    List<String>? excludeIds,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'sort': 'popularity',
        'order': 'desc',
      };

      if (excludeIds != null && excludeIds.isNotEmpty) {
        queryParams['exclude_ids'] = excludeIds.join(',');
      }

      final response = await _dioClient.get(
        '/products',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': true,
          'products': data['products'] ?? [],
          'title': 'Mashhur mahsulotlar',
          'subtitle': 'Eng ko\'p sotiladiganlar',
        };
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
        'products': <Map<String, dynamic>>[],
        'title': 'Tavsiyalar',
        'subtitle': 'Mahsulotlar vaqtinchalik mavjud emas',
      };
    }
  }
}
