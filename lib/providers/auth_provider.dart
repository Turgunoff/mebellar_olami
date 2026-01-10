import 'package:flutter/foundation.dart';

/// Autentifikatsiya holati provideri
/// Kelajakda backend bilan integratsiya qilinadi
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userName;
  String? _userPhone;
  String? _userAddress;

  /// Foydalanuvchi tizimga kirganmi?
  bool get isLoggedIn => _isLoggedIn;

  /// Foydalanuvchi ismi
  String? get userName => _userName;

  /// Foydalanuvchi telefon raqami
  String? get userPhone => _userPhone;

  /// Foydalanuvchi manzili
  String? get userAddress => _userAddress;

  /// Mehmon rejimida
  bool get isGuest => !_isLoggedIn;

  /// Tizimga kirish (Mock)
  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    // Mock delay - backend simulyatsiyasi
    await Future.delayed(const Duration(seconds: 1));

    // Mock muvaffaqiyatli kirish
    _isLoggedIn = true;
    _userName = 'Alisher Karimov';
    _userPhone = phone;
    _userAddress = 'Toshkent sh., Chilonzor t., 12-uy, 45-xonadon';

    notifyListeners();
    return true;
  }

  /// Ro'yxatdan o'tish (Mock)
  Future<bool> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    // Mock delay
    await Future.delayed(const Duration(seconds: 1));

    _isLoggedIn = true;
    _userName = name;
    _userPhone = phone;
    _userAddress = null;

    notifyListeners();
    return true;
  }

  /// Tizimdan chiqish
  void logout() {
    _isLoggedIn = false;
    _userName = null;
    _userPhone = null;
    _userAddress = null;
    notifyListeners();
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
