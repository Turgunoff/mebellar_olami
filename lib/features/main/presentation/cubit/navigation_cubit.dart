import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit to manage the bottom navigation bar index
class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);

  /// Change the current navigation index
  void changeIndex(int index) {
    if (index != state) {
      emit(index);
    }
  }
}
