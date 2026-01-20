import '../../../../core/local/hive_service.dart';

class SearchRepository {
  /// Qidiruv tarixini olish
  List<String> getSearchHistory() {
    try {
      final historyData = HiveService.searchHistoryBox.values.toList();
      return historyData.whereType<String>().cast<String>().toList();
    } catch (e) {
      return [];
    }
  }

  /// Yangi qidiruv so'zini qo'shish
  Future<void> addSearchTerm(String term) async {
    if (term.trim().isEmpty) return;

    final trimmedTerm = term.trim().toLowerCase();
    final currentHistory = getSearchHistory();

    // Dublikatlarni o'chirish
    final updatedHistory = currentHistory
        .where((item) => item.toLowerCase() != trimmedTerm)
        .toList();

    // Ro'yxat boshiga qo'shish
    updatedHistory.insert(0, trimmedTerm);

    // Maksimal 20 ta saqlash
    if (updatedHistory.length > 20) {
      updatedHistory.removeRange(20, updatedHistory.length);
    }

    await _saveSearchHistory(updatedHistory);
  }

  /// Qidiruv tarixini tozalash
  Future<void> clearHistory() async {
    try {
      await HiveService.searchHistoryBox.clear();
    } catch (e) {
      // Xatolikni log qilish mumkin
      throw Exception('Qidiruv tarixini tozalashda xatolik: ${e.toString()}');
    }
  }

  /// Bitta so'zni o'chirish
  Future<void> removeTerm(String term) async {
    if (term.trim().isEmpty) return;

    final currentHistory = getSearchHistory();
    final updatedHistory = currentHistory
        .where((item) => item.toLowerCase() != term.trim().toLowerCase())
        .toList();

    await _saveSearchHistory(updatedHistory);
  }

  /// Qidiruv so'zini tarixda borligini tekshirish
  bool isTermInHistory(String term) {
    if (term.trim().isEmpty) return false;

    final trimmedTerm = term.trim().toLowerCase();
    return getSearchHistory().any((item) => item.toLowerCase() == trimmedTerm);
  }

  /// Eng ko'p qidirilgan so'zlarni olish (statistika uchun)
  List<String> getPopularSearchTerms({int limit = 10}) {
    final history = getSearchHistory();
    return history.take(limit).toList();
  }

  /// Qidiruv takliflari (tarix asosida)
  List<String> getSearchSuggestions(String query, {int limit = 5}) {
    if (query.trim().isEmpty) return getPopularSearchTerms(limit: limit);

    final trimmedQuery = query.trim().toLowerCase();
    final history = getSearchHistory();

    // Tarixda mos so'zlarni topish
    final suggestions = history
        .where((term) => term.toLowerCase().contains(trimmedQuery))
        .take(limit)
        .toList();

    return suggestions;
  }

  /// Qidiruv tarixi uzunligi
  int get historyLength => getSearchHistory().length;

  /// Qidiruv tarixi bo'shmi
  bool get isHistoryEmpty => getSearchHistory().isEmpty;

  // Private helper methods

  Future<void> _saveSearchHistory(List<String> terms) async {
    try {
      await HiveService.searchHistoryBox.clear();
      for (int i = 0; i < terms.length; i++) {
        await HiveService.searchHistoryBox.put(i, terms[i]);
      }
    } catch (e) {
      throw Exception('Qidiruv tarixini saqlashda xatolik: ${e.toString()}');
    }
  }

  /// Qidiruv statistikasi
  Map<String, dynamic> getSearchStats() {
    final history = getSearchHistory();

    return {
      'total_searches': history.length,
      'unique_terms': history.toSet().length,
      'most_recent': history.isNotEmpty ? history.first : null,
      'popular_terms': getPopularSearchTerms(limit: 5),
    };
  }

  /// Eski qidiruvlarni tozalash (masalan, 7 kundan eskiroqlarni)
  Future<void> clearOldSearches({int daysToKeep = 7}) async {
    // Bu funksiya qidiruv vaqtini saqlash uchun kengaytirilishi mumkin
    // Hozircha oddiy tozalash
    final history = getSearchHistory();
    if (history.length > 50) {
      // 50 tadan ortiq bo'lsa, oxirgi 20 tasini saqlab qolish
      final recentSearches = history.take(20).toList();
      await _saveSearchHistory(recentSearches);
    }
  }

  /// Qidiruv so'zini formatlash (qo'shimcha belgilarni olib tashlash)
  String sanitizeSearchTerm(String term) {
    return term
        .trim()
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        ) // Bir nechta bo'shliqni bittasiga almashtirish
        .toLowerCase();
  }
}
