import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Service - Go Backend bilan bog'lanish
class ApiService {
  // Backend server manzili - .env faylidan olinadi
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'https://api.mebellar-olami.uz';

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

  /// Token ni SharedPreferences dan olish
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      _log('⚠️ Error getting token: $e');
      return null;
    }
  }

  /// Headers ni olish (token avtomatik qo'shiladi)
  Future<Map<String, String>> _getHeaders({String? explicitToken}) async {
    final token = explicitToken ?? await _getToken();
    if (token != null && token.isNotEmpty) {
      return authHeaders(token);
    }
    return _headers;
  }

  /// Log helper
  void _log(String message) {
    developer.log(message, name: 'API');
    // ignore: avoid_print
    print('🔵 [API] $message');
  }

  /// POST so'rov yuborish
  /// Token avtomatik SharedPreferences dan olinadi, agar explicitToken berilmasa
  Future<ApiResponse> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token, // Explicit token (optional, otherwise auto-fetched)
    bool requireAuth = false, // Agar true bo'lsa va token topilmasa xatolik qaytaradi
  }) async {
    final url = '${baseUrl}/api$endpoint';
    final headers = await _getHeaders(explicitToken: token);
    
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📤 POST: $url');
    _log('📦 Body: ${jsonEncode(body)}');
    _log('📋 Headers: $headers');

    // Agar auth talab qilinsa va token bo'lmasa
    if (requireAuth && !headers.containsKey('Authorization')) {
      _log('❌ Auth required but token not found');
      return ApiResponse(
        success: false,
        message: 'Tizimga kirish talab etiladi',
        statusCode: 401,
      );
    }

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: headers,
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
  /// Token avtomatik SharedPreferences dan olinadi, agar explicitToken berilmasa
  Future<ApiResponse> get(
    String endpoint, {
    String? token, // Explicit token (optional, otherwise auto-fetched)
    bool requireAuth = false, // Agar true bo'lsa va token topilmasa xatolik qaytaradi
  }) async {
    final url = '${baseUrl}/api$endpoint';
    final headers = await _getHeaders(explicitToken: token);
    
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📤 GET: $url');
    _log('📋 Headers: $headers');

    // Agar auth talab qilinsa va token bo'lmasa
    if (requireAuth && !headers.containsKey('Authorization')) {
      _log('❌ Auth required but token not found');
      return ApiResponse(
        success: false,
        message: 'Tizimga kirish talab etiladi',
        statusCode: 401,
      );
    }

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: headers,
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
    final url = '${baseUrl}/api$endpoint';
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
  // ORDERS ENDPOINTS
  // ============================================

  /// Yangi buyurtma yaratish
  Future<OrderApiResponse> createOrder({
    required String shopId,
    required String clientName,
    required String clientPhone,
    required String clientAddress,
    String? clientNote,
    required List<Map<String, dynamic>> items, // [{product_id, quantity}]
  }) async {
    _log('🛒 Creating order...');
    final url = '${baseUrl}/api/orders';
    
    final body = {
      'shop_id': shopId,
      'client_name': clientName,
      'client_phone': clientPhone,
      'client_address': clientAddress,
      if (clientNote != null && clientNote.isNotEmpty) 'client_note': clientNote,
      'items': items,
    };

    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📤 POST: $url');
    _log('📦 Body: ${jsonEncode(body)}');

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      );

      _log('📥 Status Code: ${response.statusCode}');
      _log('📥 Response Body: ${response.body}');
      _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return _handleOrderResponse(response);
    } catch (e, stackTrace) {
      _log('❌ Error: $e');
      _log('❌ StackTrace: $stackTrace');
      return OrderApiResponse(
        success: false,
        message: 'Server bilan bog\'lanib bo\'lmadi: $e',
      );
    }
  }

  /// Order response handler
  OrderApiResponse _handleOrderResponse(http.Response response) {
    if (response.statusCode == 401) {
      return OrderApiResponse(
        success: false,
        message: 'Tizimga kirish talab etiladi',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode == 404) {
      return OrderApiResponse(
        success: false,
        message: 'Server topilmadi (404)',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode == 500) {
      return OrderApiResponse(
        success: false,
        message: 'Server xatosi (500)',
        statusCode: response.statusCode,
      );
    }

    if (response.body.isEmpty) {
      return OrderApiResponse(
        success: false,
        message: 'Server bo\'sh javob qaytardi',
        statusCode: response.statusCode,
      );
    }

    try {
      final data = jsonDecode(response.body);
      return OrderApiResponse(
        success: data['success'] ?? false,
        message: data['message'] ?? '',
        order: data['order'] != null
            ? Map<String, dynamic>.from(data['order'])
            : null,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _log('❌ JSON parse error: $e');
      return OrderApiResponse(
        success: false,
        message: 'Server javobini o\'qib bo\'lmadi',
        statusCode: response.statusCode,
      );
    }
  }

  // ============================================
  // USER PROFILE ENDPOINTS
  // ============================================

  /// Profilni olish
  Future<ApiResponse> getProfile({String? token}) async {
    _log('👤 Fetching profile...');
    return await get('/user/me', token: token, requireAuth: true);
  }

  /// Profilni yangilash (multipart - ism va avatar)
  Future<ApiResponse> updateProfile({
    String? token,
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
  Future<ApiResponse> deleteAccount({String? token}) async {
    _log('🗑️ Deleting account...');
    return await delete('/user/me', token: token, requireAuth: true);
  }

  // ============================================
  // PHONE CHANGE ENDPOINTS
  // ============================================

  /// Telefon o'zgartirish - OTP so'rash
  Future<ApiResponse> requestPhoneChange({
    String? token,
    required String newPhone,
  }) async {
    _log('📞 Requesting phone change OTP: $newPhone');
    return await post(
      '/user/change-phone/request',
      {'new_phone': newPhone},
      token: token,
      requireAuth: true,
    );
  }

  /// Telefon o'zgartirish - OTP tasdiqlash
  Future<ApiResponse> verifyPhoneChange({
    String? token,
    required String newPhone,
    required String code,
  }) async {
    _log('📞 Verifying phone change: $newPhone, code: $code');
    return await post(
      '/user/change-phone/verify',
      {'new_phone': newPhone, 'code': code},
      token: token,
      requireAuth: true,
    );
  }

  // ============================================
  // EMAIL CHANGE ENDPOINTS
  // ============================================

  /// Email o'zgartirish - OTP so'rash
  Future<ApiResponse> requestEmailChange({
    String? token,
    required String newEmail,
  }) async {
    _log('📧 Requesting email change OTP: $newEmail');
    return await post(
      '/user/change-email/request',
      {'new_email': newEmail},
      token: token,
      requireAuth: true,
    );
  }

  /// Email o'zgartirish - OTP tasdiqlash
  Future<ApiResponse> verifyEmailChange({
    String? token,
    required String newEmail,
    required String code,
  }) async {
    _log('📧 Verifying email change: $newEmail, code: $code');
    return await post(
      '/user/change-email/verify',
      {'new_email': newEmail, 'code': code},
      token: token,
      requireAuth: true,
    );
  }

  /// PUT so'rov yuborish
  /// Token avtomatik SharedPreferences dan olinadi, agar explicitToken berilmasa
  Future<ApiResponse> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? token, // Explicit token (optional, otherwise auto-fetched)
    bool requireAuth = false,
  }) async {
    final url = '${baseUrl}/api$endpoint';
    final headers = await _getHeaders(explicitToken: token);
    
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📤 PUT: $url');
    _log('📦 Body: ${jsonEncode(body)}');
    _log('📋 Headers: $headers');

    if (requireAuth && !headers.containsKey('Authorization')) {
      _log('❌ Auth required but token not found');
      return ApiResponse(
        success: false,
        message: 'Tizimga kirish talab etiladi',
        statusCode: 401,
      );
    }

    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: headers,
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
  /// Token avtomatik SharedPreferences dan olinadi, agar explicitToken berilmasa
  Future<ApiResponse> delete(
    String endpoint, {
    String? token, // Explicit token (optional, otherwise auto-fetched)
    bool requireAuth = false,
  }) async {
    final url = '${baseUrl}/api$endpoint';
    final headers = await _getHeaders(explicitToken: token);
    
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📤 DELETE: $url');
    _log('📋 Headers: $headers');

    if (requireAuth && !headers.containsKey('Authorization')) {
      _log('❌ Auth required but token not found');
      return ApiResponse(
        success: false,
        message: 'Tizimga kirish talab etiladi',
        statusCode: 401,
      );
    }

    try {
      final response = await _client.delete(
        Uri.parse(url),
        headers: headers,
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
    String? token, // Explicit token (optional, otherwise auto-fetched)
    Map<String, String> fields = const {},
    File? file,
    String fileField = 'file',
  }) async {
    final url = '${baseUrl}/api$endpoint';
    final finalToken = token ?? await _getToken();
    
    if (finalToken == null || finalToken.isEmpty) {
      _log('❌ Token required for multipart request');
      return ApiResponse(
        success: false,
        message: 'Tizimga kirish talab etiladi',
        statusCode: 401,
      );
    }

    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📤 MULTIPART PUT: $url');
    _log('📦 Fields: $fields');
    _log('📎 File: ${file?.path ?? "none"}');

    try {
      final request = http.MultipartRequest('PUT', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $finalToken';

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

/// Order API javob modeli
class OrderApiResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? order;
  final int? statusCode;

  OrderApiResponse({
    required this.success,
    required this.message,
    this.order,
    this.statusCode,
  });

  @override
  String toString() {
    return 'OrderApiResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}
