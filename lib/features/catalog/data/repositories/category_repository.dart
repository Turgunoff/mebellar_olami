import '../../../../core/network/dio_client.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final DioClient _dioClient;

  CategoryRepository(this._dioClient);

  /// Fetch only main categories (parent_id is null)
  Future<List<CategoryModel>> getMainCategories() async {
    try {
      final response = await _dioClient.dio.get('/categories');

      if (response.statusCode == 200) {
        final cats = response.data['categories'] as List? ?? [];
        final allCategories = cats
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Filter: only categories where parentId is null
        return allCategories
            .where((category) => category.parentId == null)
            .toList();
      } else {
        throw Exception('Kategoriyalarni yuklashda xatolik');
      }
    } catch (e) {
      throw Exception('Server xatosi: $e');
    }
  }

  /// Fetch sub-categories for a given parent category
  Future<List<CategoryModel>> getSubCategories(String parentId) async {
    try {
      final response = await _dioClient.dio.get(
        '/categories',
        queryParameters: {'parent_id': parentId},
      );

      if (response.statusCode == 200) {
        final cats = response.data['categories'] as List? ?? [];
        return cats
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Sub-kategoriyalarni yuklashda xatolik');
      }
    } catch (e) {
      throw Exception('Server xatosi: $e');
    }
  }

  Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await _dioClient.dio.get('/categories');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'categories': response.data['categories'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'Kategoriyalarni yuklashda xatolik',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Server xatosi: $e'};
    }
  }

  Future<Map<String, dynamic>> getCategoryById(String categoryId) async {
    try {
      final response = await _dioClient.dio.get('/categories/$categoryId');

      if (response.statusCode == 200) {
        return {'success': true, 'category': response.data['category']};
      } else {
        return {'success': false, 'message': 'Kategoriyani yuklashda xatolik'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Server xatosi: $e'};
    }
  }
}
