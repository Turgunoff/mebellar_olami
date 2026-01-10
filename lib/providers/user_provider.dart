import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/api_service.dart';

/// User Profile Provider
/// Foydalanuvchi profili bilan ishlash uchun
class UserProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Holat o'zgaruvchilari
  bool _isLoading = false;
  String? _errorMessage;

  // Foydalanuvchi ma'lumotlari
  String? _userId;
  String? _fullName;
  String? _phone;
  String? _createdAt;

  /// Log helper
  void _log(String message) {
    developer.log(message, name: 'USER');
    // ignore: avoid_print
    print('🟣 [USER] $message');
  }

  // Getterlar
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userId => _userId;
  String? get fullName => _fullName;
  String? get phone => _phone;
  String? get createdAt => _createdAt;

  /// Xatolikni tozalash
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Token ni SharedPreferences dan olish
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // ============================================
  // PROFILNI OLISH
  // ============================================
  Future<bool> fetchUserProfile() async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('👤 Fetching user profile...');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _log('❌ Token not found');
        _isLoading = false;
        _errorMessage = 'Tizimga kirish talab etiladi';
        notifyListeners();
        return false;
      }

      final response = await _apiService.getProfile(token);
      _log('Response: $response');

      _isLoading = false;

      if (response.success && response.user != null) {
        _userId = response.user!['id']?.toString();
        _fullName = response.user!['full_name'];
        _phone = response.user!['phone'];
        _createdAt = response.user!['created_at'];
        _log('✅ Profile fetched: $_fullName, $_phone');
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _log('❌ Fetch profile failed: $_errorMessage');
        notifyListeners();
        return false;
      }
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
  // PROFILNI YANGILASH
  // ============================================
  Future<bool> updateProfile(String newName) async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('✏️ Updating profile: $newName');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _log('❌ Token not found');
        _isLoading = false;
        _errorMessage = 'Tizimga kirish talab etiladi';
        notifyListeners();
        return false;
      }

      final response = await _apiService.updateProfile(
        token: token,
        fullName: newName,
      );
      _log('Response: $response');

      _isLoading = false;

      if (response.success) {
        if (response.user != null) {
          _fullName = response.user!['full_name'];
          // SharedPreferences ni yangilash
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_name', _fullName ?? '');
        }
        _log('✅ Profile updated successfully');
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _log('❌ Update profile failed: $_errorMessage');
        notifyListeners();
        return false;
      }
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
  // HISOBNI O'CHIRISH
  // ============================================
  Future<bool> deleteAccount() async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('🗑️ Deleting account...');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _log('❌ Token not found');
        _isLoading = false;
        _errorMessage = 'Tizimga kirish talab etiladi';
        notifyListeners();
        return false;
      }

      final response = await _apiService.deleteAccount(token);
      _log('Response: $response');

      _isLoading = false;

      if (response.success) {
        // Local storage ni tozalash
        await _clearAllData();
        _log('✅ Account deleted successfully');
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _log('❌ Delete account failed: $_errorMessage');
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      _log('❌ Exception: $e');
      _log('❌ StackTrace: $stackTrace');
      _isLoading = false;
      _errorMessage = 'Xatolik yuz berdi: $e';
      notifyListeners();
      return false;
    }
  }

  /// Barcha ma'lumotlarni tozalash
  Future<void> _clearAllData() async {
    _log('🧹 Clearing all local data...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    await prefs.remove('user_id');

    _userId = null;
    _fullName = null;
    _phone = null;
    _createdAt = null;
    _log('✅ All data cleared');
  }

  /// Provider ni reset qilish
  void reset() {
    _userId = null;
    _fullName = null;
    _phone = null;
    _createdAt = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
