import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/repositories/cart_repository.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _repository;

  CartBloc({required CartRepository repository})
    : _repository = repository,
      super(const CartState()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartItemQuantity>(_onUpdateQuantity);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.loading));

    try {
      final cartItems = _repository.getCartItems();
      final itemCount = _repository.itemCount;
      final totalPrice = _repository.getCartTotal();

      emit(
        state.copyWith(
          status: CartStatus.loaded,
          cartItems: cartItems,
          itemCount: itemCount,
          totalPrice: totalPrice,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CartStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.updating));

    try {
      final result = await _repository.addToCart(event.product, event.quantity);

      if (result['success'] == true) {
        final cartItems = _repository.getCartItems();
        final itemCount = _repository.itemCount;
        final totalPrice = _repository.getCartTotal();

        emit(
          state.copyWith(
            status: CartStatus.loaded,
            cartItems: cartItems,
            itemCount: itemCount,
            totalPrice: totalPrice,
            successMessage: result['message'] ?? 'Savatchaga qo\'shildi',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: CartStatus.error,
            errorMessage: result['message'] ?? 'Xatolik yuz berdi',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: CartStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onUpdateQuantity(
    UpdateCartItemQuantity event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.updating));

    try {
      final result = await _repository.updateQuantity(
        event.productId,
        event.newQuantity,
      );

      if (result['success'] == true) {
        final cartItems = _repository.getCartItems();
        final itemCount = _repository.itemCount;
        final totalPrice = _repository.getCartTotal();

        emit(
          state.copyWith(
            status: CartStatus.loaded,
            cartItems: cartItems,
            itemCount: itemCount,
            totalPrice: totalPrice,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: CartStatus.error,
            errorMessage: result['message'] ?? 'Xatolik yuz berdi',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: CartStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.updating));

    try {
      final result = await _repository.removeFromCart(event.productId);

      if (result['success'] == true) {
        final cartItems = _repository.getCartItems();
        final itemCount = _repository.itemCount;
        final totalPrice = _repository.getCartTotal();

        emit(
          state.copyWith(
            status: CartStatus.loaded,
            cartItems: cartItems,
            itemCount: itemCount,
            totalPrice: totalPrice,
            successMessage: result['message'] ?? 'Savatchadan o\'chirildi',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: CartStatus.error,
            errorMessage: result['message'] ?? 'Xatolik yuz berdi',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: CartStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.updating));

    try {
      final result = await _repository.clearCart();

      if (result['success'] == true) {
        emit(
          state.copyWith(
            status: CartStatus.loaded,
            cartItems: [],
            itemCount: 0,
            totalPrice: 0.0,
            successMessage: result['message'] ?? 'Savatcha tozalandi',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: CartStatus.error,
            errorMessage: result['message'] ?? 'Xatolik yuz berdi',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: CartStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  /// Mahsulot savatchada borligini tekshirish
  bool isInCart(String productId) {
    return _repository.isInCart(productId);
  }

  /// Mahsulotning savatchadagi sonini olish
  int getProductQuantity(String productId) {
    return _repository.getProductQuantity(productId);
  }

  /// Savatcha statistikasi
  Map<String, dynamic> getCartStats() {
    return _repository.getCartStats();
  }
}
