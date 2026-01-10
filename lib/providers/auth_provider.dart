import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/api_service.dart';

/// Autentifikatsiya holati provideri
/// Go backend bilan integratsiya qilingan
class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _token;
  int? _userId;
  String? _userName;
  String? _userPhone;
  String? _userAddress;
  String? _errorMessage;

  // OTP tasdiqlangan telefonlar (registration uchun)
  final Set<String> _verifiedPhones = {};

  /// Log helper
  void _log(String message) {
    developer.log(message, name: 'AUTH');
    // ignore: avoid_print
    print('🟢 [AUTH] $message');
  }

  /// Foydalanuvchi tizimga kirganmi?
  bool get isLoggedIn => _isLoggedIn;

  /// Yuklanmoqdami?
  bool get isLoading => _isLoading;

  /// Foydalanuvchi ismi
  String? get userName => _userName;

  /// Foydalanuvchi telefon raqami
  String? get userPhone => _userPhone;

  /// Foydalanuvchi manzili
  String? get userAddress => _userAddress;

  /// Token
  String? get token => _token;

  /// User ID
  int? get userId => _userId;

  /// Xatolik xabari
  String? get errorMessage => _errorMessage;

  /// Mehmon rejimida
  bool get isGuest => !_isLoggedIn;

  /// Telefon tasdiqlangan mi?
  bool isPhoneVerified(String phone) => _verifiedPhones.contains(phone);

  /// Xatolikni tozalash
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Ilovani ochishda saqlangan token'ni tekshirish
  Future<void> checkAuthStatus() async {
    _log('Checking auth status...');
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userName = prefs.getString('user_name');
    _userPhone = prefs.getString('user_phone');
    _userId = prefs.getInt('user_id');

    _log('Token: ${_token != null ? "exists" : "null"}');
    _log('UserName: $_userName');
    _log('UserPhone: $_userPhone');

    if (_token != null && _token!.isNotEmpty) {
      _isLoggedIn = true;
      _log('User is logged in');
    } else {
      _log('User is not logged in');
    }
    notifyListeners();
  }

  /// Token va foydalanuvchi ma'lumotlarini saqlash
  Future<void> _saveAuthData(String token, Map<String, dynamic>? user) async {
    _log('Saving auth data...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    if (user != null) {
      await prefs.setString('user_name', user['full_name'] ?? '');
      await prefs.setString('user_phone', user['phone'] ?? '');
      await prefs.setInt('user_id', user['id'] ?? 0);
      _log('Auth data saved: ${user['full_name']}');
    }
  }

  /// Saqlangan ma'lumotlarni o'chirish
  Future<void> _clearAuthData() async {
    _log('Clearing auth data...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    await prefs.remove('user_id');
    _log('Auth data cleared');
  }

  // ============================================
  // OTP YUBORISH
  // ============================================
  Future<bool> sendOtp(String phone) async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📱 sendOtp called: $phone');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.sendOtp(phone);
      _log('Response: $response');

      _isLoading = false;
      if (!response.success) {
        _errorMessage = response.message;
        _log('❌ OTP failed: $_errorMessage');
      } else {
        _log('✅ OTP sent successfully');
      }
      notifyListeners();
      return response.success;
    } catch (e, stackTrace) {
      _log('❌ Exception: $e');
      _log('❌ StackTrace: $stackTrace');
      _isLoading = false;
      _errorMessage = 'Xatolik yuz berdi: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // OTP TASDIQLASH
  // ============================================
  Future<bool> verifyOtp(String phone, String code) async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('🔐 verifyOtp called: $phone, code: $code');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.verifyOtp(phone, code);
      _log('Response: $response');

      _isLoading = false;
      if (response.success) {
        _verifiedPhones.add(phone);
        _log('✅ OTP verified, phone added to verified list');
      } else {
        _errorMessage = response.message;
        _log('❌ OTP verification failed: $_errorMessage');
      }
      notifyListeners();
      return response.success;
    } catch (e, stackTrace) {
      _log('❌ Exception: $e');
      _log('❌ StackTrace: $stackTrace');
      _isLoading = false;
      _errorMessage = 'Xatolik yuz berdi: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // RO'YXATDAN O'TISH
  // ============================================
  Future<bool> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📝 register called: $name, $phone');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.register(
        fullName: name,
        phone: phone,
        password: password,
      );
      _log('Response: $response');

      _isLoading = false;

      if (response.success) {
        _token = response.token;
        _isLoggedIn = true;
        _log('✅ Registration successful, token received');

        if (response.user != null) {
          _userId = response.user!['id'];
          _userName = response.user!['full_name'];
          _userPhone = response.user!['phone'];
          _log('User data: $_userName, $_userPhone');
        }

        // Ma'lumotlarni saqlash
        if (_token != null) {
          await _saveAuthData(_token!, response.user);
        }

        // Verified listdan o'chirish
        _verifiedPhones.remove(phone);
      } else {
        _errorMessage = response.message;
        _log('❌ Registration failed: $_errorMessage');
      }

      notifyListeners();
      return response.success;
    } catch (e, stackTrace) {
      _log('❌ Exception: $e');
      _log('❌ StackTrace: $stackTrace');
      _isLoading = false;
      _errorMessage = 'Xatolik yuz berdi: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // KIRISH (LOGIN)
  // ============================================
  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('🔑 login called: $phone');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(
        phone: phone,
        password: password,
      );
      _log('Response: $response');

      _isLoading = false;

      if (response.success) {
        _token = response.token;
        _isLoggedIn = true;
        _log('✅ Login successful, token received');

        if (response.user != null) {
          _userId = response.user!['id'];
          _userName = response.user!['full_name'];
          _userPhone = response.user!['phone'];
          _log('User data: $_userName, $_userPhone');
        }

        // Ma'lumotlarni saqlash
        if (_token != null) {
          await _saveAuthData(_token!, response.user);
        }
      } else {
        _errorMessage = response.message;
        _log('❌ Login failed: $_errorMessage');
      }

      notifyListeners();
      return response.success;
    } catch (e, stackTrace) {
      _log('❌ Exception: $e');
      _log('❌ StackTrace: $stackTrace');
      _isLoading = false;
      _errorMessage = 'Xatolik yuz berdi: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // PAROLNI UNUTDIM
  // ============================================
  Future<bool> forgotPassword(String phone) async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('🔄 forgotPassword called: $phone');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.forgotPassword(phone);
      _log('Response: $response');

      _isLoading = false;
      if (!response.success) {
        _errorMessage = response.message;
        _log('❌ Forgot password failed: $_errorMessage');
      } else {
        _log('✅ Forgot password OTP sent');
      }
      notifyListeners();
      return response.success;
    } catch (e, stackTrace) {
      _log('❌ Exception: $e');
      _log('❌ StackTrace: $stackTrace');
      _isLoading = false;
      _errorMessage = 'Xatolik yuz berdi: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // PAROLNI TIKLASH
  // ============================================
  Future<bool> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('🔄 resetPassword called: $phone, code: $code');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.resetPassword(
        phone: phone,
        code: code,
        newPassword: newPassword,
      );
      _log('Response: $response');

      _isLoading = false;
      if (!response.success) {
        _errorMessage = response.message;
        _log('❌ Reset password failed: $_errorMessage');
      } else {
        _log('✅ Password reset successful');
      }
      notifyListeners();
      return response.success;
    } catch (e, stackTrace) {
      _log('❌ Exception: $e');
      _log('❌ StackTrace: $stackTrace');
      _isLoading = false;
      _errorMessage = 'Xatolik yuz berdi: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // TIZIMDAN CHIQISH
  // ============================================
  Future<void> logout() async {
    _log('🚪 Logout called');
    _isLoggedIn = false;
    _token = null;
    _userId = null;
    _userName = null;
    _userPhone = null;
    _userAddress = null;
    _errorMessage = null;

    await _clearAuthData();
    notifyListeners();
    _log('✅ Logged out');
  }

  /// Foydalanuvchi ma'lumotlarini yangilash
  void updateUserInfo({
    String? name,
    String? phone,
    String? address,
  }) {
    if (name != null) _userName = name;
    if (phone != null) _userPhone = phone;
    if (address != null) _userAddress = address;
    notifyListeners();
  }
}
