import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../local/hive_service.dart';

/// Dio klientini sozlash va umumiy interceptors.
class DioClient {
  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        // 4xx javoblar errorga aylantirilmaydi, 5xx va tarmoq xatolar
        // onError orqali qayta ishlanadi.
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization header if token exists
          final token = HiveService.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            _logRequest(options);
          }

          return handler.next(options);
        },
        onResponse: (response, handler) async {
          if (kDebugMode) {
            _logResponse(response);
          }

          // Handle 401 in response as well
          if (response.statusCode == 401) {
            await _handleUnauthorizedError();
          }

          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          if (kDebugMode) {
            _logError(error);
          }

          // Handle 401 Unauthorized error
          if (error.response?.statusCode == 401) {
            await _handleUnauthorizedError();
          }

          return handler.next(error);
        },
      ),
    );
  }

  late final Dio dio;

  static final DioClient _singleton = DioClient._internal();

  factory DioClient() => _singleton;

  /// Qisqa yo'l bilan sozlangan Dio nusxasini olish.
  static Dio get instance => DioClient().dio;

  Future<void> _handleUnauthorizedError() async {
    // TODO: Implement refresh token logic
    // For now, just clear tokens and let the app handle logout
    if (kDebugMode) {
      developer.log('🔒 Unauthorized access - clearing tokens', name: 'DIO');
    }

    await HiveService.clearTokens();

    // You can emit a global event here to trigger logout across the app
    // For example: GetIt.instance<AuthBloc>().add(LogoutEvent());
  }

  void _logRequest(RequestOptions options) {
    developer.log('🚀 === API Request ===', name: 'DIO');
    developer.log('Method: ${options.method}', name: 'DIO');
    developer.log('URL: ${options.uri}', name: 'DIO');
    developer.log('Headers: ${options.headers}', name: 'DIO');
    if (options.data != null) {
      developer.log('Body: ${options.data}', name: 'DIO');
    }
    developer.log('====================', name: 'DIO');
  }

  void _logResponse(Response response) {
    developer.log('✅ === API Response ===', name: 'DIO');
    developer.log('Status Code: ${response.statusCode}', name: 'DIO');
    developer.log('URL: ${response.requestOptions.uri}', name: 'DIO');
    if (response.data != null) {
      developer.log('Response: ${response.data}', name: 'DIO');
    }
    developer.log('=====================', name: 'DIO');
  }

  void _logError(DioException error) {
    developer.log('❌ === API Error ===', name: 'DIO');
    developer.log('Type: ${error.type}', name: 'DIO');
    developer.log('Message: ${error.message}', name: 'DIO');
    developer.log('URL: ${error.requestOptions.uri}', name: 'DIO');

    if (error.response != null) {
      developer.log('Status Code: ${error.response?.statusCode}', name: 'DIO');
      developer.log('Response: ${error.response?.data}', name: 'DIO');
    }
    developer.log('==================', name: 'DIO');
  }

  // Convenience methods for common HTTP operations
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Method to update token for all future requests
  void updateToken(String? token) {
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      dio.options.headers.remove('Authorization');
    }
  }
}
