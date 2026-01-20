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
  final String categoryId;

  const LoadCategoryProducts({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class GoBackToCategories extends CatalogEvent {
  const GoBackToCategories();
}
