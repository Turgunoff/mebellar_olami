import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/favorites/data/repositories/favorites_repository.dart';
import '../../features/favorites/bloc/favorites_bloc.dart';
import '../../features/cart/data/repositories/cart_repository.dart';
import '../../features/cart/bloc/cart_bloc.dart';
import '../../features/products/data/repositories/product_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Core
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // Features - Auth
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(dioClient: sl<DioClient>()),
  );
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      repository: sl<AuthRepository>(),
      favoritesBloc: sl<FavoritesBloc>(),
    ),
  );

  // Features - Favorites
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepository(dioClient: sl<DioClient>()),
  );
  sl.registerFactory<FavoritesBloc>(
    () => FavoritesBloc(repository: sl<FavoritesRepository>()),
  );

  // Features - Cart
  sl.registerLazySingleton<CartRepository>(() => CartRepository());
  sl.registerFactory<CartBloc>(
    () => CartBloc(repository: sl<CartRepository>()),
  );

  // Features - Products
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepository(dioClient: sl<DioClient>()),
  );
}
