import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// OneSignal orqali push notificationlarni boshqarish xizmati
class NotificationService {
  static const String _appId = 'a81db172-c5b3-4616-a014-42f8a05d8ca3';
  static bool _isInitialized = false;

  /// OneSignalni ishga tushirish
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // OneSignalni sozlash
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      // OneSignalni ishga tushirish
      OneSignal.initialize(_appId);

      // Notification permission so'rash
      final permission = await OneSignal.Notifications.requestPermission(true);
      debugPrint('Notification permission: $permission');

      // Push notification handlerlarini o'rnatish
      _setupNotificationHandlers();

      _isInitialized = true;
      debugPrint('OneSignal initialized successfully');
    } catch (e) {
      debugPrint('OneSignal initialization failed: $e');
    }
  }

  /// Notification handlerlarini o'rnatish
  static void _setupNotificationHandlers() {
    // Notification ochilganda
    OneSignal.Notifications.addClickListener((OSNotificationClickEvent event) {
      debugPrint(
        'Notification clicked: ${event.notification.jsonRepresentation}',
      );

      // Kelajakda notification turiga qarab harakat qilish mumkin
      // Masalan: buyurtma statusi o'zgarganda buyurtma detailga o'tish
      _handleNotificationClick(event);
    });

    // Notification qabul qilinganda (foregroundda)
    OneSignal.Notifications.addForegroundWillDisplayListener((
      OSNotificationWillDisplayEvent event,
    ) {
      debugPrint(
        'Notification received in foreground: ${event.notification.jsonRepresentation}',
      );

      // Notificationni ko'rsatish (hozircha to'g'ridan-to'g'ri ko'rsatamiz)
      // event.complete(); // Bu method yo'q deb o'ylayman
    });

    // Subscription holatini tinglash
    OneSignal.User.pushSubscription.addObserver((state) {
      debugPrint('Push subscription state: ${state.jsonRepresentation}');
    });
  }

  /// Notification click hodisasini qayta ishlash
  static void _handleNotificationClick(OSNotificationClickEvent event) {
    final notification = event.notification;
    final additionalData = notification.additionalData;

    if (additionalData != null) {
      final type = additionalData['type'] as String?;
      final id = additionalData['id'] as String?;

      switch (type) {
        case 'order_status':
          // Buyurtma statusi o'zgarganda
          debugPrint('Order status notification clicked: $id');
          // Buyurtma detail screeniga o'tish
          break;
        case 'promotion':
          // Aksiya/reklama notificationi
          debugPrint('Promotion notification clicked: $id');
          // Aksiya screeniga o'tish
          break;
        case 'new_product':
          // Yangi mahsulot notificationi
          debugPrint('New product notification clicked: $id');
          // Mahsulot detail screeniga o'tish
          break;
        default:
          debugPrint('Unknown notification type: $type');
      }
    }
  }

  /// Foydalanuvchi ID ni o'rnatish (backend user_id bilan bog'lash uchun)
  static Future<void> setUserId(String userId) async {
    try {
      await OneSignal.login(userId);
      debugPrint('OneSignal user ID set: $userId');
    } catch (e) {
      debugPrint('Failed to set OneSignal user ID: $e');
    }
  }

  /// Foydalanuvchi tildan chiqarish
  static Future<void> logout() async {
    try {
      await OneSignal.logout();
      debugPrint('OneSignal user logged out');
    } catch (e) {
      debugPrint('Failed to logout from OneSignal: $e');
    }
  }

  /// Foydalanuvchi ma'lumotlarini yangilash
  static Future<void> updateUserProperties({
    String? name,
    String? email,
    String? phone,
    Map<String, dynamic>? additionalProperties,
  }) async {
    try {
      final properties = <String, dynamic>{};

      if (name != null) properties['name'] = name;
      if (email != null) properties['email'] = email;
      if (phone != null) properties['phone'] = phone;

      if (additionalProperties != null) {
        properties.addAll(additionalProperties);
      }

      // Yangi OneSignal SDK versiyasida addProperties o'rniga setTags orqali qilamiz
      // Asosiy ma'lumotlar uchun alohida tags
      final tags = <String, String>{};

      if (name != null) tags['name'] = name;
      if (email != null) tags['email'] = email;
      if (phone != null) tags['phone'] = phone;

      if (additionalProperties != null) {
        additionalProperties.forEach((key, value) {
          tags[key] = value.toString();
        });
      }

      OneSignal.User.addTags(tags);
      debugPrint('OneSignal user properties updated: $properties');
    } catch (e) {
      debugPrint('Failed to update OneSignal user properties: $e');
    }
  }

  /// Taglarni o'rnatish (segmentatsiya uchun)
  static Future<void> setTags(Map<String, String> tags) async {
    try {
      OneSignal.User.addTags(tags);
      debugPrint('OneSignal tags set: $tags');
    } catch (e) {
      debugPrint('Failed to set OneSignal tags: $e');
    }
  }

  /// Push subscription holatini olish
  static Future<bool> isSubscribedToPush() async {
    try {
      final subscription = OneSignal.User.pushSubscription;
      return subscription.optedIn ?? false;
    } catch (e) {
      debugPrint('Failed to get push subscription state: $e');
      return false;
    }
  }

  /// OneSignal player ID ni olish
  static Future<String?> getPlayerId() async {
    try {
      final subscription = OneSignal.User.pushSubscription;
      return subscription.id;
    } catch (e) {
      debugPrint('Failed to get OneSignal player ID: $e');
      return null;
    }
  }

  /// Test notification yuborish (faqat debug rejimda)
  static Future<void> sendTestNotification() async {
    if (kDebugMode) {
      try {
        // Bu faqat test uchun, haqiqiy notification backenddan yuborilishi kerak
        debugPrint('Test notification would be sent here');
      } catch (e) {
        debugPrint('Failed to send test notification: $e');
      }
    }
  }
}
