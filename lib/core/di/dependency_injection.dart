import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/favorites/data/repositories/favorites_repository.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/cart/data/repositories/cart_repository.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/products/data/repositories/product_repository.dart';
import '../../features/products/presentation/bloc/product_detail_bloc.dart';
import '../../features/search/presentation/bloc/search_bloc.dart';
import '../../features/search/data/repositories/search_repository.dart';
import '../../features/catalog/data/repositories/category_repository.dart';
import '../../features/catalog/presentation/bloc/catalog_bloc.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/bloc/profile_bloc.dart';
import '../../features/checkout/data/repositories/order_repository.dart';
import '../../features/checkout/presentation/bloc/checkout_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Core
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // Features - Products (register first as it's used by other blocs)
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepository(dioClient: sl<DioClient>()),
  );
  sl.registerFactory<ProductDetailBloc>(
    () => ProductDetailBloc(productRepository: sl<ProductRepository>()),
  );

  // Features - Catalog
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepository(sl<DioClient>()),
  );
  sl.registerFactory<CatalogBloc>(
    () => CatalogBloc(
      productRepository: sl<ProductRepository>(),
      categoryRepository: sl<CategoryRepository>(),
    ),
  );

  // Features - Favorites
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepository(dioClient: sl<DioClient>()),
  );
  sl.registerLazySingleton<FavoritesBloc>(
    () => FavoritesBloc(repository: sl<FavoritesRepository>()),
  );

  // Features - Auth
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(dioClient: sl<DioClient>()),
  );
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      repository: sl<AuthRepository>(),
      favoritesBloc: sl<FavoritesBloc>(),
    ),
  );

  // Features - Cart
  sl.registerLazySingleton<CartRepository>(() => CartRepository());
  sl.registerFactory<CartBloc>(
    () => CartBloc(repository: sl<CartRepository>()),
  );

  // Features - Search
  sl.registerLazySingleton<SearchRepository>(() => SearchRepository());
  sl.registerFactory<SearchBloc>(
    () => SearchBloc(
      searchRepository: sl<SearchRepository>(),
      productRepository: sl<ProductRepository>(),
    ),
  );

  // Features - Home
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(
      productRepository: sl<ProductRepository>(),
      categoryRepository: sl<CategoryRepository>(),
    ),
  );

  // Features - Profile
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(dioClient: sl<DioClient>()),
  );
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(repository: sl<ProfileRepository>()),
  );

  // Features - Checkout
  sl.registerLazySingleton<OrderRepository>(() => OrderRepository());
  sl.registerFactory<CheckoutBloc>(
    () => CheckoutBloc(orderRepository: sl<OrderRepository>()),
  );
}
