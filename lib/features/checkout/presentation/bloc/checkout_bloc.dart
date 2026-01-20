import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final OrderRepository _orderRepository;

  CheckoutBloc({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const CheckoutInitial()) {
    on<SelectLocation>(_onSelectLocation);
    on<CreateOrder>(_onCreateOrder);
    on<ClearCheckoutData>(_onClearCheckoutData);
  }

  void _onSelectLocation(SelectLocation event, Emitter<CheckoutState> emit) {
    emit(const CheckoutLoading());
    emit(LocationSelected(event.location, event.address));
  }

  Future<void> _onCreateOrder(
    CreateOrder event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(const CheckoutLoading());
    try {
      final order = await _orderRepository.createOrder(
        items: event.items,
        deliveryAddress: event.deliveryAddress,
        latitude: event.latitude,
        longitude: event.longitude,
        paymentMethod: event.paymentMethod,
        notes: event.notes,
        customerName: event.customerName,
        customerPhone: event.customerPhone,
      );
      emit(OrderCreatedSuccess(order));
    } catch (e) {
      emit(CheckoutError(e.toString()));
    }
  }

  void _onClearCheckoutData(
    ClearCheckoutData event,
    Emitter<CheckoutState> emit,
  ) {
    emit(const CheckoutInitial());
  }
}
