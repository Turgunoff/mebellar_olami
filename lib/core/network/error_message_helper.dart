import 'package:dio/dio.dart';

/// Helper class to convert exceptions into user-friendly messages.
class ErrorMessageHelper {
  /// Returns a user-friendly message based on the exception type.
  static String getMessage(dynamic exception) {
    if (exception is DioException) {
      return _getDioErrorMessage(exception);
    } else {
      return "Noma'lum xatolik yuz berdi.";
    }
  }

  static String _getDioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return "Internet aloqasi yo'q. Iltimos, tarmoqni tekshiring.";

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 400) {
          // Try to get message from backend response
          final responseData = error.response?.data;
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('message')) {
            return responseData['message'] as String;
          }
          return "Noto'g'ri so'rov.";
        } else if (statusCode == 401) {
          return "Sessiya vaqti tugadi. Qayta kirish qiling.";
        } else if (statusCode == 403) {
          return "Sizga ruxsat berilmagan.";
        } else if (statusCode == 404) {
          return "Ma'lumot topilmadi.";
        } else if (statusCode == 409) {
          // Conflict - usually means resource already exists
          final responseData = error.response?.data;
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('message')) {
            return responseData['message'] as String;
          }
          return "Bu ma'lumot allaqachon mavjud.";
        } else if (statusCode != null && statusCode >= 500) {
          return "Serverda xatolik yuz berdi. Keyinroq urinib ko'ring.";
        } else {
          return "Noma'lum xatolik yuz berdi.";
        }

      default:
        return "Noma'lum xatolik yuz berdi.";
    }
  }
}
