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
    add(LoadCategoryProducts(categoryId: event.category.id));
  }

  Future<void> _onLoadCategoryProducts(
    LoadCategoryProducts event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(productsStatus: CatalogProductsStatus.loading));

    try {
      final result = await productRepository.getProducts(
        category: event.categoryId,
      );

      if (result['success'] == true) {
        final products = (result['products'] as List? ?? [])
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();

        emit(
          state.copyWith(
            productsStatus: CatalogProductsStatus.loaded,
            products: products,
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

  void _onGoBackToCategories(
    GoBackToCategories event,
    Emitter<CatalogState> emit,
  ) {
    emit(
      state.copyWith(selectedCategory: null, showProducts: false, products: []),
    );
  }
}
