import 'package:shared_preferences/shared_preferences.dart';

/// Local storage service for guest favorites using SharedPreferences
/// Stores only product IDs as a list of strings
class LocalFavoritesSource {
  static const String _key = 'guest_fav_ids';

  /// Get all favorite product IDs
  Future<List<String>> getFavoriteIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_key);
      return ids ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Add a product ID to favorites
  Future<bool> addFavoriteId(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentIds = await getFavoriteIds();
      
      if (!currentIds.contains(productId)) {
        currentIds.add(productId);
        return await prefs.setStringList(_key, currentIds);
      }
      return true; // Already exists
    } catch (e) {
      return false;
    }
  }

  /// Remove a product ID from favorites
  Future<bool> removeFavoriteId(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentIds = await getFavoriteIds();
      currentIds.remove(productId);
      return await prefs.setStringList(_key, currentIds);
    } catch (e) {
      return false;
    }
  }

  /// Toggle favorite status (add if not exists, remove if exists)
  Future<bool> toggleFavoriteId(String productId) async {
    try {
      final currentIds = await getFavoriteIds();
      if (currentIds.contains(productId)) {
        return await removeFavoriteId(productId);
      } else {
        return await addFavoriteId(productId);
      }
    } catch (e) {
      return false;
    }
  }

  /// Check if a product ID is in favorites
  Future<bool> isFavorite(String productId) async {
    try {
      final ids = await getFavoriteIds();
      return ids.contains(productId);
    } catch (e) {
      return false;
    }
  }

  /// Clear all guest favorites
  Future<bool> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_key);
    } catch (e) {
      return false;
    }
  }

  /// Set favorite IDs (useful for syncing)
  Future<bool> setFavoriteIds(List<String> productIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setStringList(_key, productIds);
    } catch (e) {
      return false;
    }
  }
}
