import 'package:flutter/material.dart';

import 'core/init/app_initializer.dart';
import 'core/constants/app_theme.dart';
import 'core/widgets/app_providers.dart';
import 'core/widgets/connectivity_wrapper.dart';
import 'features/auth/presentation/widgets/auth_wrapper.dart';

void main() async {
  // Barcha sozlamalar shu yerda
  await AppInitializer.init();

  runApp(const MebellarOlamiApp());
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
        // AuthWrapper alohida faylda
        home: const AuthWrapper(),
        builder: (context, child) {
          return ConnectivityWrapper(child: child!);
        },
      ),
    );
  }
}
