import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/models/product_model.dart';
import '../core/services/api_service.dart';

/// Category Provider
/// Kategoriyalar bilan ishlash uchun
class CategoryProvider extends ChangeNotifier {
  final String _baseUrl = ApiService.baseUrl;

  // Holat o'zgaruvchilari
  bool _isLoading = false;
  String? _errorMessage;

  // Kategoriyalar ro'yxati (daraxt ko'rinishida)
  List<CategoryModel> _categories = [];

  // Tanlangan kategoriya
  CategoryModel? _selectedCategory;
  CategoryModel? _selectedSubCategory;

  /// Log helper
  void _log(String message) {
    developer.log(message, name: 'CATEGORY');
    // ignore: avoid_print
    print('📂 [CATEGORY] $message');
  }

  // Getterlar
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CategoryModel> get categories => _categories;
  CategoryModel? get selectedCategory => _selectedCategory;
  CategoryModel? get selectedSubCategory => _selectedSubCategory;

  /// Tanlangan kategoriya ID si (filtrlash uchun)
  String? get selectedCategoryId {
    if (_selectedSubCategory != null) {
      return _selectedSubCategory!.id;
    }
    if (_selectedCategory != null) {
      return _selectedCategory!.id;
    }
    return null;
  }

  /// Xatolikni tozalash
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Kategoriya tanlash
  void selectCategory(CategoryModel? category) {
    _selectedCategory = category;
    _selectedSubCategory = null;
    notifyListeners();
  }

  /// Sub-kategoriya tanlash
  void selectSubCategory(CategoryModel? subCategory) {
    _selectedSubCategory = subCategory;
    notifyListeners();
  }

  /// Tanlovni tozalash
  void clearSelection() {
    _selectedCategory = null;
    _selectedSubCategory = null;
    notifyListeners();
  }

  // ============================================
  // KATEGORIYALARNI OLISH (DARAXT)
  // ============================================
  Future<bool> fetchCategories() async {
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('📂 Fetching categories (tree)...');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/categories'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      _log('Response status: ${response.statusCode}');
      _log('Response body: ${response.body.substring(0, response.body.length.clamp(0, 200))}...');

      _isLoading = false;

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final success = json['success'] as bool? ?? false;

        if (success) {
          final categoriesJson = json['categories'] as List? ?? [];
          _categories = categoriesJson
              .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList();
          _log('✅ ${_categories.length} ta kategoriya yuklandi');
          notifyListeners();
          return true;
        } else {
          _errorMessage = json['message']?.toString() ?? 'Kategoriyalarni olishda xatolik';
          _log('❌ Fetch categories failed: $_errorMessage');
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Server xatosi: ${response.statusCode}';
        _log('❌ HTTP error: ${response.statusCode}');
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

  /// Kategoriyani ID bo'yicha topish
  CategoryModel? findCategoryById(String id) {
    for (final category in _categories) {
      if (category.id == id) {
        return category;
      }
      for (final sub in category.subCategories) {
        if (sub.id == id) {
          return sub;
        }
      }
    }
    return null;
  }

  /// Sub-kategoriyalarni olish (asosiy kategoriya ID bo'yicha)
  List<CategoryModel> getSubCategories(String parentId) {
    final parent = findCategoryById(parentId);
    return parent?.subCategories ?? [];
  }

  /// Provider ni reset qilish
  void reset() {
    _categories = [];
    _selectedCategory = null;
    _selectedSubCategory = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
