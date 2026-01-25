import '../../../../core/network/dio_client.dart';
import '../models/banner_model.dart';

/// Banner ma'lumotlarini backend'dan olish uchun repository
class BannerRepository {
  final DioClient _dioClient;

  BannerRepository({required DioClient dioClient}) : _dioClient = dioClient;

  /// Barcha faol bannerlarni olish
  /// Returns: BannerModel lari ro'yxati yoki xatolik
  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await _dioClient.dio.get('/banners');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final bannersJson = response.data['banners'] as List<dynamic>? ?? [];

        return bannersJson
            .map((json) => BannerModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          response.data['message'] ?? 'Bannerlarni yuklashda xatolik',
        );
      }
    } catch (e) {
      throw Exception('Bannerlarni yuklashda xatolik: $e');
    }
  }
}
