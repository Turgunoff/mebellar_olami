part of 'sub_category_cubit.dart';

enum SubCategoryStatus { initial, loading, loaded, error }

class SubCategoryState extends Equatable {
  final SubCategoryStatus status;
  final List<CategoryModel> subCategories;
  final String? errorMessage;

  const SubCategoryState({
    this.status = SubCategoryStatus.initial,
    this.subCategories = const [],
    this.errorMessage,
  });

  bool get isLoading => status == SubCategoryStatus.loading;
  bool get isLoaded => status == SubCategoryStatus.loaded;
  bool get hasError => status == SubCategoryStatus.error;

  SubCategoryState copyWith({
    SubCategoryStatus? status,
    List<CategoryModel>? subCategories,
    String? errorMessage,
  }) {
    return SubCategoryState(
      status: status ?? this.status,
      subCategories: subCategories ?? this.subCategories,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, subCategories, errorMessage];
}
