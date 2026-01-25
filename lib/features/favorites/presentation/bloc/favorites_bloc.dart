import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/repositories/favorites_repository.dart';
import '../../data/datasources/local_favorites_source.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository _repository;
  final LocalFavoritesSource _localFavoritesSource;
  AuthBloc? _authBloc;

  FavoritesBloc({
    required FavoritesRepository repository,
    LocalFavoritesSource? localFavoritesSource,
    AuthBloc? authBloc,
  })  : _repository = repository,
        _localFavoritesSource = localFavoritesSource ?? LocalFavoritesSource(),
        _authBloc = authBloc,
        super(const FavoritesState()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<SyncFavoritesEvent>(_onSyncFavorites);
    on<MergeFavorites>(_onMergeFavorites);
  }

  /// Set AuthBloc reference (used to resolve circular dependency)
  void setAuthBloc(AuthBloc authBloc) {
    _authBloc = authBloc;
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(status: FavoritesStatus.loading));

    try {
      // Check if user is guest
      final isGuest = _authBloc?.state is AuthGuest ||
          _authBloc?.state is AuthUnauthenticated;

      if (isGuest) {
        // For guest users, load from SharedPreferences (only IDs)
        final guestFavoriteIds = await _localFavoritesSource.getFavoriteIds();
        // Convert IDs to a list of maps with just IDs (UI will handle display)
        final guestFavorites = guestFavoriteIds
            .map((id) => <String, dynamic>{'id': id})
            .toList();
        emit(
          state.copyWith(
            status: FavoritesStatus.loaded,
            favorites: guestFavorites,
          ),
        );
      } else {
        // For authenticated users, load from API
        final favorites = await _repository.getFavorites();
        emit(
          state.copyWith(status: FavoritesStatus.loaded, favorites: favorites),
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

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    // Check if user is guest
    final isGuest = _authBloc?.state is AuthGuest ||
        _authBloc?.state is AuthUnauthenticated;

    final productId = event.product['id']?.toString() ?? '';

    if (isGuest) {
      // Guest mode: Use SharedPreferences
      // Optimistic Update - avval UI ni yangilaymiz
      final currentFavorites = List<Map<String, dynamic>>.from(state.favorites);
      final existingIndex = currentFavorites.indexWhere(
        (favorite) => favorite['id']?.toString() == productId,
      );

      List<Map<String, dynamic>> optimisticFavorites;

      if (existingIndex != -1) {
        // Mahsulotni o'chirish (optimistic)
        optimisticFavorites = List.from(currentFavorites)
          ..removeAt(existingIndex);
      } else {
        // Mahsulotni qo'shish (optimistic) - only store ID for guest
        optimisticFavorites = List.from(currentFavorites)
          ..add(<String, dynamic>{'id': productId});
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
        // Toggle in SharedPreferences
        final success = await _localFavoritesSource.toggleFavoriteId(productId);

        if (success) {
          // Update confirmed
          emit(
            state.copyWith(
              status: FavoritesStatus.loaded,
              favorites: optimisticFavorites,
              isUpdating: false,
            ),
          );
        } else {
          // Failed to save, revert optimistic update
          emit(
            state.copyWith(
              status: FavoritesStatus.loaded,
              favorites: currentFavorites,
              isUpdating: false,
              errorMessage: 'Failed to update favorite',
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
    } else {
      // Authenticated mode: Use existing API logic
      // Optimistic Update - avval UI ni yangilaymiz
      final currentFavorites = List<Map<String, dynamic>>.from(state.favorites);

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

  Future<void> _onMergeFavorites(
    MergeFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(status: FavoritesStatus.syncing));

    try {
      final result = await _repository.mergeGuestFavorites();

      if (result['success'] == true) {
        // Merge muvaffaqiyatli bo'lgandan so'ng, sevimlilarni qayta yuklaymiz
        final favorites = await _repository.getFavorites();
        emit(
          state.copyWith(
            status: FavoritesStatus.loaded,
            favorites: favorites,
            syncMessage: result['message'] ?? 'Favorites merged successfully',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: FavoritesStatus.error,
            errorMessage: result['message'] ?? 'Merge failed',
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
