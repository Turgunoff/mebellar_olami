part of 'product_detail_bloc.dart';

abstract class ProductDetailState extends Equatable {
  const ProductDetailState();

  @override
  List<Object> get props => [];
}

class ProductDetailInitial extends ProductDetailState {}

class ProductDetailLoading extends ProductDetailState {}

class ProductDetailLoaded extends ProductDetailState {
  final ProductModel product;
  final List<ProductModel> relatedProducts;

  const ProductDetailLoaded({
    required this.product,
    this.relatedProducts = const [],
  });

  @override
  List<Object> get props => [product, relatedProducts];

  ProductDetailLoaded copyWith({
    ProductModel? product,
    List<ProductModel>? relatedProducts,
  }) {
    return ProductDetailLoaded(
      product: product ?? this.product,
      relatedProducts: relatedProducts ?? this.relatedProducts,
    );
  }
}

class ProductDetailError extends ProductDetailState {
  final String message;

  const ProductDetailError(this.message);

  @override
  List<Object> get props => [message];
}
