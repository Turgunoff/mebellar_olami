import 'package:dio/dio.dart';
import '../../../core/local/hive_service.dart';
import '../../../core/network/dio_client.dart';

/// Auth bilan ishlash uchun repository.
class AuthRepository {
  final DioClient _dioClient;

  AuthRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Tizimga kirish.
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        '/auth/login',
        data: {'phone': phone, 'password': password},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true && data['token'] != null) {
          await _persistAuthData(
            data['token'] as String,
            data['user'] as Map<String, dynamic>?,
          );
          return data;
        } else {
          throw Exception(data['message'] ?? 'Login failed');
        }
      } else {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Ro'yxatdan o'tish.
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  }) async {
    try {
      final response = await _dioClient.post(
        '/auth/register',
        data: {
          'full_name': fullName,
          'phone': phone,
          'password': password,
          if (email != null) 'email': email,
        },
      );

      if (response.statusCode == 201 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true && data['token'] != null) {
          await _persistAuthData(
            data['token'] as String,
            data['user'] as Map<String, dynamic>?,
          );
          return data;
        } else {
          throw Exception(data['message'] ?? 'Registration failed');
        }
      } else {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Tizimdan chiqish.
  Future<void> logout() async {
    try {
      // Call logout endpoint if needed
      await _dioClient.post('/auth/logout');
    } catch (e) {
      // Continue with local logout even if server call fails
    } finally {
      await clearSession();
    }
  }

  /// Autentifikatsiya holatini tekshirish.
  Future<bool> checkAuthStatus() async {
    final token = HiveService.accessToken;
    return token != null && token.isNotEmpty;
  }

  /// Saqlangan tokenni olish.
  Future<String?> getSavedToken() async {
    return HiveService.accessToken;
  }

  /// Onboarding holatini saqlash.
  Future<void> setOnboardingCompleted() async {
    await HiveService.authBox.put('onboarding_completed', true);
  }

  /// Onboarding holatini olish.
  Future<bool> isOnboardingCompleted() async {
    return HiveService.authBox.get('onboarding_completed', defaultValue: false)
        as bool;
  }

  /// Tizimdan chiqish va ma'lumotlarni tozalash.
  Future<void> clearSession() async {
    await HiveService.clearTokens();
    await HiveService.authBox.delete('user_name');
    await HiveService.authBox.delete('user_phone');
    await HiveService.authBox.delete('user_id');
    await HiveService.authBox.delete('user_email');
  }

  Future<void> _persistAuthData(
    String token,
    Map<String, dynamic>? user,
  ) async {
    await HiveService.saveTokens(accessToken: token);

    if (user != null) {
      await HiveService.authBox.put('user_name', user['full_name'] ?? '');
      await HiveService.authBox.put('user_phone', user['phone'] ?? '');
      await HiveService.authBox.put('user_id', user['id']?.toString() ?? '');
      await HiveService.authBox.put('user_email', user['email'] ?? '');
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server timeout. Please try again.';
      case DioExceptionType.badResponse:
        if (error.response?.data is Map<String, dynamic>) {
          final data = error.response!.data as Map<String, dynamic>;
          return data['message'] ?? data['error'] ?? 'Server error occurred.';
        }
        return 'Server error: ${error.response?.statusCode ?? 'Unknown'}';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.unknown:
        if (error.error?.toString().contains('SocketException') == true) {
          return 'No internet connection. Please check your network.';
        }
        return 'An unexpected error occurred. Please try again.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
