import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

part 'sub_category_state.dart';

class SubCategoryCubit extends Cubit<SubCategoryState> {
  final CategoryRepository _categoryRepository;

  SubCategoryCubit({required CategoryRepository categoryRepository})
    : _categoryRepository = categoryRepository,
      super(const SubCategoryState());

  Future<void> loadSubCategories(String parentId) async {
    emit(state.copyWith(status: SubCategoryStatus.loading));

    try {
      final subCategories = await _categoryRepository.getSubCategories(
        parentId,
      );
      emit(
        state.copyWith(
          status: SubCategoryStatus.loaded,
          subCategories: subCategories,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SubCategoryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refresh(String parentId) async {
    await loadSubCategories(parentId);
  }
}
