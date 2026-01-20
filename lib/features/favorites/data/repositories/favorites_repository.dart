import '../../../../core/local/hive_service.dart';
import '../../../../core/network/dio_client.dart';

class FavoritesRepository {
  final DioClient _dioClient;

  FavoritesRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Sevimli mahsulotlarni olish (Guest Mode qo'llab-quvvatlaydi)
  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      // Token borligini tekshirish
      final hasToken = HiveService.hasToken;

      if (hasToken) {
        // User mode - API dan olish
        final response = await _dioClient.get('/favorites');

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          if (data['success'] == true) {
            final favorites = List<Map<String, dynamic>>.from(
              data['favorites'] ?? [],
            );

            // Hive ga ham saqlab qo'yymiz (offline uchun)
            await _saveFavoritesToHive(favorites);
            return favorites;
          }
        }
      }

      // Guest mode yoki API xatoligi bo'lsa - Hive dan olish
      return _getFavoritesFromHive();
    } catch (e) {
      // Xatolik bo'lsa Hive dan qaytaramiz
      return _getFavoritesFromHive();
    }
  }

  /// Sevimli mahsulotni almashtirish (Guest Mode qo'llab-quvvatlaydi)
  Future<Map<String, dynamic>> toggleFavorite(
    Map<String, dynamic> product,
  ) async {
    try {
      final hasToken = HiveService.hasToken;
      final productId = product['id']?.toString() ?? '';

      if (hasToken) {
        // User mode - API ga so'rov yuborish
        final response = await _dioClient.post(
          '/favorites/toggle',
          data: {'product_id': productId},
        );

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          if (data['success'] == true) {
            // Hive ham yangilaymiz
            await _toggleFavoriteInHive(product);
            return {
              'success': true,
              'is_favorite': data['is_favorite'] ?? false,
              'message': data['message'] ?? 'Success',
            };
          }
        }
      }

      // Guest mode yoki API xatoligi - Hive da ishlash
      final result = await _toggleFavoriteInHive(product);
      return {
        'success': true,
        'is_favorite': result['is_favorite'],
        'message': result['is_favorite']
            ? 'Added to favorites'
            : 'Removed from favorites',
      };
    } catch (e) {
      // Xatolik bo'lsa Hive da urinib ko'ramiz
      final result = await _toggleFavoriteInHive(product);
      return {
        'success': true,
        'is_favorite': result['is_favorite'],
        'message': result['is_favorite']
            ? 'Added to favorites'
            : 'Removed from favorites',
      };
    }
  }

  /// Hive dagi sevimlilarni server bilan sinxronizatsiya qilish (faqat User uchun)
  Future<Map<String, dynamic>> syncFavorites() async {
    try {
      final hasToken = HiveService.hasToken;

      if (!hasToken) {
        return {'success': false, 'message': 'No authentication token'};
      }

      // Hive dagi barcha sevimlilarni olish
      final localFavorites = _getFavoritesFromHive();

      if (localFavorites.isEmpty) {
        return {'success': true, 'message': 'No favorites to sync'};
      }

      // Har bir mahsulot uchun serverga so'rov yuborish
      final syncResults = <Map<String, dynamic>>[];

      for (final favorite in localFavorites) {
        try {
          final response = await _dioClient.post(
            '/favorites/add',
            data: {'product_id': favorite['id']?.toString() ?? ''},
          );

          if (response.statusCode == 200) {
            syncResults.add({'product_id': favorite['id'], 'success': true});
          } else {
            syncResults.add({'product_id': favorite['id'], 'success': false});
          }
        } catch (e) {
          syncResults.add({'product_id': favorite['id'], 'success': false});
        }
      }

      // Muvaffaqiyatli sinxronizatsiya qilinganlarni sanash
      final successCount = syncResults
          .where((r) => r['success'] == true)
          .length;

      return {
        'success': true,
        'synced_count': successCount,
        'total_count': localFavorites.length,
        'message':
            'Synced $successCount out of ${localFavorites.length} favorites',
      };
    } catch (e) {
      return {'success': false, 'message': 'Sync failed: ${e.toString()}'};
    }
  }

  /// Mahsulot sevimli ekanligini tekshirish
  bool isFavorite(String productId) {
    try {
      final favorites = HiveService.favoritesBox.values.toList();
      return favorites.any(
        (favorite) =>
            favorite is Map && favorite['id']?.toString() == productId,
      );
    } catch (e) {
      return false;
    }
  }

  // Private helper methods

  List<Map<String, dynamic>> _getFavoritesFromHive() {
    try {
      final favorites = HiveService.favoritesBox.values.toList();
      return favorites
          .whereType<Map<String, dynamic>>()
          .cast<Map<String, dynamic>>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveFavoritesToHive(
    List<Map<String, dynamic>> favorites,
  ) async {
    try {
      await HiveService.favoritesBox.clear();
      for (int i = 0; i < favorites.length; i++) {
        await HiveService.favoritesBox.put(i, favorites[i]);
      }
    } catch (e) {
      // Xatolikni log qilish mumkin
    }
  }

  Future<Map<String, dynamic>> _toggleFavoriteInHive(
    Map<String, dynamic> product,
  ) async {
    try {
      final productId = product['id']?.toString() ?? '';
      final currentFavorites = _getFavoritesFromHive();

      // Mahsulot allaqachon sevimlilar borligini tekshirish
      final existingIndex = currentFavorites.indexWhere(
        (favorite) => favorite['id']?.toString() == productId,
      );

      List<Map<String, dynamic>> updatedFavorites;
      bool isFavorite;

      if (existingIndex != -1) {
        // Mahsulotni o'chirish
        updatedFavorites = List.from(currentFavorites)..removeAt(existingIndex);
        isFavorite = false;
      } else {
        // Mahsulotni qo'shish
        updatedFavorites = List.from(currentFavorites)..add(product);
        isFavorite = true;
      }

      // Yangilangan ro'yxatni saqlash
      await _saveFavoritesToHive(updatedFavorites);

      return {'is_favorite': isFavorite};
    } catch (e) {
      return {'is_favorite': false};
    }
  }

  /// Hive dagi barcha sevimlilarni tozalash
  Future<void> clearFavorites() async {
    try {
      await HiveService.favoritesBox.clear();
    } catch (e) {
      // Xatolikni log qilish mumkin
    }
  }
}
