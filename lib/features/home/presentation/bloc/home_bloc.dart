import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../catalog/data/models/category_model.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../catalog/data/repositories/category_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;

  HomeBloc({
    required ProductRepository productRepository,
    required CategoryRepository categoryRepository,
  }) : _productRepository = productRepository,
       _categoryRepository = categoryRepository,
       super(const HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      final results = await Future.wait([
        _productRepository.getNewProducts(),
        _productRepository.getPopularProducts(),
        _categoryRepository.getCategories(),
      ]);

      final newArrivalsResponse = results[0] as Map<String, dynamic>;
      final popularProductsResponse = results[1] as Map<String, dynamic>;
      final categories = results[2] as List<CategoryModel>;

      final newArrivals =
          (newArrivalsResponse['products'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      final popularProducts =
          (popularProductsResponse['products'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      emit(
        HomeLoaded(
          newArrivals: newArrivals,
          popularProducts: popularProducts,
          categories: categories,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final results = await Future.wait([
        _productRepository.getNewProducts(),
        _productRepository.getPopularProducts(),
        _categoryRepository.getCategories(),
      ]);

      final newArrivalsResponse = results[0] as Map<String, dynamic>;
      final popularProductsResponse = results[1] as Map<String, dynamic>;
      final categories = results[2] as List<CategoryModel>;

      final newArrivals =
          (newArrivalsResponse['products'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      final popularProducts =
          (popularProductsResponse['products'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      emit(
        HomeLoaded(
          newArrivals: newArrivals,
          popularProducts: popularProducts,
          categories: categories,
        ),
      );
    } catch (e) {
      if (state is HomeLoaded) {
        emit(state);
      } else {
        emit(HomeError(e.toString()));
      }
    }
  }
}
