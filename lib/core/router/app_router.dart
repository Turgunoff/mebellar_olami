import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/dependency_injection.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/products/presentation/bloc/product_detail_bloc.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/success_screen.dart';
import '../../features/auth/presentation/screens/verify_code_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/checkout/presentation/screens/map_selection_screen.dart';
import '../../features/checkout/presentation/screens/order_success_screen.dart';
import '../../features/main/presentation/screens/main_screen.dart';
import '../../features/products/data/models/product_model.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../utils/navigation_observer.dart';
import '../utils/route_names.dart';

/// AppRouter - GoRouter configuration with auth guards
class AppRouter {
  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'root',
  );

  late final GoRouter router;

  AppRouter(AuthBloc authBloc) {
    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: RoutePaths.main,
      debugLogDiagnostics: true,
      observers: [AppNavigationObserver()],

      // Auth redirect logic
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        final isAuthenticated = authState is AuthAuthenticated;
        final isOnboardingCompleted = authState.isOnboardingCompleted;
        final isLoading = authState is AuthLoading || authState is AuthInitial;

        // Current location
        final currentLocation = state.matchedLocation;

        // Auth-related paths
        final isAuthRoute =
            currentLocation == RoutePaths.login ||
            currentLocation == RoutePaths.signup ||
            currentLocation == RoutePaths.welcome ||
            currentLocation == RoutePaths.onboarding ||
            currentLocation == RoutePaths.forgotPassword ||
            currentLocation == RoutePaths.resetPassword ||
            currentLocation.startsWith('/verify-code');

        // If still loading auth state, don't redirect
        if (isLoading) {
          return null;
        }

        // If not completed onboarding and not on onboarding screen
        if (!isOnboardingCompleted &&
            currentLocation != RoutePaths.onboarding) {
          return RoutePaths.onboarding;
        }

        // If user is authenticated and on auth routes, redirect to main
        if (isAuthenticated && isAuthRoute) {
          return RoutePaths.main;
        }

        // Allow access to all routes (guest mode supported)
        return null;
      },

      // Refresh when auth state changes
      refreshListenable: GoRouterRefreshStream(authBloc.stream),

      routes: [
        // Main screen (dashboard with bottom navigation)
        GoRoute(
          path: RoutePaths.main,
          name: RouteNames.main,
          builder: (context, state) => const MainScreen(),
        ),

        // Onboarding
        GoRoute(
          path: RoutePaths.onboarding,
          name: RouteNames.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),

        // Welcome screen
        GoRoute(
          path: RoutePaths.welcome,
          name: RouteNames.welcome,
          builder: (context, state) => const WelcomeScreen(),
        ),

        // Login
        GoRoute(
          path: RoutePaths.login,
          name: RouteNames.login,
          builder: (context, state) {
            final isFromOnboarding =
                state.uri.queryParameters['fromOnboarding'] == 'true';
            return LoginScreen(isFromOnboarding: isFromOnboarding);
          },
        ),

        // Signup
        GoRoute(
          path: RoutePaths.signup,
          name: RouteNames.signup,
          builder: (context, state) => const SignUpScreen(),
        ),

        // Forgot password
        GoRoute(
          path: RoutePaths.forgotPassword,
          name: RouteNames.forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // Reset password
        GoRoute(
          path: RoutePaths.resetPassword,
          name: RouteNames.resetPassword,
          builder: (context, state) {
            final phone = state.uri.queryParameters['phone'] ?? '';
            return ResetPasswordScreen(phone: phone);
          },
        ),

        // Verify code
        GoRoute(
          path: RoutePaths.verifyCode,
          name: RouteNames.verifyCode,
          builder: (context, state) {
            final phone = state.uri.queryParameters['phone'] ?? '';
            final isRegistration =
                state.uri.queryParameters['isRegistration'] == 'true';
            final isPasswordReset =
                state.uri.queryParameters['isPasswordReset'] == 'true';
            return VerifyCodeScreen(
              phone: phone,
              isRegistration: isRegistration,
              isPasswordReset: isPasswordReset,
            );
          },
        ),

        // Success screen
        GoRoute(
          path: RoutePaths.success,
          name: RouteNames.success,
          builder: (context, state) {
            final title = state.uri.queryParameters['title'] ?? '';
            final subtitle = state.uri.queryParameters['subtitle'] ?? '';
            final isPasswordReset =
                state.uri.queryParameters['isPasswordReset'] == 'true';
            return SuccessScreen(
              title: title,
              subtitle: subtitle,
              isPasswordReset: isPasswordReset,
            );
          },
        ),

        // Product detail
        GoRoute(
          path: RoutePaths.productDetail,
          name: RouteNames.productDetail,
          builder: (context, state) {
            final productId = state.pathParameters['productId'] ?? '';
            return BlocProvider(
              create: (context) => sl<ProductDetailBloc>(),
              child: ProductDetailScreen(productId: productId),
            );
          },
        ),

        // Search
        GoRoute(
          path: RoutePaths.search,
          name: RouteNames.search,
          builder: (context, state) => const SearchScreen(),
        ),

        // Cart
        GoRoute(
          path: RoutePaths.cart,
          name: RouteNames.cart,
          builder: (context, state) => const CartScreen(),
        ),

        // Edit profile
        GoRoute(
          path: RoutePaths.editProfile,
          name: RouteNames.editProfile,
          builder: (context, state) => const EditProfileScreen(),
        ),

        // Checkout
        GoRoute(
          path: RoutePaths.checkout,
          name: RouteNames.checkout,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            if (extra == null) {
              // If no extra data, go back to main
              return const MainScreen();
            }
            return CheckoutScreen(
              product: extra['product'] as ProductModel,
              selectedColor: extra['selectedColor'] as String?,
              quantity: extra['quantity'] as int? ?? 1,
            );
          },
        ),

        // Order success
        GoRoute(
          path: RoutePaths.orderSuccess,
          name: RouteNames.orderSuccess,
          builder: (context, state) => const OrderSuccessScreen(),
        ),

        // Map selection
        GoRoute(
          path: RoutePaths.mapSelection,
          name: RouteNames.mapSelection,
          builder: (context, state) => const MapSelectionScreen(),
        ),
      ],

      // Error page
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Sahifa topilmadi: ${state.matchedLocation}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.goNamed(RouteNames.main),
                child: const Text('Asosiy sahifaga qaytish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// GoRouter refresh stream for auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
