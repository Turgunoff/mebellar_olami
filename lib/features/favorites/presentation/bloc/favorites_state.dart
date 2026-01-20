part of 'favorites_bloc.dart';

enum FavoritesStatus { initial, loading, loaded, syncing, error }

class FavoritesState extends Equatable {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
    this.errorMessage,
    this.syncMessage,
    this.isUpdating = false,
  });

  final FavoritesStatus status;
  final List<Map<String, dynamic>> favorites;
  final String? errorMessage;
  final String? syncMessage;
  final bool isUpdating;

  @override
  List<Object?> get props => [
    status,
    favorites,
    errorMessage,
    syncMessage,
    isUpdating,
  ];

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<Map<String, dynamic>>? favorites,
    String? errorMessage,
    String? syncMessage,
    bool? isUpdating,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      errorMessage: errorMessage,
      syncMessage: syncMessage,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}
