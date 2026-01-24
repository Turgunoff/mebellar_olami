import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

part 'product_detail_event.dart';
part 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final ProductRepository _productRepository;

  ProductDetailBloc({required ProductRepository productRepository})
    : _productRepository = productRepository,
      super(ProductDetailInitial()) {
    on<LoadProductDetails>(_onLoadProductDetails);
    on<RefreshProductDetails>(_onRefreshProductDetails);
  }

  Future<void> _onLoadProductDetails(
    LoadProductDetails event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(ProductDetailLoading());

    try {
      // Get product details
      final productResult = await _productRepository.getProductDetails(
        event.productId,
      );

      if (!productResult['success']) {
        emit(
          ProductDetailError(productResult['message'] ?? 'Mahsulot topilmadi'),
        );
        return;
      }

      final productData = productResult['product'] as Map<String, dynamic>;
      final product = ProductModel.fromJson(productData);

      // Get related products (recommended products from same category)
      List<ProductModel> relatedProducts = [];

      // Safely check category
      final dynamic category = product.category;
      bool hasCategory = false;
      if (category != null) {
        if (category is String) {
          hasCategory = category.isNotEmpty;
        } else if (category is Map) {
          hasCategory = category.isNotEmpty;
        }
      }

      if (hasCategory && category is String) {
        final relatedResult = await _productRepository.getRecommendedProducts(
          category: category,
          limit: 8,
          excludeIds: [product.id],
        );

        if (relatedResult['success']) {
          final relatedData = relatedResult['products'] as List;
          relatedProducts = relatedData
              .map(
                (item) => ProductModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      }

      emit(
        ProductDetailLoaded(product: product, relatedProducts: relatedProducts),
      );
    } catch (e) {
      emit(ProductDetailError('Xatolik yuz berdi: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshProductDetails(
    RefreshProductDetails event,
    Emitter<ProductDetailState> emit,
  ) async {
    // Reuse the same logic as LoadProductDetails
    await _onLoadProductDetails(LoadProductDetails(event.productId), emit);
  }
}
