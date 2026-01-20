import '../../../../core/network/dio_client.dart';

class CategoryRepository {
  final DioClient _dioClient;

  CategoryRepository(this._dioClient);

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
