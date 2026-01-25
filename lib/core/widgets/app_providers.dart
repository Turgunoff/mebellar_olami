import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/dependency_injection.dart' as di;
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/catalog/presentation/bloc/catalog_bloc.dart';
import '../../features/profile/bloc/profile_bloc.dart';
import '../../features/search/presentation/bloc/search_bloc.dart';
import '../../features/products/data/repositories/product_repository.dart';
import '../../features/checkout/presentation/bloc/checkout_bloc.dart';
import '../../features/main/presentation/cubit/navigation_cubit.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => di.sl<AuthRepository>()),
        RepositoryProvider(create: (_) => di.sl<ProductRepository>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => di.sl<AuthBloc>()..add(const AuthCheckStatus()),
          ),
          BlocProvider(
            create: (context) {
              final favoritesBloc = di.sl<FavoritesBloc>();
              final authBloc = context.read<AuthBloc>();
              // Set AuthBloc reference in FavoritesBloc
              favoritesBloc.setAuthBloc(authBloc);
              favoritesBloc.add(const LoadFavorites());
              return favoritesBloc;
            },
          ),
          BlocProvider(create: (_) => di.sl<CartBloc>()..add(const LoadCart())),
          BlocProvider(
            create: (_) => di.sl<HomeBloc>()..add(const LoadHomeData()),
          ),
          BlocProvider(
            create: (_) => di.sl<CatalogBloc>()..add(const LoadCategories()),
          ),
          BlocProvider(create: (_) => di.sl<ProfileBloc>()),
          BlocProvider(
            create: (_) => di.sl<SearchBloc>()..add(const LoadSearchHistory()),
          ),
          BlocProvider(create: (_) => di.sl<CheckoutBloc>()),
          BlocProvider(create: (_) => NavigationCubit()),
        ],
        child: child,
      ),
    );
  }
}
