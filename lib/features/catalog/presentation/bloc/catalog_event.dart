part of 'catalog_bloc.dart';

abstract class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CatalogEvent {
  const LoadCategories();
}

class SelectCategory extends CatalogEvent {
  final CategoryModel category;

  const SelectCategory({required this.category});

  @override
  List<Object?> get props => [category];
}

class LoadCategoryProducts extends CatalogEvent {
  final String? categoryId;
  final String? parentId;

  const LoadCategoryProducts({
    this.categoryId,
    this.parentId,
  });

  @override
  List<Object?> get props => [categoryId, parentId];
}

class GoBackToCategories extends CatalogEvent {
  const GoBackToCategories();
}
