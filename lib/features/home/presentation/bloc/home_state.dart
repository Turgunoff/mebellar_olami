part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<ProductModel> newArrivals;
  final List<ProductModel> popularProducts;
  final List<CategoryModel> categories;

  const HomeLoaded({
    required this.newArrivals,
    required this.popularProducts,
    required this.categories,
  });

  @override
  List<Object> get props => [newArrivals, popularProducts, categories];

  HomeLoaded copyWith({
    List<ProductModel>? newArrivals,
    List<ProductModel>? popularProducts,
    List<CategoryModel>? categories,
  }) {
    return HomeLoaded(
      newArrivals: newArrivals ?? this.newArrivals,
      popularProducts: popularProducts ?? this.popularProducts,
      categories: categories ?? this.categories,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
