import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../local/hive_service.dart';
import '../utils/device_utils.dart';

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

          // Add device identification headers to all requests
          // Bu backendga kim va qaysi qurilmadan kirayotganini bilish uchun kerak
          try {
            options.headers['x-device-id'] = DeviceUtils.deviceId;
            options.headers['x-app-type'] = DeviceUtils.getAppType();
            options.headers['x-device-os'] = DeviceUtils.osType;
            options.headers['x-os-version'] = DeviceUtils.osVersion;
            options.headers['x-app-version'] = DeviceUtils.appVersion;
            options.headers['x-device-name'] = DeviceUtils.deviceName;
          } catch (e) {
            // DeviceUtils.init() chaqirilmagan bo'lsa, async versiyasini ishlatish
            if (kDebugMode) {
              developer.log(
                '⚠️ DeviceUtils not initialized, skipping device headers',
                name: 'DIO',
              );
            }
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

  /// Format response data for logging to avoid console clutter
  String _formatResponse(dynamic data) {
    if (data == null) return 'null';

    // Handle List data
    if (data is List) {
      return 'List [length: ${data.length}]';
    }

    // Handle Map data
    if (data is Map) {
      final formattedMap = <String, dynamic>{};

      // Check for large lists that should be summarized
      final listKeys = [
        'products',
        'categories',
        'orders',
        'users',
        'items',
        'sessions',
      ];

      for (final entry in data.entries) {
        final key = entry.key;
        final value = entry.value;

        // If value is a large list, summarize it
        if (listKeys.contains(key) && value is List) {
          formattedMap[key] = 'List [Length: ${value.length}]';
        } else {
          formattedMap[key] = value;
        }
      }

      // Convert to string and check length
      String jsonString = jsonEncode(formattedMap);

      // Truncate if too long
      if (jsonString.length > 500) {
        jsonString = '${jsonString.substring(0, 497)}... [TRUNCATED]';
      }

      return jsonString;
    }

    // Handle other types (String, int, bool, etc.)
    String stringData = data.toString();

    // Truncate if too long
    if (stringData.length > 500) {
      stringData = '${stringData.substring(0, 497)}... [TRUNCATED]';
    }

    return stringData;
  }

  void _logResponse(Response response) {
    developer.log('✅ === API Response ===', name: 'DIO');
    developer.log('Status Code: ${response.statusCode}', name: 'DIO');
    developer.log('URL: ${response.requestOptions.uri}', name: 'DIO');
    if (response.data != null) {
      developer.log('Response: ${_formatResponse(response.data)}', name: 'DIO');
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
