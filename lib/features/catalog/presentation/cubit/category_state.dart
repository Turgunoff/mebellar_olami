part of 'category_cubit.dart';

enum CategoryStatus { initial, loading, loaded, error }

class CategoryState extends Equatable {
  final CategoryStatus status;
  final List<CategoryModel> categories;
  final String? errorMessage;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.errorMessage,
  });

  bool get isLoading => status == CategoryStatus.loading;
  bool get isLoaded => status == CategoryStatus.loaded;
  bool get hasError => status == CategoryStatus.error;

  CategoryState copyWith({
    CategoryStatus? status,
    List<CategoryModel>? categories,
    String? errorMessage,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, categories, errorMessage];
}
