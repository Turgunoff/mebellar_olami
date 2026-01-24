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
  // Netflix-style caching: Map<categoryId, List<ProductModel>>
  final Map<String, List<ProductModel>> cachedProducts;
  // Track which categories have been fetched (even if empty) to avoid redundant API calls
  final Set<String> fetchedCategories;
  // Main category cache: Map<parentId, List<ProductModel>> for "All" tab data
  final Map<String, List<ProductModel>> mainCategoryCache;
  // Track which parent categories have been loaded for "All" tab
  final Set<String> loadedMainCategories;

  const CatalogState({
    this.status = CatalogStatus.initial,
    this.productsStatus = CatalogProductsStatus.initial,
    this.categories = const [],
    this.products = const [],
    this.selectedCategory,
    this.showProducts = false,
    this.errorMessage,
    this.cachedProducts = const {},
    this.fetchedCategories = const {},
    this.mainCategoryCache = const {},
    this.loadedMainCategories = const {},
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
    Map<String, List<ProductModel>>? cachedProducts,
    Set<String>? fetchedCategories,
    Map<String, List<ProductModel>>? mainCategoryCache,
    Set<String>? loadedMainCategories,
  }) {
    return CatalogState(
      status: status ?? this.status,
      productsStatus: productsStatus ?? this.productsStatus,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      showProducts: showProducts ?? this.showProducts,
      errorMessage: errorMessage ?? this.errorMessage,
      cachedProducts: cachedProducts ?? this.cachedProducts,
      fetchedCategories: fetchedCategories ?? this.fetchedCategories,
      mainCategoryCache: mainCategoryCache ?? this.mainCategoryCache,
      loadedMainCategories: loadedMainCategories ?? this.loadedMainCategories,
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
    cachedProducts,
    fetchedCategories,
    mainCategoryCache,
    loadedMainCategories,
  ];
}
