import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryCubit({required CategoryRepository categoryRepository})
    : _categoryRepository = categoryRepository,
      super(const CategoryState());

  Future<void> loadMainCategories() async {
    emit(state.copyWith(status: CategoryStatus.loading));

    try {
      final categories = await _categoryRepository.getMainCategories();
      emit(
        state.copyWith(status: CategoryStatus.loaded, categories: categories),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refresh() async {
    await loadMainCategories();
  }
}
