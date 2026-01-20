import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/repositories/favorites_repository.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesBloc({required FavoritesRepository repository})
    : _repository = repository,
      super(const FavoritesState()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<SyncFavoritesEvent>(_onSyncFavorites);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(status: FavoritesStatus.loading));

    try {
      final favorites = await _repository.getFavorites();
      emit(
        state.copyWith(status: FavoritesStatus.loaded, favorites: favorites),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FavoritesStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    // Optimistic Update - avval UI ni yangilaymiz
    final currentFavorites = List<Map<String, dynamic>>.from(state.favorites);
    final productId = event.product['id']?.toString() ?? '';

    final existingIndex = currentFavorites.indexWhere(
      (favorite) => favorite['id']?.toString() == productId,
    );

    List<Map<String, dynamic>> optimisticFavorites;

    if (existingIndex != -1) {
      // Mahsulotni o'chirish (optimistic)
      optimisticFavorites = List.from(currentFavorites)
        ..removeAt(existingIndex);
    } else {
      // Mahsulotni qo'shish (optimistic)
      optimisticFavorites = List.from(currentFavorites)..add(event.product);
    }

    // UI ni darhol yangilash
    emit(
      state.copyWith(
        status: FavoritesStatus.loaded,
        favorites: optimisticFavorites,
        isUpdating: true,
      ),
    );

    try {
      final result = await _repository.toggleFavorite(event.product);

      if (result['success'] == true) {
        // Server javobi muvaffaqiyatli bo'lsa, state ni tasdiqlaymiz
        emit(
          state.copyWith(
            status: FavoritesStatus.loaded,
            favorites: optimisticFavorites,
            isUpdating: false,
          ),
        );

        // Optional: Success message ni ko'rsatish mumkin
        if (event.showSuccessMessage) {
          // Callback or event for showing success message
        }
      } else {
        // Server xatoligi bo'lsa, optimistic update ni qaytarib olamiz
        emit(
          state.copyWith(
            status: FavoritesStatus.loaded,
            favorites: currentFavorites,
            isUpdating: false,
            errorMessage: result['message'] ?? 'Failed to update favorite',
          ),
        );
      }
    } catch (e) {
      // Xatolik bo'lsa, optimistic update ni qaytarib olamiz
      emit(
        state.copyWith(
          status: FavoritesStatus.loaded,
          favorites: currentFavorites,
          isUpdating: false,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onSyncFavorites(
    SyncFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(status: FavoritesStatus.syncing));

    try {
      final result = await _repository.syncFavorites();

      if (result['success'] == true) {
        // Sync muvaffaqiyatli bo'lgandan so'ng, sevimlilarni qayta yuklaymiz
        final favorites = await _repository.getFavorites();
        emit(
          state.copyWith(
            status: FavoritesStatus.loaded,
            favorites: favorites,
            syncMessage: result['message'] ?? 'Favorites synced successfully',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: FavoritesStatus.error,
            errorMessage: result['message'] ?? 'Sync failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: FavoritesStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  /// Mahsulot sevimli ekanligini tekshirish
  bool isFavorite(String productId) {
    return state.favorites.any(
      (favorite) => favorite['id']?.toString() == productId,
    );
  }

  /// Sevimlilar sonini olish
  int get favoritesCount => state.favorites.length;
}
