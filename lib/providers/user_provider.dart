import 'dart:developer' as developer;
import 'dart:io';
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
  String? _email;
  String? _avatarUrl;
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
  String? get email => _email;
  String? get avatarUrl => _avatarUrl;
  String? get createdAt => _createdAt;

  /// Full avatar URL (server manzili bilan)
  String? get fullAvatarUrl {
    if (_avatarUrl == null || _avatarUrl!.isEmpty) return null;
    // Agar URL "/" bilan boshlansa, server URL qo'shamiz
    if (_avatarUrl!.startsWith('/')) {
      return 'http://45.93.201.167:8081$_avatarUrl';
    }
    return _avatarUrl;
  }

  /// Xatolikni tozalash
  void clearError() {
    _errorMessage = null;
    notifyListeners();
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
      final response = await _apiService.getProfile();
      _log('Response: $response');

      _isLoading = false;

      if (response.success && response.user != null) {
        _userId = response.user!['id']?.toString();
        _fullName = response.user!['full_name'];
        _phone = response.user!['phone'];
        _email = response.user!['email'];
        _avatarUrl = response.user!['avatar_url'];
        _createdAt = response.user!['created_at'];
        _log('✅ Profile fetched: $_fullName, $_phone, $_email, $_avatarUrl');
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
  // PROFILNI YANGILASH (ism va avatar)
  // ============================================
  Future<bool> updateProfile({String? newName, File? avatarFile}) async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('✏️ Updating profile: name=$newName, hasAvatar=${avatarFile != null}');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.updateProfile(
        fullName: newName,
        avatarFile: avatarFile,
      );
      _log('Response: $response');

      _isLoading = false;

      if (response.success) {
        if (response.user != null) {
          _fullName = response.user!['full_name'];
          _avatarUrl = response.user!['avatar_url'];
          _email = response.user!['email'];
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
      final response = await _apiService.deleteAccount();
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

  // ============================================
  // TELEFON O'ZGARTIRISH
  // ============================================

  /// Telefon o'zgartirish - OTP so'rash
  Future<bool> requestPhoneChange(String newPhone) async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📞 Requesting phone change OTP: $newPhone');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.requestPhoneChange(
        newPhone: newPhone,
      );

      _isLoading = false;

      if (response.success) {
        _log('✅ Phone change OTP sent');
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _log('❌ Phone change request failed: $_errorMessage');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _log('❌ Exception: $e');
      _isLoading = false;
      _errorMessage = 'Xatolik yuz berdi: $e';
      notifyListeners();
      return false;
    }
  }

  /// Telefon o'zgartirish - OTP tasdiqlash
  Future<bool> verifyPhoneChange(String newPhone, String code) async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📞 Verifying phone change: $newPhone');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.verifyPhoneChange(
        newPhone: newPhone,
        code: code,
      );

      _isLoading = false;

      if (response.success) {
        if (response.user != null) {
          _phone = response.user!['phone'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_phone', _phone ?? '');
        }
        _log('✅ Phone changed successfully');
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _log('❌ Phone change verification failed: $_errorMessage');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _log('❌ Exception: $e');
      _isLoading = false;
      _errorMessage = 'Xatolik yuz berdi: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // EMAIL O'ZGARTIRISH
  // ============================================

  /// Email o'zgartirish - OTP so'rash
  Future<bool> requestEmailChange(String newEmail) async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📧 Requesting email change OTP: $newEmail');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.requestEmailChange(
        newEmail: newEmail,
      );

      _isLoading = false;

      if (response.success) {
        _log('✅ Email change OTP sent');
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _log('❌ Email change request failed: $_errorMessage');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _log('❌ Exception: $e');
      _isLoading = false;
      _errorMessage = 'Xatolik yuz berdi: $e';
      notifyListeners();
      return false;
    }
  }

  /// Email o'zgartirish - OTP tasdiqlash
  Future<bool> verifyEmailChange(String newEmail, String code) async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📧 Verifying email change: $newEmail');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.verifyEmailChange(
        newEmail: newEmail,
        code: code,
      );

      _isLoading = false;

      if (response.success) {
        if (response.user != null) {
          _email = response.user!['email'];
        }
        _log('✅ Email changed successfully');
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _log('❌ Email change verification failed: $_errorMessage');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _log('❌ Exception: $e');
      _isLoading = false;
      _errorMessage = 'Xatolik yuz berdi: $e';
      notifyListeners();
      return false;
    }
  }

  /// Provider ni reset qilish
  void reset() {
    _userId = null;
    _fullName = null;
    _phone = null;
    _email = null;
    _avatarUrl = null;
    _createdAt = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
