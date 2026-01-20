class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://api.mebellar.uz';
  static const String apiVersion = 'v1';
  static const String fullApiUrl = '$baseUrl/$apiVersion';

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/categories';
  static const String cartEndpoint = '/cart';
  static const String favoritesEndpoint = '/favorites';
  static const String ordersEndpoint = '/orders';

  // Timeout durations
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // Storage Keys
  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';
  static const String userIdKey = 'userId';
  static const String userProfileKey = 'userProfile';

  // App Settings
  static const String appName = 'Mebellar Olami';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Settings
  static const int cacheMaxAge = 3600; // 1 hour in seconds
  static const int maxCacheSize = 100; // Maximum number of cached items
}
