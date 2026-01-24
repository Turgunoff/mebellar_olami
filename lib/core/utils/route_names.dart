/// Route names for navigation tracking
/// Use these constants with go_router for type-safe navigation
class RouteNames {
  // Auth routes
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String welcome = 'welcome';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String forgotPassword = 'forgot-password';
  static const String resetPassword = 'reset-password';
  static const String verifyCode = 'verify-code';
  static const String success = 'success';

  // Main routes
  static const String main = 'main';
  static const String home = 'home';
  static const String catalog = 'catalog';
  static const String favorites = 'favorites';
  static const String profile = 'profile';
  static const String editProfile = 'edit-profile';
  static const String search = 'search';

  // Product routes
  static const String productDetail = 'product-detail';
  static const String categoryProducts = 'category-products';
  static const String checkout = 'checkout';
  static const String orderSuccess = 'order-success';
  static const String mapSelection = 'map-selection';

  // Other routes
  static const String settings = 'settings';
  static const String about = 'about';
}

/// Route paths for go_router
class RoutePaths {
  // Auth routes
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyCode = '/verify-code';
  static const String success = '/success';

  // Main routes
  static const String main = '/';
  static const String search = '/search';

  // Product routes
  static const String productDetail = '/product/:productId';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String mapSelection = '/map-selection';

  // Profile routes
  static const String editProfile = '/edit-profile';
}

/*
 * USAGE EXAMPLE WITH GO_ROUTER:
 * 
 * Navigate by name:
 * context.pushNamed(RouteNames.login);
 * 
 * Navigate with parameters:
 * context.pushNamed(
 *   RouteNames.productDetail,
 *   pathParameters: {'productId': product.id},
 * );
 * 
 * Replace current route:
 * context.goNamed(RouteNames.main);
 * 
 * Go back:
 * context.pop();
 */
