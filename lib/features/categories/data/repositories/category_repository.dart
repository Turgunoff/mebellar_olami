import '../../../../core/network/dio_client.dart';

class CategoryRepository {
  final DioClient _dioClient;

  CategoryRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Kategoriyalar daraxtini olish
  Future<Map<String, dynamic>> getCategories() async {
    try {
      print('📂 [CATEGORY_REPO] Fetching categories from: /categories');

      final response = await _dioClient.get('/categories');

      print('📂 [CATEGORY_REPO] Response status: ${response.statusCode}');
      print('📂 [CATEGORY_REPO] Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': data['success'] ?? true,
          'categories': data['categories'] ?? [],
          'message': data['message'] ?? 'Success',
        };
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('❌ [CATEGORY_REPO] Error: $e');
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
        'categories': <Map<String, dynamic>>[],
      };
    }
  }
}
