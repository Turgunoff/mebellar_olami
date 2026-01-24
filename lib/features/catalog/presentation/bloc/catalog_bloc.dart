import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../products/data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../data/repositories/category_repository.dart';

part 'catalog_event.dart';
part 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final ProductRepository productRepository;
  final CategoryRepository categoryRepository;

  CatalogBloc({
    required this.productRepository,
    required this.categoryRepository,
  }) : super(const CatalogState()) {
    on<LoadCategories>(_onLoadCategories);
    on<SelectCategory>(_onSelectCategory);
    on<LoadCategoryProducts>(_onLoadCategoryProducts);
    on<LoadGroupedProductsPreview>(_onLoadGroupedProductsPreview);
    on<SwitchToSubCategory>(_onSwitchToSubCategory);
    on<GoBackToCategories>(_onGoBackToCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(status: CatalogStatus.loading));

    try {
      final result = await categoryRepository.getCategories();

      if (result['success'] == true) {
        final cats = result['categories'] as List? ?? [];
        final categories = cats
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();

        emit(
          state.copyWith(status: CatalogStatus.loaded, categories: categories),
        );
      } else {
        emit(
          state.copyWith(
            status: CatalogStatus.error,
            errorMessage: result['message']?.toString() ?? 'Xatolik yuz berdi',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: CatalogStatus.error,
          errorMessage: 'Kategoriyalarni yuklashda xatolik: $e',
        ),
      );
    }
  }

  void _onSelectCategory(SelectCategory event, Emitter<CatalogState> emit) {
    emit(state.copyWith(selectedCategory: event.category, showProducts: true));
    add(LoadCategoryProducts(categoryId: event.category.id, parentId: null));
  }

  Future<void> _onLoadCategoryProducts(
    LoadCategoryProducts event,
    Emitter<CatalogState> emit,
  ) async {
    // Check if loading "All" tab (parentId != null, categoryId == null)
    final isMainCategory = event.parentId != null && event.categoryId == null;

    // Smart cache check for "All" tab - avoid redundant API calls
    if (isMainCategory && !event.forceRefresh) {
      if (state.loadedMainCategories.contains(event.parentId!)) {
        // Use cached "All" data - instant switching with 0ms latency
        final cachedMainProducts =
            state.mainCategoryCache[event.parentId!] ?? [];
        emit(
          state.copyWith(
            products: cachedMainProducts,
            productsStatus: CatalogProductsStatus.loaded,
          ),
        );
        // NO API CALL - instant switching
        return;
      }
    }

    emit(state.copyWith(productsStatus: CatalogProductsStatus.loading));

    try {
      final result = await productRepository.getProducts(
        categoryId: event.categoryId,
        parentId: event.parentId,
      );

      if (result['success'] == true) {
        final products = (result['products'] as List? ?? [])
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Update caches
        final updatedCache = Map<String, List<ProductModel>>.from(
          state.cachedProducts,
        );
        final updatedFetched = Set<String>.from(state.fetchedCategories);
        final updatedMainCache = Map<String, List<ProductModel>>.from(
          state.mainCategoryCache,
        );
        final updatedLoadedMain = Set<String>.from(state.loadedMainCategories);

        if (isMainCategory) {
          // Save to main category cache for "All" tab
          updatedMainCache[event.parentId!] = products;
          updatedLoadedMain.add(event.parentId!);
        } else if (event.categoryId != null) {
          // Save to sub-category cache
          updatedCache[event.categoryId!] = products;
          updatedFetched.add(event.categoryId!);
        }

        emit(
          state.copyWith(
            productsStatus: CatalogProductsStatus.loaded,
            products: products,
            cachedProducts: updatedCache,
            fetchedCategories: updatedFetched,
            mainCategoryCache: updatedMainCache,
            loadedMainCategories: updatedLoadedMain,
          ),
        );
      } else {
        emit(
          state.copyWith(
            productsStatus: CatalogProductsStatus.error,
            errorMessage: result['message']?.toString() ?? 'Xatolik yuz berdi',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          productsStatus: CatalogProductsStatus.error,
          errorMessage: 'Mahsulotlarni yuklashda xatolik: $e',
        ),
      );
    }
  }

  Future<void> _onLoadGroupedProductsPreview(
    LoadGroupedProductsPreview event,
    Emitter<CatalogState> emit,
  ) async {
    try {
      final result = await productRepository.getProductsGroupedBySubcategory(
        parentId: event.parentId,
        limitPerCat: event.limitPerCat,
      );

      if (result['success'] == true) {
        final groups = result['groups'] as List? ?? [];
        final Map<String, List<ProductModel>> newCache = {};
        final Set<String> newFetchedCategories = Set<String>.from(
          state.fetchedCategories,
        );

        for (final group in groups) {
          final groupData = group as Map<String, dynamic>;
          final categoryId = groupData['category']?['id']?.toString() ?? '';
          final productsList = (groupData['products'] as List? ?? [])
              .map(
                (json) => ProductModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();

          if (categoryId.isNotEmpty) {
            // Cache the products (even if empty list - this is valid data)
            newCache[categoryId] = productsList;
            // Mark this category as fetched (even if empty)
            newFetchedCategories.add(categoryId);
          }
        }

        // Merge with existing cache
        final updatedCache = Map<String, List<ProductModel>>.from(
          state.cachedProducts,
        );
        updatedCache.addAll(newCache);

        emit(
          state.copyWith(
            cachedProducts: updatedCache,
            fetchedCategories: newFetchedCategories,
            productsStatus: CatalogProductsStatus.loaded,
          ),
        );
      } else {
        emit(
          state.copyWith(
            productsStatus: CatalogProductsStatus.error,
            errorMessage: result['message']?.toString() ?? 'Xatolik yuz berdi',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          productsStatus: CatalogProductsStatus.error,
          errorMessage: 'Preview mahsulotlarni yuklashda xatolik: $e',
        ),
      );
    }
  }

  Future<void> _onSwitchToSubCategory(
    SwitchToSubCategory event,
    Emitter<CatalogState> emit,
  ) async {
    // Check if this category has already been fetched (even if empty)
    // This prevents redundant API calls for categories we already know about
    if (event.useCache && state.fetchedCategories.contains(event.categoryId)) {
      // Use cached products (even if empty list - this is valid data from grouped preview)
      final cachedProducts = state.cachedProducts[event.categoryId] ?? [];
      emit(
        state.copyWith(
          products: cachedProducts,
          productsStatus: CatalogProductsStatus.loaded,
        ),
      );
      // NO API CALL - instant switching with 0ms latency
      return;
    }

    // Only make API call if category hasn't been fetched yet
    emit(state.copyWith(productsStatus: CatalogProductsStatus.loading));
    add(LoadCategoryProducts(categoryId: event.categoryId, parentId: null));
  }

  void _onGoBackToCategories(
    GoBackToCategories event,
    Emitter<CatalogState> emit,
  ) {
    emit(
      state.copyWith(
        selectedCategory: null,
        showProducts: false,
        products: [],
        cachedProducts: {}, // Clear cache when going back
        fetchedCategories: {}, // Clear fetched categories tracking
        mainCategoryCache: {}, // Clear main category cache
        loadedMainCategories: {}, // Clear loaded main categories tracking
      ),
    );
  }
}
