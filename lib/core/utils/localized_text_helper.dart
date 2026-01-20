import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Backenddan keladigan ko'p tilli ma'lumotlarni olish uchun helper
/// Backend format: {"en": "Table", "ru": "Стол", "uz": "Stol"}
class LocalizedTextHelper {
  /// Joriy tilga mos matnni qaytaradi
  /// Agar joriy til topilmasa, 'uz' ni qaytaradi
  /// Agar 'uz' ham topilmasa, birinchi mavjud qiymatni qaytaradi
  static String get(dynamic data, BuildContext context) {
    if (data == null) return '';
    if (data is! Map) return data.toString();

    final String lang = context.locale.languageCode; // 'uz', 'ru' yoki 'en'
    return data[lang]?.toString() ??
        data['uz']?.toString() ??
        (data.values.isNotEmpty ? data.values.first?.toString() ?? '' : '');
  }

  /// Context siz, to'g'ridan-to'g'ri til kodi bilan
  static String getByLang(dynamic data, String langCode) {
    if (data == null) return '';
    if (data is! Map) return data.toString();

    return data[langCode]?.toString() ??
        data['uz']?.toString() ??
        (data.values.isNotEmpty ? data.values.first?.toString() ?? '' : '');
  }
}
