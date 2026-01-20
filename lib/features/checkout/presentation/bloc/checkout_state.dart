part of 'checkout_bloc.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

class OrderCreatedSuccess extends CheckoutState {
  final OrderModel order;

  const OrderCreatedSuccess(this.order);

  @override
  List<Object?> get props => [order];
}

class CheckoutError extends CheckoutState {
  final String message;

  const CheckoutError(this.message);

  @override
  List<Object?> get props => [message];
}

class LocationSelected extends CheckoutState {
  final Point location;
  final String address;

  const LocationSelected(this.location, this.address);

  @override
  List<Object?> get props => [location, address];
}
