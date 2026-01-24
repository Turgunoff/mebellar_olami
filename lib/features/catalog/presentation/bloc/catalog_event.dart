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
  final bool forceRefresh; // Force API call even if cache exists (e.g., pull-to-refresh)

  const LoadCategoryProducts({
    this.categoryId,
    this.parentId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [categoryId, parentId, forceRefresh];
}

class LoadGroupedProductsPreview extends CatalogEvent {
  final String parentId;
  final int limitPerCat;

  const LoadGroupedProductsPreview({
    required this.parentId,
    this.limitPerCat = 10,
  });

  @override
  List<Object?> get props => [parentId, limitPerCat];
}

class SwitchToSubCategory extends CatalogEvent {
  final String categoryId;
  final bool useCache;

  const SwitchToSubCategory({
    required this.categoryId,
    this.useCache = true,
  });

  @override
  List<Object?> get props => [categoryId, useCache];
}

class GoBackToCategories extends CatalogEvent {
  const GoBackToCategories();
}
