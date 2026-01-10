import 'package:flutter/foundation.dart';
import '../data/models/product_model.dart';

/// Sevimlilar provideri
/// Mahalliy saqlash (Local storage) mock
class FavoritesProvider extends ChangeNotifier {
  final List<ProductModel> _favorites = [];

  /// Sevimli mahsulotlar ro'yxati
  List<ProductModel> get favorites => List.unmodifiable(_favorites);

  /// Sevimlilar soni
  int get favoritesCount => _favorites.length;

  /// Mahsulot sevimlilardami?
  bool isFavorite(String productId) {
    return _favorites.any((p) => p.id == productId);
  }

  /// Sevimlilarga qo'shish
  void addToFavorites(ProductModel product) {
    if (!isFavorite(product.id)) {
      _favorites.add(product);
      notifyListeners();
    }
  }

  /// Sevimlilardan o'chirish
  void removeFromFavorites(String productId) {
    _favorites.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  /// Sevimli holatini almashtirish
  void toggleFavorite(ProductModel product) {
    if (isFavorite(product.id)) {
      removeFromFavorites(product.id);
    } else {
      addToFavorites(product);
    }
  }

  /// Barcha sevimlilarni tozalash
  void clearFavorites() {
    _favorites.clear();
    notifyListeners();
  }
}
