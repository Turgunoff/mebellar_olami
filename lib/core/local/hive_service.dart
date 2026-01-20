import 'package:hive_flutter/hive_flutter.dart';

/// Hive storage helper to manage commonly used boxes.
class HiveService {
  static const String authBoxName = 'authBox';
  static const String cartBoxName = 'cartBox';
  static const String favoritesBoxName = 'favoritesBox';
  static const String searchHistoryBoxName = 'searchHistoryBox';

  /// Initialize Hive and open all required boxes before app start.
  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(authBoxName),
      Hive.openBox(cartBoxName),
      Hive.openBox(favoritesBoxName),
      Hive.openBox(searchHistoryBoxName),
    ]);
  }

  static Box<dynamic> get authBox => Hive.box(authBoxName);
  static Box<dynamic> get cartBox => Hive.box(cartBoxName);
  static Box<dynamic> get favoritesBox => Hive.box(favoritesBoxName);
  static Box<dynamic> get searchHistoryBox => Hive.box(searchHistoryBoxName);

  // Helper methods for common operations
  static Future<void> clearAllBoxes() async {
    await Future.wait([
      authBox.clear(),
      cartBox.clear(),
      favoritesBox.clear(),
      searchHistoryBox.clear(),
    ]);
  }

  // Token management
  static String? get accessToken => authBox.get('accessToken');
  static String? get refreshToken => authBox.get('refreshToken');
  static Future<void> saveTokens({
    String? accessToken,
    String? refreshToken,
  }) async {
    if (accessToken != null) await authBox.put('accessToken', accessToken);
    if (refreshToken != null) await authBox.put('refreshToken', refreshToken);
  }

  static Future<void> clearTokens() async {
    await authBox.delete('accessToken');
    await authBox.delete('refreshToken');
  }

  static bool get hasToken => accessToken != null && accessToken!.isNotEmpty;
}
