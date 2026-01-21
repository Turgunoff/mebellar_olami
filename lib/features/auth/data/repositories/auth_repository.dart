import 'package:dartz/dartz.dart';
import '../../../../../core/local/hive_service.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/failure.dart';
import '../../../../../core/network/error_message_helper.dart';

/// Auth bilan ishlash uchun repository.
class AuthRepository {
  final DioClient _dioClient;

  AuthRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Tizimga kirish.
  Future<Either<Failure, Map<String, dynamic>>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        '/auth/login',
        data: {'phone': phone, 'password': password},
      );

      // Handle error status codes
      if (response.statusCode != 200) {
        final data = response.data;
        String errorMessage = 'Login failed';

        if (data is Map<String, dynamic> && data.containsKey('message')) {
          errorMessage = data['message'] as String;
        }

        return Left(Failure(message: errorMessage));
      }

      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true && data['token'] != null) {
          await _persistAuthData(
            data['token'] as String,
            data['user'] as Map<String, dynamic>?,
          );
          return Right(data);
        } else {
          return Left(Failure(message: data['message'] ?? 'Login failed'));
        }
      } else {
        return Left(Failure(message: 'Invalid response from server'));
      }
    } catch (e) {
      return Left(Failure(message: ErrorMessageHelper.getMessage(e)));
    }
  }

  /// Ro'yxatdan o'tish.
  Future<Either<Failure, Map<String, dynamic>>> register({
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

      // Handle error status codes (400, 409, etc.)
      if (response.statusCode != 201 && response.statusCode != 200) {
        final data = response.data;
        String errorMessage = 'Registration failed';

        if (data is Map<String, dynamic> && data.containsKey('message')) {
          errorMessage = data['message'] as String;
        }

        return Left(Failure(message: errorMessage));
      }

      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true && data['token'] != null) {
          await _persistAuthData(
            data['token'] as String,
            data['user'] as Map<String, dynamic>?,
          );
          return Right(data);
        } else {
          return Left(
            Failure(message: data['message'] ?? 'Registration failed'),
          );
        }
      } else {
        return Left(Failure(message: 'Invalid response from server'));
      }
    } catch (e) {
      return Left(Failure(message: ErrorMessageHelper.getMessage(e)));
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

  /// OTP yuborish.
  Future<Either<Failure, Map<String, dynamic>>> sendOtp({
    required String phone,
  }) async {
    try {
      final response = await _dioClient.post(
        '/auth/send-otp',
        data: {'phone': phone},
      );

      // Check for 400 Bad Request - validation error
      if (response.statusCode == 400) {
        final data = response.data;
        String errorMessage = "Noto'g'ri so'rov.";

        if (data is Map<String, dynamic> && data.containsKey('message')) {
          errorMessage = data['message'] as String;
        }

        return Left(Failure(message: errorMessage));
      }

      // Check for 409 Conflict - phone already registered
      if (response.statusCode == 409) {
        final data = response.data;
        String errorMessage = "Bu telefon raqami allaqachon ro'yxatdan o'tgan";

        if (data is Map<String, dynamic> && data.containsKey('message')) {
          errorMessage = data['message'] as String;
        }

        return Left(Failure(message: errorMessage));
      }

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return Right({
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'OTP sent successfully',
        });
      } else {
        return Left(Failure(message: 'Failed to send OTP'));
      }
    } catch (e) {
      return Left(Failure(message: ErrorMessageHelper.getMessage(e)));
    }
  }

  /// OTP tasdiqlash.
  Future<Either<Failure, Map<String, dynamic>>> verifyOtp({
    required String phone,
    required String code,
  }) async {
    try {
      final response = await _dioClient.post(
        '/auth/verify-otp',
        data: {'phone': phone, 'code': code},
      );

      // Handle error status codes
      if (response.statusCode != 200) {
        final data = response.data;
        String errorMessage = 'Failed to verify OTP';

        if (data is Map<String, dynamic> && data.containsKey('message')) {
          errorMessage = data['message'] as String;
        }

        return Left(Failure(message: errorMessage));
      }

      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return Right({
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'OTP verified successfully',
        });
      } else {
        return Left(Failure(message: 'Failed to verify OTP'));
      }
    } catch (e) {
      return Left(Failure(message: ErrorMessageHelper.getMessage(e)));
    }
  }

  /// Parolni tiklash (OTP orqali).
  Future<Either<Failure, Map<String, dynamic>>> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await _dioClient.post(
        '/auth/reset-password',
        data: {'phone': phone, 'code': code, 'new_password': newPassword},
      );

      // Handle error status codes
      if (response.statusCode != 200) {
        final data = response.data;
        String errorMessage = 'Failed to reset password';

        if (data is Map<String, dynamic> && data.containsKey('message')) {
          errorMessage = data['message'] as String;
        }

        return Left(Failure(message: errorMessage));
      }

      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return Right({
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Password reset successful',
        });
      } else {
        return Left(Failure(message: 'Failed to reset password'));
      }
    } catch (e) {
      return Left(Failure(message: ErrorMessageHelper.getMessage(e)));
    }
  }

  /// Parolni unutish.
  Future<Either<Failure, Map<String, dynamic>>> forgotPassword({
    required String phone,
  }) async {
    try {
      final response = await _dioClient.post(
        '/auth/forgot-password',
        data: {'phone': phone},
      );

      // Handle error status codes
      if (response.statusCode != 200) {
        final data = response.data;
        String errorMessage = 'Failed to send reset code';

        if (data is Map<String, dynamic> && data.containsKey('message')) {
          errorMessage = data['message'] as String;
        }

        return Left(Failure(message: errorMessage));
      }

      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return Right({
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Password reset code sent',
        });
      } else {
        return Left(Failure(message: 'Failed to send reset code'));
      }
    } catch (e) {
      return Left(Failure(message: ErrorMessageHelper.getMessage(e)));
    }
  }
}
