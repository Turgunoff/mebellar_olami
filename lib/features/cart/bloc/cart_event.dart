part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {
  const LoadCart();
}

class AddToCart extends CartEvent {
  const AddToCart({required this.product, this.quantity = 1});

  final Map<String, dynamic> product;
  final int quantity;

  @override
  List<Object?> get props => [product, quantity];
}

class UpdateCartItemQuantity extends CartEvent {
  const UpdateCartItemQuantity({
    required this.productId,
    required this.newQuantity,
  });

  final String productId;
  final int newQuantity;

  @override
  List<Object?> get props => [productId, newQuantity];
}

class RemoveFromCart extends CartEvent {
  const RemoveFromCart({required this.productId});

  final String productId;

  @override
  List<Object?> get props => [productId];
}

class ClearCart extends CartEvent {
  const ClearCart();
}
