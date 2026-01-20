import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'core/local/hive_service.dart';
import 'core/di/dependency_injection.dart' as di;
import 'core/constants/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/widgets/connectivity_wrapper.dart';
import 'core/services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/user_provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/auth/welcome_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/favorites/bloc/favorites_bloc.dart';
import 'features/cart/bloc/cart_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize Hive storage and open required boxes
  await HiveService.init();

  // Setup dependency injection
  await di.setupDependencyInjection();

  // Initialize OneSignal notifications
  await NotificationService.initialize();

  // Tizim UI rangini sozlash
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MebellarOlamiApp());
}

/// Mebellar Olami - Premium Furniture Marketplace
/// Nabolen Style Design
class MebellarOlamiApp extends StatelessWidget {
  const MebellarOlamiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider(create: (_) => di.sl<AuthRepository>())],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                di.sl<AuthBloc>()..add(const AuthCheckStatus()),
          ),
          BlocProvider(
            create: (context) =>
                di.sl<FavoritesBloc>()..add(const LoadFavorites()),
          ),
          BlocProvider(
            create: (context) => di.sl<CartBloc>()..add(const LoadCart()),
          ),
        ],
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => FavoritesProvider()),
            ChangeNotifierProvider(create: (_) => OrdersProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => ProductProvider()),
            ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ],
          child: BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) =>
                current is AuthAuthenticated || current is AuthUnauthenticated,
            listener: (context, state) {
              final authProvider = context.read<AuthProvider>();
              if (state is AuthAuthenticated) {
                authProvider.checkAuthStatus();
              } else if (state is AuthUnauthenticated) {
                authProvider.logout();
              }
            },
            child: MaterialApp(
              title: 'Mebellar Olami',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              home: const _AuthWrapper(),
              builder: (context, child) {
                return ConnectivityWrapper(child: child!);
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Auth holatini tekshiruvchi wrapper
class _AuthWrapper extends StatefulWidget {
  const _AuthWrapper();

  @override
  State<_AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<_AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.weekend_rounded,
                      size: 50,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          return const MainScreen();
        }

        if (state.isOnboardingCompleted) {
          return const WelcomeScreen();
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: const OnboardingScreen(),
        );
      },
    );
  }
}
