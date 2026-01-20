part of 'checkout_bloc.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class SelectLocation extends CheckoutEvent {
  final Point location;
  final String address;

  const SelectLocation(this.location, this.address);

  @override
  List<Object?> get props => [location, address];
}

class CreateOrder extends CheckoutEvent {
  final List<Map<String, dynamic>> items;
  final String deliveryAddress;
  final double latitude;
  final double longitude;
  final String paymentMethod;
  final String? notes;
  final String customerName;
  final String customerPhone;

  const CreateOrder({
    required this.items,
    required this.deliveryAddress,
    required this.latitude,
    required this.longitude,
    required this.paymentMethod,
    this.notes,
    required this.customerName,
    required this.customerPhone,
  });

  @override
  List<Object?> get props => [
    items,
    deliveryAddress,
    latitude,
    longitude,
    paymentMethod,
    notes,
    customerName,
    customerPhone,
  ];
}

class ClearCheckoutData extends CheckoutEvent {
  const ClearCheckoutData();
}
