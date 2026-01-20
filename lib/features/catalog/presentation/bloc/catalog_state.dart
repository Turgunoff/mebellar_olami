part of 'catalog_bloc.dart';

enum CatalogStatus { initial, loading, loaded, error }

enum CatalogProductsStatus { initial, loading, loaded, error }

class CatalogState extends Equatable {
  final CatalogStatus status;
  final CatalogProductsStatus productsStatus;
  final List<CategoryModel> categories;
  final List<ProductModel> products;
  final CategoryModel? selectedCategory;
  final bool showProducts;
  final String? errorMessage;

  const CatalogState({
    this.status = CatalogStatus.initial,
    this.productsStatus = CatalogProductsStatus.initial,
    this.categories = const [],
    this.products = const [],
    this.selectedCategory,
    this.showProducts = false,
    this.errorMessage,
  });

  bool get isLoading => status == CatalogStatus.loading;
  bool get isLoaded => status == CatalogStatus.loaded;
  bool get hasError => status == CatalogStatus.error;
  bool get isProductsLoading => productsStatus == CatalogProductsStatus.loading;

  CatalogState copyWith({
    CatalogStatus? status,
    CatalogProductsStatus? productsStatus,
    List<CategoryModel>? categories,
    List<ProductModel>? products,
    CategoryModel? selectedCategory,
    bool? showProducts,
    String? errorMessage,
  }) {
    return CatalogState(
      status: status ?? this.status,
      productsStatus: productsStatus ?? this.productsStatus,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      showProducts: showProducts ?? this.showProducts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    productsStatus,
    categories,
    products,
    selectedCategory,
    showProducts,
    errorMessage,
  ];
}
