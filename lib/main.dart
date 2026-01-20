import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'core/init/app_initializer.dart';
import 'core/constants/app_theme.dart';
import 'core/widgets/app_providers.dart';
import 'core/widgets/connectivity_wrapper.dart';
import 'features/auth/presentation/widgets/auth_wrapper.dart';

void main() async {
  // Barcha sozlamalar shu yerda
  await AppInitializer.init();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('uz'), Locale('ru'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('uz'),
      startLocale: null,
      child: const MebellarOlamiApp(),
    ),
  );
}

class MebellarOlamiApp extends StatelessWidget {
  const MebellarOlamiApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Providerlar alohida faylda
    return AppProviders(
      child: MaterialApp(
        title: 'Mebellar Olami',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        // AuthWrapper alohida faylda
        home: const AuthWrapper(),
        builder: (context, child) {
          return ConnectivityWrapper(child: child!);
        },
      ),
    );
  }
}
