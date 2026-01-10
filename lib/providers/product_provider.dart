import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../data/models/product_model.dart';

/// Product Provider
/// Mahsulotlar bilan ishlash uchun
class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Holat o'zgaruvchilari
  bool _isLoading = false;
  bool _isLoadingNew = false;
  bool _isLoadingPopular = false;
  String? _errorMessage;

  // Mahsulotlar ro'yxati
  List<ProductModel> _allProducts = [];
  List<ProductModel> _newArrivals = [];
  List<ProductModel> _popularProducts = [];

  /// Log helper
  void _log(String message) {
    developer.log(message, name: 'PRODUCT');
    // ignore: avoid_print
    print('🛋️ [PRODUCT] $message');
  }

  // Getterlar
  bool get isLoading => _isLoading;
  bool get isLoadingNew => _isLoadingNew;
  bool get isLoadingPopular => _isLoadingPopular;
  String? get errorMessage => _errorMessage;
  
  List<ProductModel> get allProducts => _allProducts;
  List<ProductModel> get newArrivals => _newArrivals;
  List<ProductModel> get popularProducts => _popularProducts;

  /// Xatolikni tozalash
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================
  // BARCHA MAHSULOTLARNI OLISH
  // ============================================
  Future<bool> fetchProducts({String? category}) async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📦 Fetching products... category=$category');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getProducts(category: category);
      _log('Response: $response');

      _isLoading = false;

      if (response.success) {
        _allProducts = response.products
            .map((json) => ProductModel.fromJson(json))
            .toList();
        _log('✅ ${_allProducts.length} ta mahsulot yuklandi');
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _log('❌ Fetch products failed: $_errorMessage');
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      _log('❌ Exception: $e');
      _log('❌ StackTrace: $stackTrace');
      _isLoading = false;
      _errorMessage = 'Xatolik yuz berdi: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // YANGI MAHSULOTLARNI OLISH
  // ============================================
  Future<bool> fetchNewArrivals() async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('🆕 Fetching new arrivals...');

    _isLoadingNew = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getNewArrivals();
      _log('Response: $response');

      _isLoadingNew = false;

      if (response.success) {
        _newArrivals = response.products
            .map((json) => ProductModel.fromJson(json))
            .toList();
        _log('✅ ${_newArrivals.length} ta yangi mahsulot yuklandi');
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _log('❌ Fetch new arrivals failed: $_errorMessage');
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      _log('❌ Exception: $e');
      _log('❌ StackTrace: $stackTrace');
      _isLoadingNew = false;
      _errorMessage = 'Xatolik yuz berdi: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // MASHHUR MAHSULOTLARNI OLISH
  // ============================================
  Future<bool> fetchPopularProducts() async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('⭐ Fetching popular products...');

    _isLoadingPopular = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getPopularProducts();
      _log('Response: $response');

      _isLoadingPopular = false;

      if (response.success) {
        _popularProducts = response.products
            .map((json) => ProductModel.fromJson(json))
            .toList();
        _log('✅ ${_popularProducts.length} ta mashhur mahsulot yuklandi');
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _log('❌ Fetch popular products failed: $_errorMessage');
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      _log('❌ Exception: $e');
      _log('❌ StackTrace: $stackTrace');
      _isLoadingPopular = false;
      _errorMessage = 'Xatolik yuz berdi: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // BARCHA MA'LUMOTLARNI YUKLASH
  // ============================================
  Future<void> fetchAll() async {
    _log('🔄 Fetching all products data...');
    await Future.wait([
      fetchNewArrivals(),
      fetchPopularProducts(),
    ]);
  }

  /// Provider ni reset qilish
  void reset() {
    _allProducts = [];
    _newArrivals = [];
    _popularProducts = [];
    _errorMessage = null;
    _isLoading = false;
    _isLoadingNew = false;
    _isLoadingPopular = false;
    notifyListeners();
  }
}
