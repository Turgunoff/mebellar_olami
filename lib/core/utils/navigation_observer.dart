import 'package:flutter/material.dart';

/// Navigation observer to track screen flow in the app
/// Provides detailed logs for navigation events
class AppNavigationObserver extends NavigatorObserver {
  static const String _tag = '[NAV]';

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final routeName = _getRouteName(route);
    debugPrint('$_tag 📲 OPEN: $routeName');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final routeName = _getRouteName(route);
    debugPrint('$_tag ⬅️ CLOSE: $routeName');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final oldRouteName = _getRouteName(oldRoute);
    final newRouteName = _getRouteName(newRoute);
    debugPrint('$_tag 🔀 REPLACE: $oldRouteName -> $newRouteName');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    final routeName = _getRouteName(route);
    debugPrint('$_tag 🗑️ REMOVE: $routeName');
  }

  /// Extract route name from route settings
  /// Returns 'Anonymous Route' if name is null
  String _getRouteName(Route<dynamic>? route) {
    if (route == null) return 'Unknown Route';
    return route.settings.name ?? 'Anonymous Route';
  }
}

/*
 * USAGE TIPS:
 * 
 * 1. Add to MaterialApp in main.dart:
 *    MaterialApp(
 *      navigatorObservers: [AppNavigationObserver()],
 *      // ... other properties
 *    )
 * 
 * 2. For better logging, always provide RouteSettings.name:
 *    Navigator.push(
 *      context,
 *      MaterialPageRoute(
 *        builder: (context) => LoginScreen(),
 *        settings: RouteSettings(name: '/login'),
 *      ),
 *    )
 * 
 * 3. Example console output:
 *    [NAV] 📲 OPEN: /splash
 *    [NAV] 🔀 REPLACE: /splash -> /login
 *    [NAV] 📲 OPEN: /dashboard
 *    [NAV] ⬅️ CLOSE: /dashboard
 */
