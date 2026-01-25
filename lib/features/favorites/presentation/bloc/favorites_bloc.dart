import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/repositories/favorites_repository.dart';
import '../../data/datasources/local_favorites_source.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../products/data/repositories/product_repository.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository _repository;
  final LocalFavoritesSource _localFavoritesSource;
  final ProductRepository? _productRepository;
  AuthBloc? _authBloc;

  FavoritesBloc({
    required FavoritesRepository repository,
    LocalFavoritesSource? localFavoritesSource,
    ProductRepository? productRepository,
    AuthBloc? authBloc,
  })  : _repository = repository,
        _localFavoritesSource = localFavoritesSource ?? LocalFavoritesSource(),
        _productRepository = productRepository,
        _authBloc = authBloc,
        super(const FavoritesState()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<SyncFavoritesEvent>(_onSyncFavorites);
    on<MergeFavorites>(_onMergeFavorites);
    on<ClearFavorites>(_onClearFavorites);
    on<_RevertFavoritesEvent>(_onRevertFavorites);
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
        // For guest users, load IDs from SharedPreferences
        final guestFavoriteIds = await _localFavoritesSource.getFavoriteIds();

        if (guestFavoriteIds.isEmpty) {
          emit(
            state.copyWith(
              status: FavoritesStatus.loaded,
              favorites: [],
            ),
          );
          return;
        }

        // Fetch full product details using ProductRepository
        if (_productRepository != null) {
          debugPrint(
            '📦 [Favorites] Fetching ${guestFavoriteIds.length} products for guest',
          );
          final products = await _productRepository.getProductsByIds(
            guestFavoriteIds,
          );
          debugPrint(
            '✅ [Favorites] Successfully fetched ${products.length} products',
          );

          if (products.isEmpty && guestFavoriteIds.isNotEmpty) {
            debugPrint(
              '⚠️ [Favorites] No products found for ${guestFavoriteIds.length} IDs',
            );
          }

          emit(
            state.copyWith(
              status: FavoritesStatus.loaded,
              favorites: products,
            ),
          );
        } else {
          // Fallback: if ProductRepository is not available, use IDs only
          debugPrint(
            '⚠️ [Favorites] ProductRepository not available, using IDs only',
          );
          final guestFavorites = guestFavoriteIds
              .map((id) => <String, dynamic>{'id': id})
              .toList();
          emit(
            state.copyWith(
              status: FavoritesStatus.loaded,
              favorites: guestFavorites,
            ),
          );
        }
      } else {
        // For authenticated users, load from API
        final favorites = await _repository.getFavorites();
        emit(
          state.copyWith(status: FavoritesStatus.loaded, favorites: favorites),
        );
      }
    } catch (e) {
      debugPrint('❌ [Favorites] Error loading favorites: $e');
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
      // Guest mode: Optimistic Update without reloading
      final currentFavorites = List<Map<String, dynamic>>.from(state.favorites);
      final existingIndex = currentFavorites.indexWhere(
        (favorite) => favorite['id']?.toString() == productId,
      );

      final wasFavorite = existingIndex != -1;
      List<Map<String, dynamic>> optimisticFavorites;

      if (wasFavorite) {
        // Removing: Remove from list immediately
        optimisticFavorites = List.from(currentFavorites)..removeAt(existingIndex);
      } else {
        // Adding: Add to list immediately with FULL product data
        // Always use the full event.product object to ensure all fields (name, price, images, etc.) are included
        debugPrint(
          '✅ [Favorites] Adding product with fields: ${event.product.keys.join(", ")}',
        );
        // Verify critical fields are present
        if (!event.product.containsKey('images') && !event.product.containsKey('image_url')) {
          debugPrint(
            '⚠️ [Favorites] Warning: Product image.pngmissing image data',
          );
        }
        if (!event.product.containsKey('price')) {
          debugPrint(
            '⚠️ [Favorites] Warning: Product missing price data',
          );
        }
        optimisticFavorites = List.from(currentFavorites)..add(event.product);
      }

      // Emit updated state immediately (optimistic UI)
      emit(
        state.copyWith(
          status: FavoritesStatus.loaded,
          favorites: optimisticFavorites,
          isUpdating: false, // Don't show loading indicator
        ),
      );

      // Save to SharedPreferences in background (non-blocking)
      _saveGuestFavoriteInBackground(productId, wasFavorite, currentFavorites);
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

      // Emit updated state immediately (optimistic UI)
      emit(
        state.copyWith(
          status: FavoritesStatus.loaded,
          favorites: optimisticFavorites,
          isUpdating: false, // Don't show loading indicator
        ),
      );

      // Call API in background and revert on failure
      final wasFavorite = existingIndex != -1;
      _saveAuthenticatedFavoriteInBackground(
        event.product,
        productId,
        wasFavorite,
        currentFavorites,
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

  Future<void> _onClearFavorites(
    ClearFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    // Check if user is guest
    final isGuest = _authBloc?.state is AuthGuest ||
        _authBloc?.state is AuthUnauthenticated;

    // Emit empty list immediately (optimistic UI)
    emit(
      state.copyWith(
        status: FavoritesStatus.loaded,
        favorites: [],
        isUpdating: false,
      ),
    );

    // Clear in background (non-blocking)
    if (isGuest) {
      _clearGuestFavoritesInBackground();
    } else {
      _clearAuthenticatedFavoritesInBackground();
    }
  }

  /// Save guest favorite in background (non-blocking)
  Future<void> _saveGuestFavoriteInBackground(
    String productId,
    bool wasFavorite,
    List<Map<String, dynamic>> previousFavorites,
  ) async {
    try {
      final success = await _localFavoritesSource.toggleFavoriteId(productId);

      if (success) {
        if (wasFavorite) {
          debugPrint(
            '🔴 [Favorites] Guest REMOVED: (ID: $productId)',
          );
        } else {
          debugPrint(
            '🟢 [Favorites] Guest ADDED: (ID: $productId)',
          );
        }
      } else {
        // Revert on failure
        debugPrint(
          '❌ [Favorites] Failed to save guest favorite, reverting: $productId',
        );
        add(_RevertFavoritesEvent(previousFavorites));
      }
    } catch (e) {
      debugPrint('❌ [Favorites] Error saving guest favorite: $e');
      // Revert on error
      add(_RevertFavoritesEvent(previousFavorites));
    }
  }

  /// Save authenticated favorite in background (non-blocking)
  Future<void> _saveAuthenticatedFavoriteInBackground(
    Map<String, dynamic> product,
    String productId,
    bool wasFavorite,
    List<Map<String, dynamic>> previousFavorites,
  ) async {
    try {
      final productName = product['name']?.toString() ?? 'Unknown';
      final result = await _repository.toggleFavorite(product);

      if (result['success'] == true) {
        if (wasFavorite) {
          debugPrint(
            '🔴 [Favorites] Authenticated REMOVED: $productName (ID: $productId)',
          );
        } else {
          debugPrint(
            '🟢 [Favorites] Authenticated ADDED: $productName (ID: $productId)',
          );
        }
      } else {
        // Revert on failure
        debugPrint(
          '❌ [Favorites] Failed to save authenticated favorite, reverting: $productId',
        );
        add(_RevertFavoritesEvent(previousFavorites));
      }
    } catch (e) {
      debugPrint('❌ [Favorites] Error saving authenticated favorite: $e');
      // Revert on error
      add(_RevertFavoritesEvent(previousFavorites));
    }
  }

  /// Clear guest favorites in background
  Future<void> _clearGuestFavoritesInBackground() async {
    try {
      final success = await _localFavoritesSource.clearFavorites();
      if (success) {
        debugPrint('🧹 [Favorites] Guest list CLEARED');
      } else {
        debugPrint('❌ [Favorites] Failed to clear guest favorites');
      }
    } catch (e) {
      debugPrint('❌ [Favorites] Error clearing guest favorites: $e');
    }
  }

  /// Clear authenticated favorites in background
  Future<void> _clearAuthenticatedFavoritesInBackground() async {
    try {
      debugPrint('🧹 [Favorites] Clearing authenticated favorites');
      // Note: If you have a clear endpoint, call it here
      // For now, we just clear the local state
      // You may want to add a clearFavorites method to the repository
    } catch (e) {
      debugPrint('❌ [Favorites] Error clearing authenticated favorites: $e');
    }
  }

  /// Handle revert event (internal use only)
  void _onRevertFavorites(
    _RevertFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) {
    emit(
      state.copyWith(
        status: FavoritesStatus.loaded,
        favorites: event.previousFavorites,
        isUpdating: false,
      ),
    );
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

/// Internal event for reverting favorites (used when background save fails)
class _RevertFavoritesEvent extends FavoritesEvent {
  const _RevertFavoritesEvent(this.previousFavorites);

  final List<Map<String, dynamic>> previousFavorites;

  @override
  List<Object?> get props => [previousFavorites];
}
