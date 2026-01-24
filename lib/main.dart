import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/init/app_initializer.dart';
import 'core/constants/app_theme.dart';
import 'core/widgets/app_providers.dart';
import 'core/widgets/connectivity_wrapper.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  // Barcha sozlamalar shu yerda
  await AppInitializer.init();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('uz'), Locale('ru'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('uz'),
      saveLocale: true,
      child: const MebellarOlamiApp(),
    ),
  );
}

class MebellarOlamiApp extends StatefulWidget {
  const MebellarOlamiApp({super.key});

  @override
  State<MebellarOlamiApp> createState() => _MebellarOlamiAppState();
}

class _MebellarOlamiAppState extends State<MebellarOlamiApp> {
  AppRouter? _appRouter;

  @override
  Widget build(BuildContext context) {
    // Providerlar alohida faylda
    return AppProviders(
      child: Builder(
        builder: (context) {
          // Initialize router if not already done
          _appRouter ??= AppRouter(context.read<AuthBloc>());

          return MaterialApp.router(
            title: 'Mebellar Olami',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            // GoRouter configuration
            routerConfig: _appRouter!.router,
            builder: (context, child) {
              return ConnectivityWrapper(child: child!);
            },
          );
        },
      ),
    );
  }
}
