part of 'product_detail_bloc.dart';

abstract class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadProductDetails extends ProductDetailEvent {
  final String productId;

  const LoadProductDetails(this.productId);

  @override
  List<Object> get props => [productId];
}

class RefreshProductDetails extends ProductDetailEvent {
  final String productId;

  const RefreshProductDetails(this.productId);

  @override
  List<Object> get props => [productId];
}
