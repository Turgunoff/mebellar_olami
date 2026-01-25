part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {
  const LoadFavorites();
}

class ToggleFavoriteEvent extends FavoritesEvent {
  const ToggleFavoriteEvent({
    required this.product,
    this.showSuccessMessage = false,
  });

  final Map<String, dynamic> product;
  final bool showSuccessMessage;

  @override
  List<Object?> get props => [product, showSuccessMessage];
}

class SyncFavoritesEvent extends FavoritesEvent {
  const SyncFavoritesEvent();
}

class MergeFavorites extends FavoritesEvent {
  const MergeFavorites();
}
