import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;

/// API Service - Go Backend bilan bog'lanish
class ApiService {
  // Backend server manzili - o'zingizning IP manzilingizni kiriting
  // Emulator uchun: 10.0.2.2:8081
  // iOS Simulator uchun: localhost:8081
  // Real device uchun: <YOUR_IP>:8081
  static const String baseUrl = 'http://45.93.201.167:8081/api';

  // HTTP client
  final http.Client _client = http.Client();

  // Headers
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Auth headers (token bilan)
  Map<String, String> authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  /// Log helper
  void _log(String message) {
    developer.log(message, name: 'API');
    // ignore: avoid_print
    print('🔵 [API] $message');
  }

  /// POST so'rov yuborish
  Future<ApiResponse> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final url = '$baseUrl$endpoint';
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📤 POST: $url');
    _log('📦 Body: ${jsonEncode(body)}');
    _log('📋 Headers: ${token != null ? authHeaders(token) : _headers}');

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: token != null ? authHeaders(token) : _headers,
        body: jsonEncode(body),
      );

      _log('📥 Status Code: ${response.statusCode}');
      _log('📥 Response Headers: ${response.headers}');
      _log('📥 Response Body: ${response.body}');
      _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return _handleResponse(response);
    } catch (e, stackTrace) {
      _log('❌ Error: $e');
      _log('❌ StackTrace: $stackTrace');
      _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return ApiResponse(
        success: false,
        message: 'Server bilan bog\'lanib bo\'lmadi: $e',
      );
    }
  }

  /// GET so'rov yuborish
  Future<ApiResponse> get(String endpoint, {String? token}) async {
    final url = '$baseUrl$endpoint';
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📤 GET: $url');

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: token != null ? authHeaders(token) : _headers,
      );

      _log('📥 Status Code: ${response.statusCode}');
      _log('📥 Response Body: ${response.body}');
      _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return _handleResponse(response);
    } catch (e, stackTrace) {
      _log('❌ Error: $e');
      _log('❌ StackTrace: $stackTrace');
      return ApiResponse(
        success: false,
        message: 'Server bilan bog\'lanib bo\'lmadi: $e',
      );
    }
  }

  /// Response handling
  ApiResponse _handleResponse(http.Response response) {
    _log('🔄 Parsing response...');
    _log('🔄 Body length: ${response.body.length}');
    _log('🔄 Body content: "${response.body}"');

    // Status code tekshirish
    if (response.statusCode == 404) {
      _log('❌ 404 Not Found - endpoint mavjud emas!');
      return ApiResponse(
        success: false,
        message:
            'Server topilmadi (404). Backend ishlamayapti yoki endpoint mavjud emas.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode == 500) {
      _log('❌ 500 Internal Server Error');
      return ApiResponse(
        success: false,
        message: 'Server xatosi (500). Iltimos keyinroq urinib ko\'ring.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode == 502 || response.statusCode == 503) {
      _log('❌ Server unavailable: ${response.statusCode}');
      return ApiResponse(
        success: false,
        message: 'Server hozir mavjud emas. Iltimos keyinroq urinib ko\'ring.',
        statusCode: response.statusCode,
      );
    }

    // Bo'sh response tekshirish
    if (response.body.isEmpty) {
      _log('⚠️ Response body is empty!');
      return ApiResponse(
        success: false,
        message: 'Server bo\'sh javob qaytardi',
        statusCode: response.statusCode,
      );
    }

    try {
      final data = jsonDecode(response.body);
      _log('✅ JSON parsed successfully: $data');

      return ApiResponse(
        success: data['success'] ?? false,
        message: data['message'] ?? '',
        token: data['token'],
        user: data['user'] != null
            ? Map<String, dynamic>.from(data['user'])
            : null,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _log('❌ JSON parse error: $e');
      _log('❌ Raw body was: "${response.body}"');
      return ApiResponse(
        success: false,
        message: 'Server javobini o\'qib bo\'lmadi',
        statusCode: response.statusCode,
      );
    }
  }

  // ============================================
  // AUTH ENDPOINTS
  // ============================================

  /// OTP yuborish
  Future<ApiResponse> sendOtp(String phone) async {
    _log('📱 Sending OTP to: $phone');
    return await post('/auth/send-otp', {'phone': phone});
  }

  /// OTP tasdiqlash
  Future<ApiResponse> verifyOtp(String phone, String code) async {
    _log('🔐 Verifying OTP for: $phone, code: $code');
    return await post('/auth/verify-otp', {'phone': phone, 'code': code});
  }

  /// Ro'yxatdan o'tish
  Future<ApiResponse> register({
    required String fullName,
    required String phone,
    required String password,
  }) async {
    _log('📝 Registering: $fullName, $phone');
    return await post('/auth/register', {
      'full_name': fullName,
      'phone': phone,
      'password': password,
    });
  }

  /// Kirish
  Future<ApiResponse> login({
    required String phone,
    required String password,
  }) async {
    _log('🔑 Login attempt: $phone');
    return await post('/auth/login', {'phone': phone, 'password': password});
  }

  /// Parolni unutdim
  Future<ApiResponse> forgotPassword(String phone) async {
    _log('🔄 Forgot password: $phone');
    return await post('/auth/forgot-password', {'phone': phone});
  }

  /// Parolni tiklash
  Future<ApiResponse> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    _log('🔄 Reset password: $phone');
    return await post('/auth/reset-password', {
      'phone': phone,
      'code': code,
      'new_password': newPassword,
    });
  }

  // ============================================
  // PRODUCTS ENDPOINTS
  // ============================================

  /// Barcha mahsulotlarni olish
  Future<ProductsApiResponse> getProducts({String? category}) async {
    _log('🛋️ Fetching products... category=$category');
    final endpoint = category != null 
        ? '/products?category=$category' 
        : '/products';
    return await getProducts_(endpoint);
  }

  /// Yangi mahsulotlarni olish
  Future<ProductsApiResponse> getNewArrivals() async {
    _log('🆕 Fetching new arrivals...');
    return await getProducts_('/products/new');
  }

  /// Mashhur mahsulotlarni olish
  Future<ProductsApiResponse> getPopularProducts() async {
    _log('⭐ Fetching popular products...');
    return await getProducts_('/products/popular');
  }

  /// Products GET helper
  Future<ProductsApiResponse> getProducts_(String endpoint) async {
    final url = '$baseUrl$endpoint';
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📤 GET: $url');

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      _log('📥 Status Code: ${response.statusCode}');
      _log('📥 Response Body: ${response.body}');
      _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return _handleProductsResponse(response);
    } catch (e, stackTrace) {
      _log('❌ Error: $e');
      _log('❌ StackTrace: $stackTrace');
      return ProductsApiResponse(
        success: false,
        message: 'Server bilan bog\'lanib bo\'lmadi: $e',
        products: [],
        count: 0,
      );
    }
  }

  /// Products response handler
  ProductsApiResponse _handleProductsResponse(http.Response response) {
    if (response.body.isEmpty) {
      return ProductsApiResponse(
        success: false,
        message: 'Server bo\'sh javob qaytardi',
        products: [],
        count: 0,
      );
    }

    try {
      final data = jsonDecode(response.body);
      final productsList = (data['products'] as List?)
              ?.map((p) => p as Map<String, dynamic>)
              .toList() ??
          [];

      return ProductsApiResponse(
        success: data['success'] ?? false,
        message: data['message'] ?? '',
        products: productsList,
        count: data['count'] ?? 0,
      );
    } catch (e) {
      _log('❌ JSON parse error: $e');
      return ProductsApiResponse(
        success: false,
        message: 'Server javobini o\'qib bo\'lmadi',
        products: [],
        count: 0,
      );
    }
  }

  // ============================================
  // USER PROFILE ENDPOINTS
  // ============================================

  /// Profilni olish
  Future<ApiResponse> getProfile(String token) async {
    _log('👤 Fetching profile...');
    return await get('/user/me', token: token);
  }

  /// Profilni yangilash (multipart - ism va avatar)
  Future<ApiResponse> updateProfile({
    required String token,
    String? fullName,
    File? avatarFile,
  }) async {
    _log('✏️ Updating profile: fullName=$fullName, hasAvatar=${avatarFile != null}');
    return await multipartPut(
      '/user/me',
      token: token,
      fields: fullName != null ? {'full_name': fullName} : {},
      file: avatarFile,
      fileField: 'avatar',
    );
  }

  /// Hisobni o'chirish
  Future<ApiResponse> deleteAccount(String token) async {
    _log('🗑️ Deleting account...');
    return await delete('/user/me', token: token);
  }

  // ============================================
  // PHONE CHANGE ENDPOINTS
  // ============================================

  /// Telefon o'zgartirish - OTP so'rash
  Future<ApiResponse> requestPhoneChange({
    required String token,
    required String newPhone,
  }) async {
    _log('📞 Requesting phone change OTP: $newPhone');
    return await post(
      '/user/change-phone/request',
      {'new_phone': newPhone},
      token: token,
    );
  }

  /// Telefon o'zgartirish - OTP tasdiqlash
  Future<ApiResponse> verifyPhoneChange({
    required String token,
    required String newPhone,
    required String code,
  }) async {
    _log('📞 Verifying phone change: $newPhone, code: $code');
    return await post(
      '/user/change-phone/verify',
      {'new_phone': newPhone, 'code': code},
      token: token,
    );
  }

  // ============================================
  // EMAIL CHANGE ENDPOINTS
  // ============================================

  /// Email o'zgartirish - OTP so'rash
  Future<ApiResponse> requestEmailChange({
    required String token,
    required String newEmail,
  }) async {
    _log('📧 Requesting email change OTP: $newEmail');
    return await post(
      '/user/change-email/request',
      {'new_email': newEmail},
      token: token,
    );
  }

  /// Email o'zgartirish - OTP tasdiqlash
  Future<ApiResponse> verifyEmailChange({
    required String token,
    required String newEmail,
    required String code,
  }) async {
    _log('📧 Verifying email change: $newEmail, code: $code');
    return await post(
      '/user/change-email/verify',
      {'new_email': newEmail, 'code': code},
      token: token,
    );
  }

  /// PUT so'rov yuborish
  Future<ApiResponse> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final url = '$baseUrl$endpoint';
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📤 PUT: $url');
    _log('📦 Body: ${jsonEncode(body)}');

    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: token != null ? authHeaders(token) : _headers,
        body: jsonEncode(body),
      );

      _log('📥 Status Code: ${response.statusCode}');
      _log('📥 Response Body: ${response.body}');
      _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return _handleResponse(response);
    } catch (e, stackTrace) {
      _log('❌ Error: $e');
      _log('❌ StackTrace: $stackTrace');
      return ApiResponse(
        success: false,
        message: 'Server bilan bog\'lanib bo\'lmadi: $e',
      );
    }
  }

  /// DELETE so'rov yuborish
  Future<ApiResponse> delete(String endpoint, {String? token}) async {
    final url = '$baseUrl$endpoint';
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📤 DELETE: $url');

    try {
      final response = await _client.delete(
        Uri.parse(url),
        headers: token != null ? authHeaders(token) : _headers,
      );

      _log('📥 Status Code: ${response.statusCode}');
      _log('📥 Response Body: ${response.body}');
      _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return _handleResponse(response);
    } catch (e, stackTrace) {
      _log('❌ Error: $e');
      _log('❌ StackTrace: $stackTrace');
      return ApiResponse(
        success: false,
        message: 'Server bilan bog\'lanib bo\'lmadi: $e',
      );
    }
  }

  /// Multipart PUT so'rov yuborish (fayl yuklash uchun)
  Future<ApiResponse> multipartPut(
    String endpoint, {
    required String token,
    Map<String, String> fields = const {},
    File? file,
    String fileField = 'file',
  }) async {
    final url = '$baseUrl$endpoint';
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📤 MULTIPART PUT: $url');
    _log('📦 Fields: $fields');
    _log('📎 File: ${file?.path ?? "none"}');

    try {
      final request = http.MultipartRequest('PUT', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';

      // Text fieldlarni qo'shish
      request.fields.addAll(fields);

      // Fayl qo'shish (agar bor bo'lsa)
      if (file != null) {
        final fileStream = http.ByteStream(file.openRead());
        final length = await file.length();
        final filename = file.path.split('/').last;

        final multipartFile = http.MultipartFile(
          fileField,
          fileStream,
          length,
          filename: filename,
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _log('📥 Status Code: ${response.statusCode}');
      _log('📥 Response Body: ${response.body}');
      _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return _handleResponse(response);
    } catch (e, stackTrace) {
      _log('❌ Error: $e');
      _log('❌ StackTrace: $stackTrace');
      return ApiResponse(
        success: false,
        message: 'Server bilan bog\'lanib bo\'lmadi: $e',
      );
    }
  }
}

/// API javob modeli
class ApiResponse {
  final bool success;
  final String message;
  final String? token;
  final Map<String, dynamic>? user;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.statusCode,
  });

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode, token: ${token != null ? "***" : null}, user: $user)';
  }
}

/// Products API javob modeli
class ProductsApiResponse {
  final bool success;
  final String message;
  final List<Map<String, dynamic>> products;
  final int count;

  ProductsApiResponse({
    required this.success,
    required this.message,
    required this.products,
    required this.count,
  });

  @override
  String toString() {
    return 'ProductsApiResponse(success: $success, message: $message, count: $count)';
  }
}
