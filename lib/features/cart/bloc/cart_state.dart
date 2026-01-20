part of 'cart_bloc.dart';

enum CartStatus { initial, loading, loaded, updating, error }

class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.initial,
    this.cartItems = const [],
    this.itemCount = 0,
    this.totalPrice = 0.0,
    this.errorMessage,
    this.successMessage,
  });

  final CartStatus status;
  final List<Map<String, dynamic>> cartItems;
  final int itemCount;
  final double totalPrice;
  final String? errorMessage;
  final String? successMessage;

  @override
  List<Object?> get props => [
    status,
    cartItems,
    itemCount,
    totalPrice,
    errorMessage,
    successMessage,
  ];

  CartState copyWith({
    CartStatus? status,
    List<Map<String, dynamic>>? cartItems,
    int? itemCount,
    double? totalPrice,
    String? errorMessage,
    String? successMessage,
  }) {
    return CartState(
      status: status ?? this.status,
      cartItems: cartItems ?? this.cartItems,
      itemCount: itemCount ?? this.itemCount,
      totalPrice: totalPrice ?? this.totalPrice,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  bool get isEmpty => itemCount == 0;
  bool get isNotEmpty => itemCount > 0;
}
