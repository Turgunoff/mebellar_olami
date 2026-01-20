import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API-related konstantalar.
class ApiConstants {
  /// Asosiy server manzili.
  static String get baseUrl => dotenv.env['BASE_URL'] ?? _defaultBaseUrl;

  /// Default bazaviy URL (agar .env berilmagan bo'lsa).
  static const String _defaultBaseUrl = 'https://api.mebellar-olami.uz/api';
}
