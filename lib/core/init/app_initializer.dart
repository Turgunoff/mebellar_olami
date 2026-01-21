import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../local/hive_service.dart';
import '../di/dependency_injection.dart' as di;
import '../services/notification_service.dart';
import '../constants/app_colors.dart';
import '../utils/device_utils.dart';

class AppInitializer {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Load Environment variables
    await dotenv.load(fileName: ".env");

    // 2. Initialize Hive
    await HiveService.init();

    // 3. Initialize Device Utils (Device ID generation)
    await DeviceUtils.init();

    // 4. Setup Dependency Injection
    await di.setupDependencyInjection();

    // 5. Initialize Notifications
    await NotificationService.initialize();

    // 5. System UI Settings
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
}
