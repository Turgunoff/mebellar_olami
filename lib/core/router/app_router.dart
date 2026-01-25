import 'dart:async';

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
        final currentLocation = state.matchedLocation;

        print(
          '🔀 GoRouter redirect: currentLocation=$currentLocation, authState=${authState.runtimeType}, isOnboardingCompleted=${authState.isOnboardingCompleted}',
        );

        // Define route checks
        final isGoingToOnboarding = currentLocation == RoutePaths.onboarding;
        final isGoingToWelcome = currentLocation == RoutePaths.welcome;
        final isGoingToLogin = currentLocation == RoutePaths.login;
        final isGoingToSignup = currentLocation == RoutePaths.signup;
        final isGoingToLoginOrSignup = isGoingToLogin || isGoingToSignup;
        final isGoingToAuthFlow =
            isGoingToLoginOrSignup ||
            currentLocation == RoutePaths.forgotPassword ||
            currentLocation == RoutePaths.resetPassword ||
            currentLocation.startsWith('/verify-code');

        // If still loading auth state, don't redirect
        if (authState is AuthLoading || authState is AuthInitial) {
          print('🔀 GoRouter: Auth still loading, no redirect');
          return null;
        }

        // 1. Check Onboarding Required
        // If onboarding is not completed, redirect to onboarding (unless already there)
        if (!authState.isOnboardingCompleted) {
          if (isGoingToOnboarding) {
            print('🔀 GoRouter: Already on onboarding, no redirect');
            return null; // Allow access to onboarding
          }
          print('🔀 GoRouter: Redirecting to onboarding');
          return RoutePaths.onboarding; // Redirect to onboarding
        }

        // 2. Check Unauthenticated (onboarding completed but not logged in)
        if (authState is AuthUnauthenticated) {
          // Allow access to welcome and auth flows
          if (isGoingToWelcome || isGoingToAuthFlow) {
            print('🔀 GoRouter: Allowing access to welcome/auth flow');
            return null;
          }
          // Redirect to welcome for all other routes (including onboarding after completion)
          print('🔀 GoRouter: Redirecting to welcome');
          return RoutePaths.welcome;
        }

        // 3. Check Authenticated (fully logged in users)
        if (authState is AuthAuthenticated) {
          // If user is authenticated but tries to go to auth/onboarding/welcome -> Send to Home
          if (isGoingToLoginOrSignup ||
              isGoingToOnboarding ||
              isGoingToWelcome ||
              isGoingToAuthFlow) {
            print('🔀 GoRouter: User authenticated, redirecting to main');
            return RoutePaths.main;
          }
        }

        // 4. Check Guest (guests can browse but need login for some features)
        if (authState is AuthGuest) {
          // Guests MUST be allowed to access /login and /signup to upgrade their account
          if (isGoingToLoginOrSignup) {
            print('🔀 GoRouter: Guest accessing login/signup, allowing access');
            return null; // Allow access to login/signup
          }
          // If guest tries to go to other auth flows (onboarding/welcome) -> Send to Home
          if (isGoingToOnboarding || isGoingToWelcome) {
            print('🔀 GoRouter: Guest accessing onboarding/welcome, redirecting to main');
            return RoutePaths.main;
          }
        }

        // No redirect needed
        print('🔀 GoRouter: No redirect needed');
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
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    print('🔄 GoRouterRefreshStream: Initialized');
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((event) {
      print(
        '🔄 GoRouterRefreshStream: Stream event received, notifying listeners. Event: $event',
      );
      notifyListeners();
    });
  }

  @override
  void dispose() {
    print('🔄 GoRouterRefreshStream: Disposing');
    _subscription.cancel();
    super.dispose();
  }
}
