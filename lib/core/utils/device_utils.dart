import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

/// Qurilma haqida ma'lumotlar va app type bilan ishlash uchun utility class.
class DeviceUtils {
  static const String _deviceIdKey = 'unique_device_id';
  static const String _boxName = 'device_box';

  static String? _cachedDeviceId;
  static Box? _deviceBox;

  // OS va App versiya ma'lumotlari
  static String? _osType;
  static String? _osVersion;
  static String? _appVersion;
  static String? _deviceName;

  /// Hive box'ni ochish (ilova boshida chaqiriladi)
  static Future<void> init() async {
    _deviceBox = await Hive.openBox(_boxName);
    await _ensureDeviceId();
    await _initDeviceInfo();
  }

  /// OS va App versiya ma'lumotlarini olish
  static Future<void> _initDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      // OS type va versiyasini olish
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _osType = 'Android';
        _osVersion = androidInfo.version.release;
        _deviceName = "${androidInfo.brand} ${androidInfo.model}";
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _osType = 'iOS';
        _osVersion = iosInfo.systemVersion;
        _deviceName = iosInfo.name;
      } else {
        _osType = Platform.operatingSystem;
        _osVersion = Platform.operatingSystemVersion;
        _deviceName = Platform.localHostname;
      }

      // App versiyasini olish
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      _osType = Platform.operatingSystem;
      _osVersion = '';
      _appVersion = '';
      _deviceName = '';
    }
  }

  /// Unique Device ID ni olish.
  /// Agar oldin yaratilgan bo'lsa, o'sha ID ni qaytaradi.
  /// Agar yo'q bo'lsa, yangi UUID yaratadi va saqlaydi.
  static Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    await _ensureDeviceId();
    return _cachedDeviceId!;
  }

  /// Sinxron versiyasi (init() chaqirilgandan keyin ishlatish mumkin)
  static String get deviceId {
    if (_cachedDeviceId == null) {
      throw StateError(
        'DeviceUtils.init() must be called before accessing deviceId synchronously',
      );
    }
    return _cachedDeviceId!;
  }

  /// App type ni olish - bu ilova xaridor (client) ilovasi
  static String getAppType() {
    return 'client';
  }

  /// OS type ni olish (iOS, Android)
  static String get osType => _osType ?? Platform.operatingSystem;

  /// OS versiyasini olish (17.2, 14.0)
  static String get osVersion => _osVersion ?? '';

  /// App versiyasini olish (1.0.0+1)
  static String get appVersion => _appVersion ?? '';

  /// Qurilma nomini olish (iPhone 15 Pro, Samsung Galaxy S21)
  static String get deviceName => _deviceName ?? '';

  /// Asinxron OS type olish (init chaqirilmagan bo'lsa)
  static Future<String> getOSType() async {
    if (_osType != null) return _osType!;
    await _initDeviceInfo();
    return _osType ?? Platform.operatingSystem;
  }

  /// Asinxron OS versiya olish
  static Future<String> getOSVersion() async {
    if (_osVersion != null) return _osVersion!;
    await _initDeviceInfo();
    return _osVersion ?? '';
  }

  /// Asinxron App versiya olish
  static Future<String> getAppVersion() async {
    if (_appVersion != null) return _appVersion!;
    await _initDeviceInfo();
    return _appVersion ?? '';
  }

  /// Asinxron qurilma nomi olish
  static Future<String> getDeviceName() async {
    if (_deviceName != null) return _deviceName!;
    await _initDeviceInfo();
    return _deviceName ?? '';
  }

  /// Device ID mavjudligini ta'minlash
  static Future<void> _ensureDeviceId() async {
    if (_deviceBox == null) {
      _deviceBox = await Hive.openBox(_boxName);
    }

    // Avval saqlangan ID ni tekshirish
    final savedId = _deviceBox!.get(_deviceIdKey) as String?;

    if (savedId != null && savedId.isNotEmpty) {
      _cachedDeviceId = savedId;
      return;
    }

    // Yangi unique ID yaratish
    final newDeviceId = await _generateUniqueDeviceId();
    await _deviceBox!.put(_deviceIdKey, newDeviceId);
    _cachedDeviceId = newDeviceId;
  }

  /// Unique device ID yaratish
  /// Qurilma ma'lumotlari + UUID kombinatsiyasi
  static Future<String> _generateUniqueDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceIdentifier = '';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Android ID yoki fingerprint ishlatish
        deviceIdentifier = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // iOS da identifierForVendor ishlatish
        deviceIdentifier = iosInfo.identifierForVendor ?? '';
      }
    } catch (e) {
      // Qurilma ma'lumotlarini olishda xato bo'lsa, faqat UUID ishlatish
      deviceIdentifier = '';
    }

    // Agar qurilma identifikatori bo'sh bo'lsa, UUID yaratish
    if (deviceIdentifier.isEmpty) {
      deviceIdentifier = const Uuid().v4();
    }

    return deviceIdentifier;
  }

  /// Qurilma haqida qo'shimcha ma'lumotlar (debug uchun)
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final Map<String, dynamic> info = {};

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        info['platform'] = 'android';
        info['model'] = androidInfo.model;
        info['brand'] = androidInfo.brand;
        info['version'] = androidInfo.version.release;
        info['sdk'] = androidInfo.version.sdkInt;
        info['device_name'] = "${androidInfo.brand} ${androidInfo.model}";
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        info['platform'] = 'ios';
        info['model'] = iosInfo.model;
        info['name'] = iosInfo.name;
        info['version'] = iosInfo.systemVersion;
        info['device_name'] = iosInfo.name;
      }
    } catch (e) {
      info['error'] = e.toString();
    }

    info['device_id'] = await getDeviceId();
    info['app_type'] = getAppType();

    return info;
  }
}
