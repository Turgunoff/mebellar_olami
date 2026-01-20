import 'dart:io';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/api_service.dart';

/// Profile repository - foydalanuvchi profili bilan ishlash
class ProfileRepository {
  final DioClient _dioClient;
  final ApiService _apiService;

  ProfileRepository({DioClient? dioClient, ApiService? apiService})
    : _dioClient = dioClient ?? DioClient(),
      _apiService = apiService ?? ApiService();

  /// Profil ma'lumotlarini olish
  Future<ApiResponse> getProfile() async {
    try {
      final response = await _dioClient.get('/user/me');
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? '',
        user: response.data['user'] != null
            ? Map<String, dynamic>.from(response.data['user'])
            : null,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Profilni yuklashda xatolik: $e',
      );
    }
  }

  /// Profilni yangilash (ism va avatar)
  Future<ApiResponse> updateProfile({
    String? fullName,
    File? avatarFile,
  }) async {
    try {
      if (avatarFile != null) {
        // Avatar bilan yangilash - multipart
        return await _apiService.updateProfile(
          fullName: fullName,
          avatarFile: avatarFile,
        );
      } else {
        // Faqat ismni yangilash - oddiy JSON
        final response = await _dioClient.put(
          '/user/me',
          data: fullName != null ? {'full_name': fullName} : {},
        );
        return ApiResponse(
          success: response.data['success'] ?? false,
          message: response.data['message'] ?? '',
          user: response.data['user'] != null
              ? Map<String, dynamic>.from(response.data['user'])
              : null,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Profilni yangilashda xatolik: $e',
      );
    }
  }

  /// Hisobni o'chirish
  Future<ApiResponse> deleteAccount() async {
    try {
      final response = await _dioClient.delete('/user/me');
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? '',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Hisobni o\'chirishda xatolik: $e',
      );
    }
  }

  /// Telefon raqamini o'zgartirish - OTP so'rash
  Future<ApiResponse> requestPhoneChange(String newPhone) async {
    try {
      final response = await _dioClient.post(
        '/user/change-phone/request',
        data: {'new_phone': newPhone},
      );
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? '',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'OTP yuborishda xatolik: $e');
    }
  }

  /// Telefon raqamini o'zgartirish - OTP tasdiqlash
  Future<ApiResponse> verifyPhoneChange(String newPhone, String code) async {
    try {
      final response = await _dioClient.post(
        '/user/change-phone/verify',
        data: {'new_phone': newPhone, 'code': code},
      );
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? '',
        user: response.data['user'] != null
            ? Map<String, dynamic>.from(response.data['user'])
            : null,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Kodni tasdiqlashda xatolik: $e',
      );
    }
  }

  /// Emailni o'zgartirish - OTP so'rash
  Future<ApiResponse> requestEmailChange(String newEmail) async {
    try {
      final response = await _dioClient.post(
        '/user/change-email/request',
        data: {'new_email': newEmail},
      );
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? '',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'OTP yuborishda xatolik: $e');
    }
  }

  /// Emailni o'zgartirish - OTP tasdiqlash
  Future<ApiResponse> verifyEmailChange(String newEmail, String code) async {
    try {
      final response = await _dioClient.post(
        '/user/change-email/verify',
        data: {'new_email': newEmail, 'code': code},
      );
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? '',
        user: response.data['user'] != null
            ? Map<String, dynamic>.from(response.data['user'])
            : null,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Kodni tasdiqlashda xatolik: $e',
      );
    }
  }
}
